import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/presentation/view_model/brand_provider.dart';
import 'package:ztajir_furniture/presentation/views/views/view_all_product_by_brand.dart';
import 'package:ztajir_furniture/presentation/views/widgets/brand_widget/brand_card.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/presentation/views/widgets/text_sections.dart';
import 'package:ztajir_furniture/presentation/views/widgets/view_all.dart';
import 'package:ztajir_furniture/presentation/views/views/home/all_brands_view.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';

class BrandsSection extends StatefulWidget {
  const BrandsSection({super.key});

  @override
  State<BrandsSection> createState() => _BrandsSectionState();
}

class _BrandsSectionState extends State<BrandsSection> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BrandProvider>().fetchBrands());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Consumer<BrandProvider>(
      builder: (context, provider, _) {
        final brands = provider.brands;
        final isLoading = provider.isLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextSections(textSection: loc.translate('brands_title')),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllBrandsView()),
                    );
                  },
                  child: const ViewAll(),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            CarouselSlider.builder(
              itemCount: (isLoading || brands.isEmpty) ? 3 : brands.length,
              itemBuilder: (context, index, _) {
                // Skeleton للتحميل مع shimmer
                if (isLoading || brands.isEmpty) {
                  return _BrandSkeletonCard();
                }

                final brand = brands[index];
                return AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: index == _currentIndex ? 1 : 0.92,
                  child: brand_card(
                    image: brand.image,
                    name: brand.name,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllProductsByBrandScreen(
                          brandId: brand.id,
                          brandName: brand.name,
                        ),
                      ),
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 100.h,
                enlargeCenterPage: true,
                enlargeFactor: 0.15,
                viewportFraction: 0.75,
                onPageChanged: (i, _) => setState(() => _currentIndex = i),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Brand Skeleton Card with Shimmer
class _BrandSkeletonCard extends StatefulWidget {
  const _BrandSkeletonCard();

  @override
  State<_BrandSkeletonCard> createState() => __BrandSkeletonCardState();
}

class __BrandSkeletonCardState extends State<_BrandSkeletonCard>
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
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.w),
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
