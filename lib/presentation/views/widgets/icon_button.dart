import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final int badgeCount;

  TopIconButton({
    required this.icon,
    required this.onTap,
    required this.size,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(35.w),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: AppColors.whiteColor, size: size),
            if (badgeCount > 0)
              Positioned(
                right: -8.w,
                top: -8.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.redColor, AppColors.redColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10.w),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.redColor.withOpacity(0.4),
                        blurRadius: 4.w,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(minWidth: 18.w, minHeight: 16.h),
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
