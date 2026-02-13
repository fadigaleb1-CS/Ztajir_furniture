import 'dart:math';
import 'package:ztajir_furniture/core/constants/api_constants.dart';

class ProductModel {
  final int id;
  final String title;
  final String? slug; // الـ slug الخاص بالمنتج
  final String image;
  final double price;
  final double? oldPrice;
  final double rating;
  final int categoryId;
  final String? categorySlug;
  final int brandId;
  final String? brandName; // اسم العلامة التجارية
  final String describtion;
  bool isFavorite;
  final bool isNew;
  final bool isFeatured;
  final String? currency;
  final int stockQuantity;
  final bool inStock;
  final List<String> images;
  final List<ProductAttribute> attributes;

  ProductModel({
    required this.id,
    required this.title,
    this.slug,
    required this.image,
    required this.price,
    this.oldPrice,
    required this.rating,
    required this.categoryId,
    this.categorySlug,
    required this.brandId,
    this.brandName,
    this.isFavorite = false,
    required this.describtion,
    this.isNew = false,
    this.isFeatured = false,
    this.currency,
    this.stockQuantity = 0,
    this.inStock = true,
    this.images = const [],
    this.attributes = const [],
  });

  void toggleFavorite() {
    isFavorite = !isFavorite;
  }

  /// توليد rating عشوائي ثابت بناءً على الـ ID (بين 3.5 و 5.0)
  static double _generateRating(int productId) {
    // استخدام الـ ID كـ seed لضمان نفس الـ rating دائماً لنفس المنتج
    final random = Random(productId);
    // توليد قيمة بين 3.5 و 5.0 مع خطوة 0.1
    return 3.5 + (random.nextInt(16) * 0.1); // 3.5 to 5.0
  }

  /// Create ProductModel from JSON (API response)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final productId = json['id'] as int;

    // Handle price object if exists, or flat fields
    // Handle price object if exists, or flat fields
    double currentPrice = 0.0;
    double? oldPriceVal;
    String? currencyVal;

    if (json['price'] is Map) {
      final priceObj = json['price'];
      currentPrice = (priceObj['current'] as num?)?.toDouble() ?? 0.0;
      if (priceObj['has_discount'] == true && priceObj['base'] != null) {
        oldPriceVal = (priceObj['base'] as num).toDouble();
      }
      currencyVal = priceObj['currency'];
    } else {
      // Fallback for list style (if any)
      double? cPrice = (json['current_price'] as num?)?.toDouble();
      double? bPrice = (json['price'] as num?)?.toDouble();

      if (cPrice != null) {
        currentPrice = cPrice;
        if (json['has_discount'] == true) {
          oldPriceVal = bPrice;
        }
      } else {
        // If current_price is missing, use 'price' as current
        currentPrice = bPrice ?? 0.0;
      }
      currencyVal = json['currency'];
    }

    // Handle Stock
    int qty = 0;
    bool inStk = true;
    if (json['stock'] is Map) {
      qty = json['stock']['quantity'] ?? 0;
      inStk = json['stock']['in_stock'] ?? true;
    } else {
      // Flat fields fallback
      qty = json['stock_quantity'] ?? json['quantity'] ?? 0;
      inStk = json['in_stock'] ?? true;
    }

    // Handle Brand
    int bId = 0;
    String? bName;
    if (json['brand'] is Map) {
      bId = json['brand']['id'] ?? 0;
      bName = json['brand']['name'];
    } else {
      bId = json['brand_id'] ?? 0;
      bName = json['brand_name'];
    }

    // Handle Categories (Main category)
    int cId = 0;
    String? cSlug;
    if (json['categories'] is List && (json['categories'] as List).isNotEmpty) {
      cId = json['categories'][0]['id'] ?? 0;
      cSlug = json['categories'][0]['slug'];
    } else {
      cId = json['category_id'] ?? 0;
      if (json['category'] is Map) {
        cSlug = json['category']['slug'];
      }
    }

    // Handle Images
    List<String> imgs = [];
    if (json['images'] is List) {
      imgs = (json['images'] as List)
          .map((e) {
            if (e is Map && e['url'] != null) {
              return _buildFullImageUrl(e['url'].toString());
            } else if (e is String) {
              return _buildFullImageUrl(e);
            }
            return '';
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // Handle Attributes from default_variant
    List<ProductAttribute> attrs = [];
    if (json['default_variant'] is Map &&
        json['default_variant']['attributes'] is List) {
      attrs = (json['default_variant']['attributes'] as List)
          .map((e) => ProductAttribute.fromJson(e))
          .toList();
    }

    return ProductModel(
      id: productId,
      title: json['name'] as String? ?? json['title'] ?? '',
      slug: json['slug'] as String?,
      image: _buildFullImageUrl(json['main_image'] ?? json['image']),
      price: currentPrice,
      oldPrice: oldPriceVal,
      rating: json['rating']?.toDouble() ?? _generateRating(productId),
      categoryId: cId,
      categorySlug: cSlug,
      brandId: bId,
      brandName: bName,
      describtion: json['description'] ?? json['short_description'] ?? '',
      isFavorite: json['is_favorite'] ?? false,
      isNew: json['is_new'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      currency: currencyVal,
      stockQuantity: qty,
      inStock: inStk,
      images: imgs,
      attributes: attrs,
    );
  }

  /// Create ProductModel from Wishlist JSON structure
  factory ProductModel.fromWishlistJson(Map<String, dynamic> json) {
    try {
      final productData = json['product'];
      if (productData != null && productData is Map<String, dynamic>) {
        // Use the robust fromJson to parse product data
        var product = ProductModel.fromJson(productData);
        // Ensure it's marked as favorite since it comes from wishlist
        product.isFavorite = true;
        return product;
      }
    } catch (e) {
      print('⚠️ Error parsing wishlist product with fromJson: $e');
      print('Falling back to manual parsing...');
    }

    // Fallback Manual Parsing (matches previous logic but safer)
    final productJson = json['product'] ?? {};
    final productId = productJson['id'] as int? ?? 0;

    return ProductModel(
      id: productId,
      title: productJson['name'] ?? productJson['title'] ?? '',
      slug: productJson['slug'] as String?,
      image: _buildFullImageUrl(
        productJson['main_image'] ?? productJson['image'],
      ),
      price: _getWishlistFinalPrice(productJson),
      oldPrice: _getWishlistOldPrice(productJson),
      rating: productJson['rating']?.toDouble() ?? _generateRating(productId),
      categoryId: productJson['category_id'] as int? ?? 0,
      categorySlug: productJson['category']?['slug'],
      brandId: productJson['brand_id'] as int? ?? 0,
      brandName: productJson['brand']?['name'] ?? productJson['brand_name'],
      describtion:
          productJson['description'] ??
          productJson['short_description'] ??
          productJson['slug'] ??
          '',
      isFavorite: true,
      isNew: productJson['is_new'] ?? false,
      isFeatured: productJson['is_featured'] ?? false,
      currency: 'YER',
      stockQuantity: productJson['quantity'] ?? 0,
      inStock: (productJson['quantity'] ?? 0) > 0,
    );
  }

  /// Convert ProductModel to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'slug': slug,
      'image': image,
      'current_price': price,
      'price': oldPrice,
      'rating': rating,
      'categoryId': categoryId,
      'categorySlug': categorySlug,
      'brandId': brandId,
      'brandName': brandName,
      'description': describtion,
      'is_favorite': isFavorite,
      'is_new': isNew,
      'is_featured': isFeatured,
      'currency': currency,
    };
  }

  /// Create a list of ProductModel from JSON list
  static List<ProductModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ProductModel.fromJson(json)).toList();
  }

  /// Create a copy of ProductModel with updated fields
  ProductModel copyWith({
    int? id,
    String? title,
    String? slug,
    String? image,
    double? price,
    double? oldPrice,
    double? rating,
    int? categoryId,
    String? categorySlug,
    int? brandId,
    String? brandName,
    String? describtion,
    bool? isFavorite,
    bool? isNew,
    bool? isFeatured,
    String? currency,
    List<ProductAttribute>? attributes,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      image: image ?? this.image,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      rating: rating ?? this.rating,
      categoryId: categoryId ?? this.categoryId,
      categorySlug: categorySlug ?? this.categorySlug,
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      describtion: describtion ?? this.describtion,
      isFavorite: isFavorite ?? this.isFavorite,
      isNew: isNew ?? this.isNew,
      isFeatured: isFeatured ?? this.isFeatured,
      currency: currency ?? this.currency,
      attributes: attributes ?? this.attributes,
    );
  }

  /// Helper method to build full image URL from relative path
  static String _buildFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    // إذا كان الرابط كامل بالفعل (يبدأ بـ http أو https)، نرجعه كما هو
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return imagePath;
    }
    // إضافة الـ Base Storage URL للمسار النسبي
    final baseUrl = ApiConstants.storageUrl;
    if (!baseUrl.endsWith('/') && !imagePath.startsWith('/')) {
      return '$baseUrl/$imagePath';
    }
    return '$baseUrl$imagePath';
  }

  /// Helper: Get final price (current price) from wishlist JSON
  static double _getWishlistFinalPrice(Map<String, dynamic> json) {
    // Try final_price first (discounted), then current_price, then base_price
    double finalPrice =
        double.tryParse(json['final_price']?.toString() ?? '0') ??
        double.tryParse(json['current_price']?.toString() ?? '0') ??
        0.0;

    if (finalPrice > 0) return finalPrice;

    // Fallback to base_price or price
    return double.tryParse(json['base_price']?.toString() ?? '0') ??
        double.tryParse(json['price']?.toString() ?? '0') ??
        0.0;
  }

  /// Helper: Get old price (before discount) from wishlist JSON
  static double? _getWishlistOldPrice(Map<String, dynamic> json) {
    double basePrice =
        double.tryParse(json['base_price']?.toString() ?? '0') ?? 0.0;
    double finalPrice = _getWishlistFinalPrice(json);

    // If base_price > final_price, there's a discount
    if (basePrice > finalPrice) {
      return basePrice;
    }

    // Check explicit old_price field
    if (json['old_price'] != null) {
      double? oldPrice = double.tryParse(json['old_price'].toString());
      if (oldPrice != null && oldPrice > finalPrice) {
        return oldPrice;
      }
    }

    return null; // No discount
  }
}

class ProductAttribute {
  final int id;
  final String name;
  final String value;

  ProductAttribute({required this.id, required this.name, required this.value});

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'] ?? 0,
      name: json['attribute_name'] ?? '',
      value: json['value'] ?? '',
    );
  }
}
