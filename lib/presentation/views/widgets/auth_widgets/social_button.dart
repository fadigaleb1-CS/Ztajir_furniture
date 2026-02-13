import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class SocialButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;
  final double? size;
  final Color? backgroundColor;

  const SocialButton({
    Key? key,
    required this.assetPath,
    required this.onTap,
    this.size,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.whiteColor,
      shape: const CircleBorder(),
      elevation: 3, // Increased elevation for protrusion
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.darkGreyColor),
          ),
          child: SvgPicture.asset(
            assetPath,
            width: size ?? 24.w,
            height: size ?? 24.w,
          ),
        ),
      ),
    );
  }
}
