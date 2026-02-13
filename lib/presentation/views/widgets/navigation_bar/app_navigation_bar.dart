import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/presentation/views/widgets/navigation_bar/navigation_item.dart';

class AppNavigationBarBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppNavigationBarBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withOpacity(0.92), // 🔥 شبه شفاف
        borderRadius: BorderRadius.circular(28.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.12),
            blurRadius: 18.w,
            offset: Offset(0, 6.h),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NavigationItem(
            currentIndex: currentIndex,
            onTap: onTap,
            icon: Icons.home_outlined,
            index: 0,
          ),
          NavigationItem(
            currentIndex: currentIndex,
            onTap: onTap,
            icon: Icons.shopping_cart_outlined,
            index: 1,
          ),
          NavigationItem(
            currentIndex: currentIndex,
            onTap: onTap,
            icon: Icons.favorite_border,
            index: 2,
          ),
          NavigationItem(
            currentIndex: currentIndex,
            onTap: onTap,
            icon: Icons.search,
            index: 3,
          ),
          NavigationItem(
            currentIndex: currentIndex,
            onTap: onTap,
            icon: Icons.person_outline,
            index: 4,
          ),
        ],
      ),
    );
  }
}
