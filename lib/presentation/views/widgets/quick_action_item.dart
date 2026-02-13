import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const QuickActionItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20.w),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26.w),
            // Changed from const SizedBox(height: 8) to SizedBox(height: 8.h)
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
