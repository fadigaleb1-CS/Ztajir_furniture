import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ztajir_furniture/core/network/api_client.dart';
import 'package:ztajir_furniture/data/models/user_model.dart';
import 'package:ztajir_furniture/data/repositories/auth_repository.dart';
import 'package:ztajir_furniture/data/mock/mock_data.dart'; // For syncing
import 'package:ztajir_furniture/presentation/view_model/cart_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final ApiClient _apiClient = ApiClient();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  bool _isAutoLoginCheckComplete = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAutoLoginCheckComplete => _isAutoLoginCheckComplete;

  AuthProvider() {
    checkAuth();
  }

  // دالة للتحقق الصريح من حالة تسجيل الدخول، مفيدة في شاشة البداية
  Future<void> checkLoginStatus() async {
    // إذا لم ينته التحقق التلقائي بعد، ننتظره
    if (!_isAutoLoginCheckComplete) {
      // قد نحتاج لمنطق انتظار أفضل هنا، أو مجرد استدعاء checkAuth مرة أخرى
      // checkAuth sets _isAutoLoginCheckComplete = true at end.
      // We can just await checkAuth if needed, but it's already running in constructor.
      // Let's just wait a bit or re-trigger if needed.
      // For simplicity, re-awaiting checkAuth is fine as it handles idempotency mostly or re-fetches.
      // But better: Just wait till _isLoading becomes false?
      // Let's simplify: Just call checkAuth again to be sure.
      await checkAuth();
    }
  }

  // Check valid token and load user
  Future<void> checkAuth() async {
    _isLoading = true;
    _isAutoLoginCheckComplete = false;
    notifyListeners();

    try {
      // 1. Try to load user from local storage first for fast UI response
      debugPrint('🔐 AuthProvider: Starting local user load...');
      final localUser = await _loadUserFromPrefs();
      debugPrint('🔐 AuthProvider: Local user loaded: ${localUser?.email}');
      if (localUser != null) {
        _user = localUser;
        MockData.currentUser = localUser;
        debugPrint(
          '🔐 AuthProvider: User set from local storage: ${localUser.name}',
        );
      }
      // Mark local check as done, so SplashScreen knows we have a result
      _isAutoLoginCheckComplete = true;
      notifyListeners();

      // 2. Refresh user data from API if we have a token
      // This happens in background if we already have local user
      final user = await _repository.getCurrentUser();
      _setUser(user);
    } catch (e) {
      debugPrint('Auth Check Error: $e');
      // If API fails with 401, it means token is invalid.
      // But we should be careful. If we have a local user, we might want to keep them
      // "logged in" offline, PROBABLY NOT if it's 401. 401 means "I know who you are and your token is bad".
      if (e.toString().contains('401') ||
          e.toString().toLowerCase().contains('unauthorized')) {
        await logout();
      }
    } finally {
      // Ensure this is set to true even if everything fails
      _isAutoLoginCheckComplete = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.login(email, password);
      final String token = result['token'];
      final UserModel user = result['user'];

      await _apiClient.setAuthToken(token);
      _setUser(user);
      // مسح جلسة الضيف وإعادة جلب السلة بعد تسجيل الدخول
      await CartService().clearGuestSession();
      await CartService().fetchCart();
      return true;
    } catch (e) {
      String errorMessage = e.toString();

      // ترجمة أخطاء تسجيل الدخول
      if (errorMessage.contains('Invalid credentials') ||
          errorMessage.contains('invalid_credentials') ||
          errorMessage.contains('These credentials do not match our records')) {
        errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      } else if (errorMessage.contains('SocketException') ||
          errorMessage.contains('Connection refused')) {
        errorMessage = 'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة';
      } else if (errorMessage.contains('Too Many Requests')) {
        errorMessage = 'محاولات دخول كثيرة، يرجى الانتظار قليلاً';
      }

      _error = errorMessage;
      _user = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
      );

      if (result.containsKey('token')) {
        final String token = result['token'];
        final UserModel user = result['user'];
        await _apiClient.setAuthToken(token);
        _setUser(user);
        return true;
      }
      // If no token, maybe just success? return true to navigate to login?
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (e) {
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthenticated')) {
        debugPrint('Logout Info: Session already expired or invalid token.');
      } else {
        debugPrint('Logout API Error: $e');
      }
    }

    await _apiClient.clearAuthToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? avatarUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final parts = name.split(' ');
      final fName = parts.isNotEmpty ? parts.first : name;
      final lName = parts.length > 1
          ? parts.sublist(1).join(' ')
          : parts.length == 1
          ? ''
          : '';

      final updatedUser = await _repository.updateProfile(
        firstName: fName,
        lastName: lName,
        email: email,
        phone: phone,
        avatar: avatarUrl != null && !avatarUrl.startsWith('http')
            ? File(avatarUrl)
            : null,
      );

      // حفظ الصورة محلياً إذا كانت موجودة ولم يحفظها الـ Server
      UserModel finalUser = updatedUser;
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        // إذا كان الـ Server لم يُرجع الصورة، نحفظها محلياً
        if (updatedUser.avatarUrl == null || updatedUser.avatarUrl!.isEmpty) {
          finalUser = updatedUser.copyWith(avatarUrl: avatarUrl);
          // حفظ مسار الصورة المحلي بشكل منفصل
          await _saveLocalAvatarPath(avatarUrl);
        }
      }

      _setUser(finalUser);
    } catch (e) {
      _error = e.toString();
      debugPrint('Profile Update Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: confirmPassword,
      );
    } catch (e) {
      // ترجمة رسائل الخطأ الشائعة
      String errorMessage = e.toString();
      if (errorMessage.contains('current_password_incorrect')) {
        errorMessage = 'كلمة المرور الحالية غير صحيحة';
      } else if (errorMessage.contains('password_confirmation')) {
        errorMessage = 'كلمة المرور غير متطابقة';
      } else if (errorMessage.contains('password')) {
        errorMessage = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
      }

      _error = errorMessage;
      // نرمي الخطأ الجديد المترجم
      throw errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setUser(UserModel user) {
    UserModel updatedUser = user;

    // If the new user (likely from API) has no avatar, but we already have a local one
    // that is a local file path (suggesting it was recently picked but not uploaded), keep it.
    if ((user.avatarUrl == null || user.avatarUrl!.isEmpty) &&
        _user?.avatarUrl != null &&
        (_user!.avatarUrl!.startsWith('/') ||
            _user!.avatarUrl!.contains('\\'))) {
      updatedUser = user.copyWith(avatarUrl: _user!.avatarUrl);
    }

    _user = updatedUser;
    // Sync with MockData to keep old UI parts working
    MockData.currentUser = updatedUser;
    _saveUserToPrefs(updatedUser);
    notifyListeners();
  }

  Future<void> _saveUserToPrefs(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(user.toJson());
      debugPrint('💾 Saving user to prefs: $jsonData');
      await prefs.setString('user_data', jsonData);
    } catch (e) {
      debugPrint('❌ Error saving user to prefs: $e');
    }
  }

  Future<UserModel?> _loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      debugPrint('📖 Loading user from prefs: $userData');
      if (userData != null) {
        UserModel user = UserModel.fromJson(jsonDecode(userData));

        // إذا كانت الصورة فارغة، نحاول تحميل الصورة المحلية
        if (user.avatarUrl == null || user.avatarUrl!.isEmpty) {
          final localAvatar = await _loadLocalAvatarPath();
          if (localAvatar != null) {
            user = user.copyWith(avatarUrl: localAvatar);
            debugPrint('📷 Using local avatar: $localAvatar');
          }
        }

        return user;
      }
    } catch (e) {
      debugPrint('❌ Error loading user from prefs: $e');
    }
    return null;
  }

  // حفظ مسار الصورة المحلي
  Future<void> _saveLocalAvatarPath(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_avatar_path', path);
      debugPrint('📷 Saved local avatar path: $path');
    } catch (e) {
      debugPrint('❌ Error saving local avatar path: $e');
    }
  }

  // تحميل مسار الصورة المحلي
  Future<String?> _loadLocalAvatarPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('local_avatar_path');
    } catch (e) {
      debugPrint('❌ Error loading local avatar path: $e');
    }
    return null;
  }

  // حفظ بيانات الدخول (تذكرني)
  Future<void> saveCredentials(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
      // يمكن إضافة تشفير بسيط هنا إذا لزم الأمر، لكن SharedPreferences في أندرويد خاصة بالتطبيق
      debugPrint(' Credentials saved locally');
    } catch (e) {
      debugPrint(' Error saving credentials: $e');
    }
  }

  // تحميل بيانات الدخول المحفوظة
  Future<Map<String, String>?> loadCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('saved_email');
      final password = prefs.getString('saved_password');

      if (email != null &&
          email.isNotEmpty &&
          password != null &&
          password.isNotEmpty) {
        return {'email': email, 'password': password};
      }
    } catch (e) {
      debugPrint(' Error loading credentials: $e');
    }
    return null;
  }

  // حذف بيانات الدخول (إذا ألغى المستخدم خيار تذكرني)
  Future<void> clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      debugPrint(' Credentials cleared');
    } catch (e) {
      debugPrint(' Error clearing credentials: $e');
    }
  }
}
