import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة تخزين صور المنتجات محلياً
/// تُستخدم لحفظ رابط صورة المنتج عند الشراء واسترجاعه عند عرض الطلبات
/// لأن API الطلبات لا يُرجع صورة المنتج
class ProductImageCache {
  static const String _cacheKey = 'product_image_cache';

  /// حفظ صورة منتج واحد
  static Future<void> cacheImage(String productId, String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> cache = _getCache(prefs);
    cache[productId] = imageUrl;
    await prefs.setString(_cacheKey, jsonEncode(cache));
  }

  /// حفظ صور عدة منتجات دفعة واحدة
  static Future<void> cacheImages(Map<String, String> images) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> cache = _getCache(prefs);
    cache.addAll(images);
    await prefs.setString(_cacheKey, jsonEncode(cache));
  }

  /// استرجاع صورة منتج
  static Future<String?> getImage(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = _getCache(prefs);
    return cache[productId] as String?;
  }

  /// استرجاع صورة منتج (متزامن - يحتاج instance مسبق)
  static String? getImageSync(SharedPreferences prefs, String productId) {
    final cache = _getCache(prefs);
    return cache[productId] as String?;
  }

  static Map<String, dynamic> _getCache(SharedPreferences prefs) {
    final String? raw = prefs.getString(_cacheKey);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}

/// كاش لحفظ طريقة الدفع المختارة لكل طلب
/// لأن السيرفر يرجع "cash" دائماً بغض النظر عن الطريقة المختارة
class PaymentMethodCache {
  static const String _cacheKey = 'order_payment_method_cache';

  /// حفظ طريقة الدفع لطلب معين
  static Future<void> save(String orderNumber, String methodId) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = _getCache(prefs);
    cache[orderNumber] = methodId;
    await prefs.setString(_cacheKey, jsonEncode(cache));
  }

  /// استرجاع طريقة الدفع لطلب معين
  static Future<String?> get(String orderNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = _getCache(prefs);
    return cache[orderNumber] as String?;
  }

  static Map<String, dynamic> _getCache(SharedPreferences prefs) {
    final String? raw = prefs.getString(_cacheKey);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
