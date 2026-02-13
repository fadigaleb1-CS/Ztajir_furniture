import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class BuildQuantityButton extends StatelessWidget {
  const BuildQuantityButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(8.w),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
        ),
        child: Icon(icon, size: 16.w, color: AppColors.primaryColor),
      ),
    );
  }
}
