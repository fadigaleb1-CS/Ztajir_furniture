// core/utils/snackbar_helper.dart

import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

// يجب أن يكون هذا الكلاس خالياً من الحالة (Stateless/Static)
class SnackBarHelper {
  // دالة ثابتة (Static) لاستدعائها مباشرة عبر SnackBarHelper.show()
  static void show({
    required BuildContext context,
    required String message,
    Color? backgroundColor, // قيمة افتراضية null, سيتم تطبيق اللون الأساسي
    int durationSeconds = 2, // قيمة افتراضية لثانية واحدة
    SnackBarAction? action, // زر اختياري
    EdgeInsetsGeometry? margin, // هامش مخصص (اختياري)
  }) {
    // إخفاء أي SnackBar سابق قبل عرض الجديد
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // حساب الهامش الافتراضي ليكون أعلى الشاشة
    final defaultMargin = EdgeInsets.only(
      bottom: 90.h, // رفع الـ SnackBar أعلى بكثير
      left: 16.w,
      right: 16.w,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          // قد تحتاج لضبط اللون إذا كان لون الخلفية فاتحاً
          style: TextStyle(color: AppColors.secondaryColor),
        ),

        backgroundColor: backgroundColor ?? AppColors.primaryColor,

        // استخدام المعاملات التي تم تمريرها أو القيم الافتراضية
        duration: Duration(seconds: durationSeconds),
        behavior: SnackBarBehavior.floating,
        action: action,
        margin: margin ?? defaultMargin,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
