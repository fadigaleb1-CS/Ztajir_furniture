import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class AccountSectionCard extends StatelessWidget {
  const AccountSectionCard({super.key, required this.items});

  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.05),
            blurRadius: 25.w,
            spreadRadius: -5.w,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      // نستخدم Material هنا ليكون هو السطح الذي يظهر عليه تأثير النقر
      child: Material(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(28.w),
        clipBehavior:
            Clip.antiAlias, // لضمان قص تأثير النقر عند الزوايا المنحنية
        child: Column(children: items),
      ),
    );
  }
}
