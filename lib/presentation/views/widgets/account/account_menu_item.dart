import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class AccountMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showDivider;

  const AccountMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = isDestructive
        ? AppColors.redColor
        : AppColors.primaryColor;

    return Column(
      children: [
        ListTile(
          onTap: onTap,

          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
          leading: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: baseColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: baseColor, size: 22.w),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: isDestructive ? AppColors.redColor : AppColors.textColor,
            ),
          ),
          trailing: isDestructive
              ? null
              : Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.w,
                  color: AppColors.darkGreyColor,
                ),
        ),
        if (showDivider)
          Divider(
            height: 1.h,
            thickness: 0.5.h,
            indent: 70.w,
            endIndent: 20.w,
            color: AppColors.darkGreyColor.withOpacity(0.1),
          ),
      ],
    );
  }
}
