import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class SocialMediaButton extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final Color color;
  final VoidCallback? onTap;

  const SocialMediaButton({
    super.key,
    this.icon,
    this.svgPath,
    required this.color,
    this.onTap,
  }) : assert(
         icon != null || svgPath != null,
         'Either icon or svgPath must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreyColor.withOpacity(0.05),
            blurRadius: 10.w,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(50.w),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: svgPath != null
                ? SvgPicture.asset(
                    svgPath!,
                    width: 22.w,
                    height: 22.w,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  )
                : Icon(icon, color: color, size: 22.w),
          ),
        ),
      ),
    );
  }
}
