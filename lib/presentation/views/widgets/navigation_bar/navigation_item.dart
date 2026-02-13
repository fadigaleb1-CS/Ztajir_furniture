import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class NavigationItem extends StatelessWidget {
  const NavigationItem({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.icon,
    required this.index,
  });

  final int currentIndex;
  final Function(int) onTap;
  final IconData icon;
  final int index;

  @override
  Widget build(BuildContext context) {
    bool selected = index == currentIndex;

    return InkWell(
      onTap: () => onTap(index),

      borderRadius: BorderRadius.circular(50.w),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(selected ? 12.w : 10.w),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryColor.withOpacity(0.15)
              : AppColors.transparentColor,
          borderRadius: BorderRadius.circular(50.w),
        ),

        child: Icon(
          icon,
          size: selected ? 32.w : 26.w,
          color: selected ? AppColors.primaryColor : AppColors.darkGreyColor,
        ),
      ),
    );
  }
}
