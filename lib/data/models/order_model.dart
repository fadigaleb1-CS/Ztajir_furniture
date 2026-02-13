import 'package:ztajir_furniture/core/constants/api_constants.dart';
import 'package:ztajir_furniture/core/services/product_image_cache.dart';

class OrderModel {
  final int id;
  final String orderNumber;
  final String status;
  final double total;
  final double subTotal;
  final double discount;
  final double tax;
  final double shippingCost; // تكلفة الشحن
  final String currency;
  final DateTime createdAt;
  final String paymentMethod;
  final List<OrderItem> items;
  final bool canCancel;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.subTotal,
    required this.discount,
    required this.tax,
    required this.shippingCost,
    required this.currency,
    required this.createdAt,
    required this.paymentMethod,
    required this.items,
    required this.canCancel,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      status: json['status'] ?? 'pending',
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      subTotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      discount:
          double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      tax: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0.0,
      // قراءة تكلفة الشحن من الحقول المحتملة
      shippingCost:
          double.tryParse(
            json['shipping_cost']?.toString() ??
                json['shipping_amount']?.toString() ??
                json['delivery_fee']?.toString() ??
                '0',
          ) ??
          0.0,
      currency: 'YER', // العملة الافتراضية
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      paymentMethod: json['payment_method'] ?? 'Unknown',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      canCancel: _canCancel(json['status']),
    );
  }

  // يمكن إضافة دالة مساعدة للحصول على رابط الطلب للتفاصيل
  // String get detailUrl => '${ApiConstants.orders}/$orderNumber';

  static bool _canCancel(String? status) {
    if (status == null) return false;
    final s = status.toLowerCase();
    return s == 'pending' || s == 'new';
  }

  // خاصية للحصول على رمز الطلب للعرض (نفس orderNumber)
  String get orderCode => orderNumber;

  /// نسخة معدلة من الطلب مع تغيير حقول معينة
  OrderModel copyWith({String? paymentMethod}) {
    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      status: status,
      total: total,
      subTotal: subTotal,
      discount: discount,
      tax: tax,
      shippingCost: shippingCost,
      currency: currency,
      createdAt: createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items,
      canCancel: canCancel,
    );
  }

  /// تعبئة صور المنتجات من الكاش المحلي (للعناصر التي لا تحتوي على صورة من API)
  Future<void> fillCachedImages() async {
    for (var item in items) {
      if (item.productImage == null || item.productImage!.isEmpty) {
        final cached = await ProductImageCache.getImage(
          item.productId.toString(),
        );
        if (cached != null && cached.isNotEmpty) {
          item._cachedImage = cached;
        }
      }
    }
  }
}

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? _apiImage;
  String? _cachedImage;
  final double price;
  final int quantity;
  final double total;

  /// الصورة الفعلية: من API أولاً، ثم من الكاش المحلي
  String? get productImage => _apiImage ?? _cachedImage;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    String? productImage,
    required this.price,
    required this.quantity,
    required this.total,
  }) : _apiImage = productImage;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;

    // استخراج اسم المنتج من عدة مصادر محتملة
    String name =
        json['product_name'] ?? product?['name'] ?? json['name'] ?? 'Product';

    // استخراج الصورة من عدة مصادر محتملة
    String? img;
    if (product != null && product['main_image'] != null) {
      img = product['main_image'].toString();
    } else if (json['main_image'] != null) {
      img = json['main_image'].toString();
    } else if (json['image'] != null) {
      img = json['image'].toString();
    } else if (json['product_image'] != null) {
      img = json['product_image'].toString();
    }

    // بناء الرابط الكامل للصورة
    String? fullImageUrl;
    if (img != null && img.isNotEmpty) {
      if (img.startsWith('http')) {
        fullImageUrl = img;
      } else {
        fullImageUrl = '${ApiConstants.storageUrl}/$img';
      }
    }

    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: name,
      productImage: fullImageUrl,
      price: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      quantity: json['quantity'] ?? 1,
      total: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
    );
  }
}
