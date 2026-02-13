import 'package:flutter/material.dart';
import 'package:ztajir_furniture/data/models/product_model.dart';
import 'package:ztajir_furniture/data/repositories/wishlist_repository.dart';

class FavoriteProvider extends ChangeNotifier {
  final WishlistRepository _repository = WishlistRepository();

  // Map Product ID (int) -> Wishlist Item ID (int)
  // If product ID exists in keys, it is favorited.
  // The value is the ID needed to delete it.
  Map<int, int> _favoritesMap = {};
  List<ProductModel> _favoriteProducts = [];

  bool _isLoading = false;
  String? error;

  List<ProductModel> get favoriteProducts => _favoriteProducts;
  bool get isLoading => _isLoading;

  FavoriteProvider() {
    fetchFavorites();
  }

  /// Fetch Favorites from API
  Future<void> fetchFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final items = await _repository.getWishlistItems();
      _favoritesMap.clear();
      _favoriteProducts.clear();

      for (var item in items) {
        final ProductModel product = item['product'];
        final int wishlistId = item['wishlist_id'];
        _favoritesMap[product.id] = wishlistId;
        _favoriteProducts.add(product);

        // Also update local `isFavorite` flag if needed for UI consistency
        product.isFavorite = true;
      }
    } catch (e) {
      error = e.toString();
      print('❌ Error fetching wishlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all favorites (used when logging out)
  void clearFavorites() {
    _favoritesMap.clear();
    _favoriteProducts.clear();
    error = null;
    notifyListeners();
    print('🧹 Favorites cleared');
  }

  /// Check if product is in favorites
  bool isFavorite(String productId) {
    final id = int.tryParse(productId);
    if (id == null) return false;
    return _favoritesMap.containsKey(id);
  }

  /// Toggle Favorite
  Future<void> toggleFavorite(ProductModel product) async {
    final pId = product.id;

    if (_favoritesMap.containsKey(pId)) {
      // It is favorite -> Remove it
      await _removeFromWishlist(pId);
    } else {
      // Is not favorite -> Add it
      await _addToWishlist(product);
    }
  }

  Future<void> _addToWishlist(ProductModel product) async {
    final pId = product.id;
    // Optimistic Update: Add to map and list immediately
    // Use stored/temp ID for map value (e.g. 0 or negative) until server response?
    // Correct approach: We need the return value ID for deletion.
    // If we add it optimistically, we can't delete it until the request finishes.
    // But for UI feedback (Red Heart), map presence is enough.

    _favoritesMap[pId] = 0; // Temporary placeholder
    _favoriteProducts.add(product);
    notifyListeners();

    try {
      final wishlistId = await _repository.addToWishlist(pId);
      // Update with real ID
      if (_favoritesMap.containsKey(pId)) {
        _favoritesMap[pId] = wishlistId;
      }
      print('✅ Added to wishlist on server. Wishlist ID: $wishlistId');
    } catch (e) {
      print('❌ Error adding to wishlist (server): $e');
      // Revert local changes
      _favoritesMap.remove(pId);
      _favoriteProducts.removeWhere((p) => p.id == pId); // Safe remove by ID
      error = "failed_to_add_wishlist"; // Simple error key
      notifyListeners();
    }
  }

  Future<void> _removeFromWishlist(int productId) async {
    print('🗑️ Attempting to remove: productId=$productId');

    // حفظ المنتج قبل الحذف للاسترجاع في حالة الفشل
    ProductModel? removedProduct;
    int? oldWishlistId = _favoritesMap[productId];

    // Find product to keep backup
    try {
      removedProduct = _favoriteProducts.firstWhere((p) => p.id == productId);
    } catch (_) {
      removedProduct = null;
    }

    // Optimistic Remove
    _favoritesMap.remove(productId);
    _favoriteProducts.removeWhere((p) => p.id == productId);
    notifyListeners();

    print('✅ Removed locally, calling API...');

    try {
      // إرسال productId للحذف (DELETE /wishlist مع body)
      await _repository.removeFromWishlist(productId);
      print('✅ Removed from server successfully');
    } catch (e) {
      print('❌ Error removing from wishlist: $e');

      // استرجاع المنتج في حالة فشل الـ API
      if (removedProduct != null) {
        _favoritesMap[productId] = oldWishlistId ?? 0;
        _favoriteProducts.add(removedProduct);
        error = "failed_to_remove_wishlist";
        notifyListeners();
        print('🔄 Restored product locally due to API failure');
      } else {
        // If we lost the product object, we might need to re-fetch
        fetchFavorites();
      }
    }
  }
}
