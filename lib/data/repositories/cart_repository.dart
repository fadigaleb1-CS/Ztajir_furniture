import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ztajir_furniture/core/network/api_client.dart';
import 'package:ztajir_furniture/core/constants/api_constants.dart';
import 'package:ztajir_furniture/data/models/cart_item_model.dart';

class CartRepository {
  final ApiClient _apiClient = ApiClient();
  String? _sessionId;

  // توليد session_id فريد محلياً
  String _generateSessionId() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final id = List.generate(
      40,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    return 'guest_$id';
  }

  // تحميل أو إنشاء session_id
  Future<String> _getSessionId() async {
    if (_sessionId != null) return _sessionId!;
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString('guest_session_id');
    if (_sessionId == null) {
      _sessionId = _generateSessionId();
      await prefs.setString('guest_session_id', _sessionId!);
      if (kDebugMode) {
        print('🛒 Generated new guest session_id: $_sessionId');
      }
    }
    return _sessionId!;
  }

  // مسح session_id (عند تسجيل الدخول مثلاً)
  Future<void> clearSessionId() async {
    _sessionId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('guest_session_id');
  }

  // التحقق مما إذا كان المستخدم ضيف (لا يوجد auth token)
  Future<bool> _isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    return authToken == null || authToken.isEmpty;
  }

  // إنشاء Options مع skipAuth للضيف (لمنع إرسال auth token قديم)
  Options _guestOptions() {
    return Options(extra: {'skipAuth': true});
  }

  // جلب عناصر السلة
  Future<List<CartItem>> getCart() async {
    try {
      Options? options;
      Map<String, dynamic>? queryParams;

      if (await _isGuest()) {
        final sessionId = await _getSessionId();
        queryParams = {'session_id': sessionId};
        options = _guestOptions();
      }

      final response = await _apiClient.get(
        ApiConstants.cart,
        queryParameters: queryParams,
        options: options,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data['items'] is List) {
          return (data['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList();
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching cart: $e");
      }
      return [];
    }
  }

  // إضافة عنصر للسلة
  Future<List<CartItem>> addToCart(String productId, int quantity) async {
    try {
      final Map<String, dynamic> body = {
        'product_id': productId,
        'quantity': quantity,
      };

      Options? options;
      if (await _isGuest()) {
        body['session_id'] = await _getSessionId();
        options = _guestOptions();
      }

      final response = await _apiClient.post(
        ApiConstants.cartItems,
        data: body,
        options: options,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data['items'] is List) {
          return (data['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList();
        }
        return [];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add item');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error adding to cart: $e");
      }
      rethrow;
    }
  }

  // حذف عنصر من السلة
  Future<List<CartItem>> removeFromCart(String itemId) async {
    try {
      Options? options;
      Map<String, dynamic>? queryParams;

      if (await _isGuest()) {
        queryParams = {'session_id': await _getSessionId()};
        options = _guestOptions();
      }

      final response = await _apiClient.delete(
        '${ApiConstants.cartItems}/$itemId',
        queryParameters: queryParams,
        options: options,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data['items'] is List) {
          return (data['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList();
        }
        return [];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to remove item');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error removing form cart: $e");
      }
      rethrow;
    }
  }

  // تحديث كمية عنصر باستخدام PUT
  Future<List<CartItem>> updateCartItem(String itemId, int quantity) async {
    try {
      final Map<String, dynamic> body = {'quantity': quantity};

      Options? options;
      if (await _isGuest()) {
        body['session_id'] = await _getSessionId();
        options = _guestOptions();
      }

      final response = await _apiClient.put(
        '${ApiConstants.cartItems}/$itemId',
        data: body,
        options: options,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data['items'] is List) {
          return (data['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList();
        }
        return [];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update item');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating cart item: $e");
      }
      rethrow;
    }
  }
}
