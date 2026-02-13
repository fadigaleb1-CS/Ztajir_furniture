import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';

import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/presentation/view_model/product_provider.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/widgets/product_card/product_grid.dart';

class DiscountedProductsView extends StatefulWidget {
  const DiscountedProductsView({super.key});

  @override
  State<DiscountedProductsView> createState() => _DiscountedProductsViewState();
}

class _DiscountedProductsViewState extends State<DiscountedProductsView> {
  @override
  void initState() {
    super.initState();
    // Fetch all products to filter for discounts
    // Using microtask to avoid build conflicts
    Future.microtask(() {
      final productProvider = context.read<ProductProvider>();
      productProvider.fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: StaticAppBar(
        appBarName: "العروض الحصرية", // Or localized 'exclusive_offers'
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.whiteColor,
            size: 20.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading && productProvider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter for discounted products (where oldPrice is not null)
          // Also simple check to ensure oldPrice > price if needed, but model says oldPrice exists if has_discount
          final discountedProducts = productProvider.products
              .where((product) => product.oldPrice != null)
              .toList();

          if (discountedProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.percent_rounded,
                    size: 80.w,
                    color: AppColors.darkGreyColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "لا توجد عروض حالياً",
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: AppColors.darkGreyColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: ProductGrid(products: discountedProducts),
          );
        },
      ),
    );
  }
}
