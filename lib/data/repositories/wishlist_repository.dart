import 'package:ztajir_furniture/core/network/api_client.dart';
import 'package:ztajir_furniture/core/network/api_endpoints.dart';
import 'package:ztajir_furniture/data/models/product_model.dart';

class WishlistRepository {
  final ApiClient _apiClient;

  WishlistRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get Wishlist Items (as Products)
  /// Returns a Map where key is Product ID and value is Wishlist Item ID (for deletion)
  /// Also returns list of products.
  Future<List<Map<String, dynamic>>> getWishlistItems() async {
    try {
      // استخدام المسار النسبي ليتم إضافة الـ Token تلقائياً
      final response = await _apiClient.get(ApiEndpoints.wishlist);

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['data'];
        return data.map((item) {
          return {
            'wishlist_id': item['id'], // The ID to delete
            'product': ProductModel.fromWishlistJson(item),
          };
        }).toList();
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Add to Wishlist
  /// Returns the new Wishlist Item ID
  Future<int> addToWishlist(int productId) async {
    print('❤️ API: Adding productId=$productId to wishlist');
    try {
      final response = await _apiClient.post(
        ApiEndpoints.wishlist,
        data: {'product_id': productId},
      );
      print('📥 Add Response: ${response.data}');

      if (response.data['success'] == true) {
        final int newId = response.data['data']['id'];
        print('✅ Added successfully. New Wishlist ID: $newId');
        return newId;
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      print('❌ Error adding to wishlist: $e');
      rethrow;
    }
  }

  /// Remove from Wishlist using Product ID
  /// METHOD: DELETE
  /// URL: /wishlist
  /// BODY: {"product_id": X}
  Future<void> removeFromWishlist(int productId) async {
    print('🗑️ API: Deleting product ID: $productId from wishlist');

    try {
      final response = await _apiClient.delete(
        ApiEndpoints.wishlist,
        data: {'product_id': productId},
      );

      if (response.data['success'] == true) {
        print('✅ Removed from wishlist successfully');
        return;
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      print('❌ Error removing from wishlist: $e');
      rethrow;
    }
  }
}
