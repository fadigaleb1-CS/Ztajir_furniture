import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/presentation/view_model/product_provider.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/widgets/product_card/product_grid.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class AllProductsByBrandScreen extends StatefulWidget {
  final int brandId;
  final String brandName;

  const AllProductsByBrandScreen({
    super.key,
    required this.brandId,
    required this.brandName,
  });

  @override
  State<AllProductsByBrandScreen> createState() =>
      _AllProductsByBrandScreenState();
}

class _AllProductsByBrandScreenState extends State<AllProductsByBrandScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<ProductProvider>().fetchProductsByBrandId(
        widget.brandId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: StaticAppBar(appBarName: widget.brandName),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.brandProducts.isEmpty) {
            return Center(
              child: Text(
                'لا توجد منتجات حالياً للعلامة التجارية ${widget.brandName}.',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: ProductGrid(products: provider.brandProducts),
          );
        },
      ),
    );
  }
}
