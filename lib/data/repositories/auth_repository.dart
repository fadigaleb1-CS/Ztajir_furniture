import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ztajir_furniture/core/network/api_client.dart';
import 'package:ztajir_furniture/core/constants/api_constants.dart';
import 'package:ztajir_furniture/data/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Login
  /// Returns Map with 'user' (UserModel) and 'token' (String)
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'];
        final user = UserModel.fromJson(data['customer']);
        return {'token': token, 'user': user};
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Register
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      // Debug: طباعة البيانات المرسلة
      final requestData = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'phone': phone,
      };
      print('📤 REGISTER REQUEST DATA: $requestData');

      final response = await _apiClient.post(
        ApiConstants.register,
        data: requestData,
      );

      print('📥 REGISTER RESPONSE: ${response.data}');

      // Check success logic.
      // If server returns validation errors (422), Dio throws error.
      // We handle success case here.
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Assuming register logs in automatically or returns success.
        // If it returns token/user like login:
        if (response.data['success'] == true && response.data['data'] != null) {
          final data = response.data['data'];
          // Verify structure. If just message, we might need to login.
          if (data['token'] != null) {
            final token = data['token'];
            // Check if customer or user key exists
            final userJson = data['customer'] ?? data['user'];
            final user = UserModel.fromJson(userJson);
            return {'token': token, 'user': user};
          }
        }
        return {}; // Return empty if explicit success but no token (e.g. verify email)
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get Current User
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get('${ApiConstants.apiUrl}/auth/me');

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (e) {
      // Even if logout fails on server (e.g. token expired), we should proceed with local logout
      rethrow;
    }
  }

  /// Update Profile
  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    File? avatar,
  }) async {
    try {
      // Need to handle FormData for image upload if avatar is present
      // For now, assuming JSON body if no avatar, or FormData if avatar.
      // But ApiClient might need adjustment for FormData.
      // Let's assume JSON first as per existing structure,
      // but usually profile update needs FormData for images.

      // Since ApiClient wraps Dio, we can pass FormData.

      final Map<String, dynamic> data = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
      };

      dynamic requestData = data;

      // إذا كانت الصورة موجودة، نستخدم FormData
      if (avatar != null && avatar.existsSync()) {
        requestData = FormData.fromMap({
          ...data,
          'avatar': await MultipartFile.fromFile(
            avatar.path,
            filename: avatar.path.split('/').last,
          ),
        });
      }

      final response = await _apiClient.put(
        ApiConstants.profile,
        data: requestData,
      );

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.apiUrl}/auth/password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPasswordConfirmation,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
