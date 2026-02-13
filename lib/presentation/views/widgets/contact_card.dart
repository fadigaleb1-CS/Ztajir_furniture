import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class ContactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? svgPath;
  final Color color;
  final VoidCallback onTap;

  const ContactCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.svgPath,
    required this.color,
    required this.onTap,
  }) : assert(
         icon != null || svgPath != null,
         'Either icon or svgPath must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25.w),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25.w),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.w),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (svgPath != null)
                  SvgPicture.asset(
                    svgPath!,
                    color: color,
                    width: 35.w,
                    height: 35.w,
                  )
                else
                  Icon(icon, color: color, size: 35.w),
                SizedBox(height: 15.h),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
