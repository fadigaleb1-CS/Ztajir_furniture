import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/data/models/product_model.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/widgets/product_card/product_grid.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class SectionProductsView extends StatelessWidget {
  final String title;
  final List<ProductModel> products;

  const SectionProductsView({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: StaticAppBar(appBarName: title),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64.w,
                    color: AppColors.darkGreyColor.withOpacity(0.5),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    loc.translate('no_products_in_section'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.darkGreyColor,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: ProductGrid(products: products),
            ),
    );
  }
}
