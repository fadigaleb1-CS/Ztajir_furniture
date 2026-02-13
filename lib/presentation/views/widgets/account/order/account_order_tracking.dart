import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class OrderTrackingSheet extends StatelessWidget {
  final String status;
  final String orderId;
  const OrderTrackingSheet({
    super.key,
    required this.status,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(25.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط السحب العلوي
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.darkGreyColor,
              borderRadius: BorderRadius.circular(10.w),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "تتبع الطلب #$orderId",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30.h),
          ..._getTrackingSteps(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  List<Widget> _getTrackingSteps() {
    // 1. حالة الطلب الملغي
    if (status == "ملغي") {
      return [
        _buildStep("تم استلام الطلب", "نأسف، تم إلغاء هذا الطلب", true),
        _buildStep(
          "طلب ملغي",
          "تم الإلغاء بنجاح",
          true,
          isLast: true,
          color: AppColors.redColor,
        ),
      ];
    }

    // 2. حالة الطلب المكتمل (تم التوصيل) - تظهر باللون الأخضر
    if (status == "تم التوصيل") {
      return [
        _buildStep(
          "تم استلام الطلب",
          "20 ديسمبر 2025",
          true,
          color: AppColors.greenColor,
        ),
        _buildStep(
          "قيد التجهيز",
          "تم تجهيز الأثاث",
          true,
          color: AppColors.greenColor,
        ),
        _buildStep(
          "تم التوصيل",
          "وصلت الشحنة بنجاح",
          true,
          isLast: true,
          color: AppColors.greenColor,
        ),
      ];
    }

    // 3. الحالة الافتراضية (نشط / قيد التنفيذ)
    return [
      _buildStep("تم استلام الطلب", "طلبك قيد المراجعة", true),
      _buildStep("قيد التجهيز", "يتم تحضير منتجاتك", true),
      _buildStep("في الطريق إليك", "بانتظار خروج المندوب", false, isLast: true),
    ];
  }

  Widget _buildStep(
    String title,
    String subtitle,
    bool isDone, {
    bool isLast = false,
    Color? color,
  }) {
    // تحديد اللون: إذا اكتملت الخطوة نستخدم اللون الممرر (مثل الأخضر للمكتمل) أو اللون الأساسي للتطبيق
    final activeColor = color ?? AppColors.primaryColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            // تغيير الأيقونة بناءً على حالة الإتمام واللون
            Icon(
              isDone
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: isDone ? activeColor : Colors.grey[300],
              size: 24.w,
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 40.h,
                color: isDone ? activeColor.withOpacity(0.5) : Colors.grey[200],
              ),
          ],
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15.sp,
                  color: isDone && status == "تم التوصيل"
                      ? AppColors.greenColor
                      : AppColors.blackColor,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.darkGreyColor,
                ),
              ),
              if (!isLast) SizedBox(height: 10.h),
            ],
          ),
        ),
      ],
    );
  }
}
