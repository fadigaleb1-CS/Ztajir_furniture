import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class BannerDot extends StatelessWidget {
  const BannerDot({super.key, required this.index, required this.currentIndex});

  final int currentIndex;
  final int index;

  @override
  Widget build(BuildContext context) {
    bool active = currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8.w,
      width: active ? 18.w : 8.w,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: active
            ? AppColors
                  .primaryColor // النقطة المفعّلة
            : AppColors.primaryColor.withOpacity(0.4), // غير مفعّلة شفافة
        borderRadius: BorderRadius.circular(10.w),
      ),
    );
  }
}
