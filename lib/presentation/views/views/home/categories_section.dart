import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/view_model/category_provider.dart';
import 'package:ztajir_furniture/presentation/views/views/view_all_product_by_category.dart';
import 'package:ztajir_furniture/presentation/views/widgets/category_widget/category_card.dart';
import 'package:ztajir_furniture/presentation/views/widgets/text_sections.dart';
import 'package:ztajir_furniture/presentation/views/widgets/view_all.dart';
import 'package:ztajir_furniture/presentation/views/views/home/all_categories_view.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CategoryProvider>().fetchCategories());
  }

  // دالة الانتقال لصفحة المنتجات
  void _navigateToAllProducts(
    BuildContext context,
    int categoryId,
    String categoryName,
    String? slug, // Added slug
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllProductsScreen(
          categoryId: categoryId,
          categoryName: categoryName,
          slug: slug,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== العنوان + زر عرض الكل =====
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextSections(
              textSection: AppLocalizations.of(
                context,
              )!.translate('categories'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllCategoriesView()),
                );
              },
              child: ViewAll(),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // ===== قائمة التصنيفات الأفقية =====
        SizedBox(
          height: 120.h,
          child: Consumer<CategoryProvider>(
            builder: (context, provider, _) {
              final categories = provider.categories;
              final isLoading = provider.isLoading;

              // إذا كان هناك تحميل أو القائمة فارغة (سواء بسبب خطأ أو بداية التحميل)، نعرض الـ Skeleton
              if (isLoading || categories.isEmpty) {
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (context, index) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    return _CategorySkeletonCard();
                  },
                );
              }

              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, index) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final categoryItem = categories[index];
                  return CategoryCard(
                    category: categoryItem,
                    // ألغينا التحديد المرئي لأننا سننتقل لصفحة أخرى
                    isSelected: true,
                    onTap: () {
                      // 🚀 التعديل الجوهري: الانتقال مباشرة لصفحة التصنيف
                      _navigateToAllProducts(
                        context,
                        categoryItem.id,
                        categoryItem.name,
                        categoryItem.slug, // Pass slug
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// Category Skeleton Card with Shimmer
class _CategorySkeletonCard extends StatefulWidget {
  const _CategorySkeletonCard();

  @override
  State<_CategorySkeletonCard> createState() => __CategorySkeletonCardState();
}

class __CategorySkeletonCardState extends State<_CategorySkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 80.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFFFFFFF),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: [
                0.0,
                (_animation.value * 0.5 - 0.25).clamp(0.0, 1.0),
                (_animation.value * 0.5).clamp(0.0, 1.0),
                (_animation.value * 0.5 + 0.25).clamp(0.0, 1.0),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}
