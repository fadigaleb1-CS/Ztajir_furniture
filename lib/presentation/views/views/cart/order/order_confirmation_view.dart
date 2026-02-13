import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/routes/app_route.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/core/utiles/price_formatter.dart';
import 'package:ztajir_furniture/presentation/views/widgets/primary_button.dart';
import 'package:ztajir_furniture/data/models/order_model.dart';
import 'package:ztajir_furniture/core/services/pdf_invoice_service.dart';

class OrderConfirmationView extends StatelessWidget {
  final OrderModel orderData;

  const OrderConfirmationView({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // ============ أيقونة النجاح ============
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: AppColors.greenColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.greenColor,
                  size: 60.w,
                ),
              ),

              SizedBox(height: 20.h),

              // ============ عنوان النجاح ============
              Text(
                loc.translate('order_success'),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                loc.translate('order_success_message'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.darkGreyColor,
                ),
              ),

              SizedBox(height: 30.h),

              // ============ بطاقة الفاتورة ============
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10.w,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // رأس الفاتورة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.translate('invoice'),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greenColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.w),
                          ),
                          child: Text(
                            loc.translate(
                              'paid',
                            ), // أو استخدام orderData.status
                            style: TextStyle(
                              color: AppColors.greenColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Divider(height: 30.h),

                    // معلومات الطلب
                    _buildInfoRow(
                      loc.translate('order_number'),
                      orderData.orderNumber,
                    ),
                    SizedBox(height: 12.h),
                    _buildInfoRow(
                      loc.translate('order_date'),
                      _formatDate(orderData.createdAt),
                    ),
                    SizedBox(height: 12.h),
                    _buildInfoRow(
                      loc.translate('payment_method'),
                      getPaymentMethodDisplayName(orderData.paymentMethod),
                    ),

                    Divider(height: 30.h),

                    // ============ المنتجات ============
                    Text(
                      loc.translate('order_items'),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    ...orderData.items.map((item) => _buildItemRow(item)),

                    Divider(height: 30.h),

                    // ============ ملخص الأسعار ============
                    _buildPriceRow(
                      loc.translate('subtotal'),
                      '${formatPrice(orderData.subTotal)} ${orderData.currency}',
                      isGrey: true,
                    ),

                    if (orderData.discount > 0) ...[
                      SizedBox(height: 8.h),
                      _buildPriceRow(
                        loc.translate('discount'),
                        '- ${formatPrice(orderData.discount)} ${orderData.currency}',
                        isGreen: true,
                      ),
                    ],

                    if (orderData.shippingCost > 0) ...[
                      SizedBox(height: 8.h),
                      _buildPriceRow(
                        loc.translate('shipping_fee') ?? 'رسوم الشحن',
                        '${formatPrice(orderData.shippingCost)} ${orderData.currency}',
                      ),
                    ],

                    if (orderData.tax > 0) ...[
                      SizedBox(height: 8.h),
                      _buildPriceRow(
                        loc.translate('tax') ?? 'الضريبة',
                        '${formatPrice(orderData.tax)} ${orderData.currency}',
                      ),
                    ],

                    SizedBox(height: 12.h),
                    Divider(),
                    SizedBox(height: 12.h),

                    _buildPriceRow(
                      loc.translate('total'),
                      '${formatPrice(orderData.total)} ${orderData.currency}',
                      isBold: true,
                      isPrimary: true,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // ============ أزرار الإجراءات ============

              // زر تحميل الفاتورة (مؤجل حالياً)
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await PdfInvoiceService.generateAndSaveInvoice(orderData);
                    } catch (e) {
                      debugPrint('Error generating PDF: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('فشل تجهيز الفاتورة: $e')),
                        );
                      }
                    }
                  },
                  icon: Icon(
                    Icons.download_rounded,
                    color: AppColors.primaryColor,
                  ),
                  label: Text(
                    loc.translate('download_invoice'),
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: PrimaryButton(
                  text: loc.translate('continue_shopping'),
                  onPressed: () {
                    // العودة للصفحة الرئيسية
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
                  },
                ),
              ),

              SizedBox(height: 12.h),

              TextButton(
                onPressed: () {
                  // الانتقال إلى شاشة الطلبات
                  Navigator.pushNamed(context, AppRoutes.orderScreenState);
                },
                child: Text(
                  loc.translate('view_orders'),
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.darkGreyColor, fontSize: 13.sp),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          // صورة المنتج
          ClipRRect(
            borderRadius: BorderRadius.circular(8.w),
            child: item.productImage != null
                ? Image.network(
                    item.productImage!,
                    width: 50.w,
                    height: 50.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 50.w,
                      height: 50.w,
                      color: AppColors.darkGreyColor,
                      child: Icon(Icons.image, color: AppColors.darkGreyColor),
                    ),
                  )
                : Container(
                    width: 50.w,
                    height: 50.w,
                    color: AppColors.darkGreyColor,
                    child: Icon(Icons.image, color: AppColors.darkGreyColor),
                  ),
          ),
          SizedBox(width: 12.w),

          // تفاصيل المنتج
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${formatPrice(item.price)} YER × ${item.quantity}',
                  style: TextStyle(
                    color: AppColors.darkGreyColor,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),

          // السعر الإجمالي
          Text(
            '${formatPrice(item.total)} YER',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isGrey = false,
    bool isGreen = false,
    bool isBold = false,
    bool isPrimary = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isGreen
                ? AppColors.greenColor
                : (isGrey ? AppColors.darkGreyColor : AppColors.textColor),
            fontSize: isBold ? 16.sp : 13.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isGreen
                ? AppColors.greenColor
                : (isPrimary ? AppColors.primaryColor : AppColors.textColor),
            fontSize: isBold ? 18.sp : 13.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
