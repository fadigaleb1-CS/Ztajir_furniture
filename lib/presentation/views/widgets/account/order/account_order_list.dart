import 'package:flutter/material.dart';
import 'package:ztajir_furniture/data/models/product_model.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

import 'package:ztajir_furniture/presentation/views/widgets/account/order/account_order_card.dart';

class OrdersList extends StatelessWidget {
  final List<ProductModel> products;
  final String status;
  const OrdersList({required this.products, required this.status});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const Center(child: Text("لا توجد طلبات هنا"));

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: products.length,
      itemBuilder: (context, index) =>
          OrderCard(product: products[index], status: status),
    );
  }
}
