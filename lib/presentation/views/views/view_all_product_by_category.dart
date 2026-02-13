import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/presentation/view_model/product_provider.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/widgets/product_card/product_grid.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class AllProductsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final String? slug; // Added slug

  const AllProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.slug,
  });

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // If categoryId is 0, fetch all products (pass null slug)
      // Otherwise fetch by slug
      final slug = widget.categoryId == 0 ? null : widget.slug;
      context.read<ProductProvider>().fetchProductsByCategory(slug);
    });
  }

  @override
  Widget build(BuildContext context) {
    // إذا كان ID = 0 نعرض "جميع المنتجات"، وإلا نعرض اسم التصنيف
    final String title = widget.categoryId == 0
        ? 'جميع المنتجات'
        : widget.categoryName;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: StaticAppBar(appBarName: title),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categoryProducts.isEmpty) {
            return Center(
              child: Text(
                'لا توجد منتجات حالياً في تصنيف ${widget.categoryName}.',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: ProductGrid(products: provider.categoryProducts),
          );
        },
      ),
    );
  }
}
