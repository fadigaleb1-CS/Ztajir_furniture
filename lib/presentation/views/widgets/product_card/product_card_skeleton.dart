import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class ProductCardSkeleton extends StatefulWidget {
  const ProductCardSkeleton({super.key});

  @override
  State<ProductCardSkeleton> createState() => _ProductCardSkeletonState();
}

class _ProductCardSkeletonState extends State<ProductCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170.w,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreyColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder with enhanced shimmer
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.w)),
            child: AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Container(
                  height: 140.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFFE0E0E0),
                        const Color(0xFFF5F5F5),
                        const Color(0xFFFFFFFF),
                        const Color(0xFFF5F5F5),
                        const Color(0xFFE0E0E0),
                      ],
                      stops: [
                        0.0,
                        _shimmerAnimation.value * 0.5 - 0.2,
                        _shimmerAnimation.value * 0.5,
                        _shimmerAnimation.value * 0.5 + 0.2,
                        1.0,
                      ].map((e) => e.clamp(0.0, 1.0)).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder with enhanced shimmer
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Container(
                      width: double.infinity,
                      height: 12.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.w),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xFFE0E0E0),
                            const Color(0xFFF5F5F5),
                            const Color(0xFFFFFFFF),
                            const Color(0xFFF5F5F5),
                            const Color(0xFFE0E0E0),
                          ],
                          stops: [
                            0.0,
                            _shimmerAnimation.value * 0.5 - 0.15,
                            _shimmerAnimation.value * 0.5,
                            _shimmerAnimation.value * 0.5 + 0.15,
                            1.0,
                          ].map((e) => e.clamp(0.0, 1.0)).toList(),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 6.h),
                // Subtitle placeholder with enhanced shimmer
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 100.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.w),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xFFE0E0E0),
                            const Color(0xFFF5F5F5),
                            const Color(0xFFFFFFFF),
                            const Color(0xFFF5F5F5),
                            const Color(0xFFE0E0E0),
                          ],
                          stops: [
                            0.0,
                            _shimmerAnimation.value * 0.5 - 0.15,
                            _shimmerAnimation.value * 0.5,
                            _shimmerAnimation.value * 0.5 + 0.15,
                            1.0,
                          ].map((e) => e.clamp(0.0, 1.0)).toList(),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8.h),
                // Price placeholder with enhanced shimmer (golden tint)
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 60.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.w),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.primaryColor.withOpacity(0.2),
                            AppColors.primaryColor.withOpacity(0.3),
                            AppColors.primaryColor.withOpacity(0.5),
                            AppColors.primaryColor.withOpacity(0.3),
                            AppColors.primaryColor.withOpacity(0.2),
                          ],
                          stops: [
                            0.0,
                            _shimmerAnimation.value * 0.5 - 0.15,
                            _shimmerAnimation.value * 0.5,
                            _shimmerAnimation.value * 0.5 + 0.15,
                            1.0,
                          ].map((e) => e.clamp(0.0, 1.0)).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal list of skeleton cards
class HorizontalSkeletonList extends StatelessWidget {
  final int count;

  const HorizontalSkeletonList({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: count,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: const ProductCardSkeleton(),
          );
        },
      ),
    );
  }
}
