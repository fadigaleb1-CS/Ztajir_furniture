import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class BannerCard extends StatelessWidget {
  const BannerCard({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Material(
        // ← مهم جداً لإعطاء ظل ناعم من نفس الانحناء
        elevation: 6,
        shadowColor: AppColors.blackColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16.w),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.w),
          child: Image.asset(
            imagePath,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
