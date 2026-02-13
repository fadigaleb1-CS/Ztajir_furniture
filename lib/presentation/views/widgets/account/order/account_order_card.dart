import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/data/models/product_model.dart';
import 'package:ztajir_furniture/presentation/views/views/product_detail.dart';
import 'package:ztajir_furniture/presentation/views/widgets/account/order/account_order_tracking.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

// 1. استخدام Extension للتعامل مع منطق الألوان بناءً على الحالة
extension OrderStatusX on String {
  Color get statusColor {
    switch (this) {
      case "قيد التنفيذ":
        return AppColors.primaryColor;
      case "تم التوصيل":
        return AppColors.greenColor;
      case "ملغي":
        return AppColors.redColor;
      default:
        return AppColors.darkGreyColor;
    }
  }
}

class OrderCard extends StatelessWidget {
  final ProductModel product;
  final String status;

  const OrderCard({super.key, required this.product, required this.status});

  @override
  Widget build(BuildContext context) {
    // تجهيز البيانات الأساسية
    final String orderId = "ZT-${1000 + product.id}";
    final Color statusColor =
        status.statusColor; // نعتمد على الـ Extension الذي أنشأناه سابقاً

    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20.w,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // القسم العلوي: الصورة والمعلومات
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. صورة المنتج
              Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(18.w),
                  image: DecorationImage(
                    image: AssetImage(product.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              // 2. تفاصيل المنتج
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${AppLocalizations.of(context)!.translate('order_number')}$orderId",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.darkGreyColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // حالة الطلب (Badge) مصممة مباشرة هنا
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      product.describtion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // السعر والتاريخ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${product.price} ${AppLocalizations.of(context)!.translate('currency')}",
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 18.sp,
                          ),
                        ),
                        Text(
                          "25 ديسمبر 2025",
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0.h),
            child: Divider(height: 1.h, color: const Color(0xFFF1F1F1)),
          ),

          // القسم السفلي: الأزرار
          Row(
            children: [
              // زر تتبع الطلب
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showTracking(context, orderId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.whiteColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.translate('track_order'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // زر التفاصيل
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.primaryColor.withOpacity(0.2),
                    ),
                    foregroundColor: AppColors.textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.translate('details'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // دالة عرض التتبع بقيت مستقلة لأنها تفتح واجهة جديدة (BottomSheet)
  void _showTracking(BuildContext context, String orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.w)),
      ),
      builder: (_) => OrderTrackingSheet(status: status, orderId: orderId),
    );
  }
}
