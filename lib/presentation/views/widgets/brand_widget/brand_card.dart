// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class brand_card extends StatelessWidget {
  const brand_card({
    super.key,
    required this.image,
    required this.name,
    this.onTap,
  });

  final String? image;
  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withValues(alpha: 0.10),
              blurRadius: 8.w,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.w),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // صورة العلامة التجارية
              (image == null || image!.isEmpty)
                  ? Container(
                      width: double.infinity,
                      height: 120.h,
                      color: AppColors.darkGreyColor,
                      child: Icon(
                        Icons.store,
                        size: 40.w,
                        color: AppColors.darkGreyColor,
                      ),
                    )
                  : Image.network(
                      image!,
                      width: double.infinity,
                      height: 120.h,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return _BrandShimmer();
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 120.h,
                        color: AppColors.darkGreyColor,
                        child: Icon(
                          Icons.store,
                          size: 40.w,
                          color: AppColors.darkGreyColor,
                        ),
                      ),
                    ),

              // Gradient
              Container(
                height: 45.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.blackColor.withValues(alpha: 0.55),
                      AppColors.transparentColor,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              // اسم العلامة
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  name,
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Brand Shimmer Loading
class _BrandShimmer extends StatefulWidget {
  const _BrandShimmer();

  @override
  State<_BrandShimmer> createState() => __BrandShimmerState();
}

class __BrandShimmerState extends State<_BrandShimmer>
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
          width: double.infinity,
          height: 120.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFDDDDDD), // رمادي متوسط
                Color(0xFFEEEEEE), // رمادي فاتح
                Color(0xFFFFFFFF), // أبيض ناصع (لمعان)
                Color(0xFFEEEEEE), // رمادي فاتح
                Color(0xFFDDDDDD), // رمادي متوسط
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
