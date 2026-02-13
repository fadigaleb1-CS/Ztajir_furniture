import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/presentation/view_model/product_provider.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/widgets/product_card/product_grid.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class DiscountedProductsByCategoryView extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final String? slug;

  const DiscountedProductsByCategoryView({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.slug,
  });

  @override
  State<DiscountedProductsByCategoryView> createState() =>
      _DiscountedProductsByCategoryViewState();
}

class _DiscountedProductsByCategoryViewState
    extends State<DiscountedProductsByCategoryView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Fetch products for this category
      context.read<ProductProvider>().fetchProductsByCategory(widget.slug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: StaticAppBar(
        // Using "Offers: [Category Name]" pattern or just Category Name
        appBarName: widget.categoryName,
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
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // FILTERING LOGIC:
          // We take the products returned for this category
          // AND keep only those that have a discount (oldPrice != null)
          final discountedCategoryProducts = provider.categoryProducts
              .where((product) => product.oldPrice != null)
              .toList();

          if (discountedCategoryProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.discount_rounded,
                    size: 80.w,
                    color: AppColors.darkGreyColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'لا توجد عروض في تصنيف ${widget.categoryName} حالياً.',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.darkGreyColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: ProductGrid(products: discountedCategoryProducts),
          );
        },
      ),
    );
  }
}
