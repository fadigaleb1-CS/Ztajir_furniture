import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class CustomConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final Color? confirmColor;
  final Color? iconColor;

  const CustomConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.cancelText,
    this.icon = Icons.warning_amber_rounded,
    this.confirmColor,
    this.iconColor,
  });

  /// Shows the confirmation dialog and returns true if confirmed, false otherwise.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    IconData icon = Icons.warning_amber_rounded,
    Color? confirmColor,
    Color? iconColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CustomConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        confirmColor: confirmColor,
        iconColor: iconColor,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.secondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.w)),
      title: Icon(icon, color: iconColor ?? AppColors.primaryColor, size: 40.w),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.h),
          Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp),
          ),
        ],
      ),
      actionsPadding: EdgeInsets.only(bottom: 20.h, left: 20.w, right: 20.w),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                ),
                child: Text(
                  cancelText,
                  style: TextStyle(color: Colors.black, fontSize: 14.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor ?? AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                ),
                child: Text(
                  confirmText,
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
