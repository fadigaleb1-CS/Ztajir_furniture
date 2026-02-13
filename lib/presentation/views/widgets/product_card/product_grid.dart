import 'package:flutter/material.dart';
import 'package:ztajir_furniture/data/models/product_model.dart';
import 'package:ztajir_furniture/presentation/views/widgets/product_card/product_card.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class ProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  final bool isSliver;

  const ProductGrid({super.key, required this.products, this.isSliver = false});

  @override
  Widget build(BuildContext context) {
    if (isSliver) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildRow(context, index),
          childCount: (products.length / 2).ceil(),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding:
          EdgeInsets.zero, // إزالة الـ padding لأن الصفحات لديها padding خاص
      itemCount: (products.length / 2).ceil(),
      itemBuilder: (context, index) => _buildRow(context, index),
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    final int firstIndex = index * 2;
    final int secondIndex = firstIndex + 1;
    final bool hasSecond = secondIndex < products.length;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h), // مضاعفة المسافة العمودية
      child: SizedBox(
        height: 240.h, // تقليل الارتفاع لجعل البطاقة أقصر
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: ProductCard(product: products[firstIndex])),
            SizedBox(width: 16.w), // مضاعفة المسافة الأفقية
            Expanded(
              child: hasSecond
                  ? ProductCard(product: products[secondIndex])
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
