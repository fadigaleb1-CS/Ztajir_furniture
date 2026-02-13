// lib/data/models/cart_item_model.dart

import 'package:ztajir_furniture/core/constants/api_constants.dart';

class CartItem {
  final String id; // cart_item_id
  final String productId;
  final String title;
  final double price;
  final String image;
  int quantity;
  final String currency;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    this.quantity = 1,
    this.currency = 'YER',
  });

  /// Create CartItem from JSON (API response)
  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};

    String imgPath = product['main_image'] ?? '';
    if (imgPath.isNotEmpty && !imgPath.startsWith('http')) {
      imgPath = '${ApiConstants.storageUrl}/$imgPath';
    }

    return CartItem(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      title: product['name'] ?? 'Unknown Product',
      price: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      image: imgPath,
      quantity: json['quantity'] ?? 1,
      currency: 'YER', // Default currency
    );
  }

  /// Convert CartItem to JSON (API request payload format if needed)
  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'quantity': quantity};
  }

  // دالة مساعدة لإنشاء عنصر محلي مؤقت
  factory CartItem.local({
    required String productId,
    required String title,
    required double price,
    required String image,
    int quantity = 1,
  }) {
    return CartItem(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      title: title,
      price: price,
      image: image,
      quantity: quantity,
    );
  }

  /// Get total price for this item
  double get totalPrice => price * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    String? title,
    double? price,
    String? image,
    int? quantity,
    String? currency,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      currency: currency ?? this.currency,
    );
  }
}
