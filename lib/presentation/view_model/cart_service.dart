// presentation/view_model/cart_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // For ChangeNotifier
import 'package:ztajir_furniture/data/models/cart_item_model.dart';
import 'package:ztajir_furniture/data/models/coupon_model.dart';
import 'package:ztajir_furniture/data/repositories/cart_repository.dart';
import 'package:ztajir_furniture/core/services/product_image_cache.dart';

class CartService extends ChangeNotifier {
  // 1. Singleton Setup
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;

  CartService._internal() {
    _repository = CartRepository();
    // Fetch cart immediately on initialization if needed, useful for persisting across screens
    fetchCart();
  }

  late final CartRepository _repository;
  List<CartItem> _cartItems = [];
  CouponModel? _appliedCoupon;
  bool _isLoading = false;
  String? _error;

  List<CartItem> get cartItems => _cartItems;
  CouponModel? get appliedCoupon => _appliedCoupon;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Subtotal (Original price without discount)
  double get subTotal {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  // Discount Amount
  double get discountAmount {
    if (_appliedCoupon == null) return 0.0;
    return subTotal * _appliedCoupon!.discountPercentage;
  }

  // Total Price (Subtotal - Discount)
  double get totalPrice {
    return subTotal - discountAmount;
  }

  // Fetch Cart from API
  Future<void> fetchCart() async {
    if (_isLoading) return; // Prevent multiple calls
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cartItems = await _repository.getCart();
      // حفظ صور المنتجات محلياً لاستخدامها في شاشة الطلبات
      final imageMap = <String, String>{};
      for (var item in _cartItems) {
        if (item.image.isNotEmpty) {
          imageMap[item.productId] = item.image;
        }
      }
      if (imageMap.isNotEmpty) {
        ProductImageCache.cacheImages(imageMap);
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print("Cart Fetch Error: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply Coupon (Local logic for demo, API based coupons can be added)
  void applyCoupon(String code) {
    // Mock Logic: Check against a local list of valid coupons
    final validCoupons = [
      CouponModel(
        code: 'SAVE20',
        discountPercentage: 0.20,
        description: '20% Off',
        expiryDate: DateTime.now().add(const Duration(days: 30)),
      ),
      CouponModel(
        code: 'SAVE10',
        discountPercentage: 0.10,
        description: '10% Welcome Bonus',
        expiryDate: DateTime.now().add(const Duration(days: 365)),
      ),
    ];
    try {
      final coupon = validCoupons.firstWhere(
        (c) => c.code.toUpperCase() == code.toUpperCase() && c.isValid,
      );
      _appliedCoupon = coupon;
      notifyListeners();
    } catch (e) {
      throw Exception('Invalid or expired coupon');
    }
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  // Add Item to Cart (API)
  Future<void> addItem(CartItem newItem) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Call API to add item
      _cartItems = await _repository.addToCart(
        newItem.productId,
        newItem.quantity,
      );
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print("Add Item Error: $e");
      }
      rethrow; // Let UI handle notification if needed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove Item from Cart (API)
  Future<void> removeItem(String itemId) async {
    // itemId here is the CART ITEM ID from the API response
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cartItems = await _repository.removeFromCart(itemId);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print("Remove Item Error: $e");
      }
    } finally {
      notifyListeners();
    }
  }

  // Update Item Quantity (PUT)
  Future<void> updateItemQuantity(String itemId, int quantity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cartItems = await _repository.updateCartItem(itemId, quantity);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print("Update Item Error: $e");
      }
      // Don't rethrow to avoid crashing UI, just log and notify error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper: Remove all quantity of an item (API logic same as remove single if using endpoint)
  // Or maybe Update quantity to 0? For now alias to removeItem
  Future<void> removeAllOfItem(String itemId) async {
    return removeItem(itemId);
  }

  // مسح جلسة الضيف (تُستدعى عند تسجيل الدخول)
  Future<void> clearGuestSession() async {
    await _repository.clearSessionId();
  }

  // Clear Cart (Local + API if supported)
  void clearCart() {
    _cartItems.clear();
    _appliedCoupon = null;
    notifyListeners();
    // Note: API might not have clear cart endpoint documented, so just clearing local view
    // Or iterate delete? Better wait for API documentation on Clear.
  }
}
