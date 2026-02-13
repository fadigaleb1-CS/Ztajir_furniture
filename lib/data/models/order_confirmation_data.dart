import 'package:ztajir_furniture/data/models/cart_item_model.dart';

/// نموذج لبيانات الطلب المكتمل
class OrderConfirmationData {
  final String orderId;
  final DateTime orderDate;
  final List<CartItem> items;
  final double subTotal;
  final double discount;
  final double total;
  final String paymentMethod;
  final String? couponCode;
  final String currency;

  OrderConfirmationData({
    required this.orderId,
    required this.orderDate,
    required this.items,
    required this.subTotal,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    this.couponCode,
    this.currency = 'YER',
  });
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderDate': orderDate.toIso8601String(),
      'items': items.map((x) => x.toJson()).toList(),
      'subTotal': subTotal,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod,
      'couponCode': couponCode,
      'currency': currency,
    };
  }

  factory OrderConfirmationData.fromJson(Map<String, dynamic> json) {
    return OrderConfirmationData(
      orderId: json['orderId'],
      orderDate: DateTime.parse(json['orderDate']),
      items: (json['items'] as List).map((x) => CartItem.fromJson(x)).toList(),
      subTotal: (json['subTotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['paymentMethod'],
      couponCode: json['couponCode'],
      currency: json['currency'] ?? 'YER',
    );
  }
}
