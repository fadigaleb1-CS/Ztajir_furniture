import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/services/pdf_invoice_service.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/core/utiles/price_formatter.dart';

import 'package:ztajir_furniture/data/models/order_model.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';

class OrderDetailsView extends StatelessWidget {
  final OrderModel orderData;

  const OrderDetailsView({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    final statusInfo = _getOrderStatus(context, orderData.status);

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: StaticAppBar(
        appBarName: '${loc.translate('order_number')} ${orderData.orderCode}',
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.whiteColor,
            size: 20.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // ============ بطاقة الفاتورة ============
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(16.w),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackColor.withOpacity(0.05),
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
                          color: statusInfo.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.w),
                        ),
                        child: Text(
                          statusInfo.text,
                          style: TextStyle(
                            color: statusInfo.color,
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
                    orderData.orderCode,
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

            // ============ زر تحميل الفاتورة (معطل حالياً) ============
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
                        SnackBar(content: Text('فشل تحميل الفاتورة: $e')),
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
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.darkGreyColor, fontSize: 13.sp),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
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
                      color: AppColors.darkGreyColor.withOpacity(0.2),
                      child: Icon(Icons.image, color: AppColors.darkGreyColor),
                    ),
                  )
                : Container(
                    width: 50.w,
                    height: 50.w,
                    color: AppColors.darkGreyColor.withOpacity(0.2),
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

  _StatusInfo _getOrderStatus(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _StatusInfo("قيد الانتظار", Colors.orange);
      case 'processing':
        return _StatusInfo("قيد التنفيذ", Colors.blue);
      case 'shipped':
        return _StatusInfo("تم الشحن", Colors.purple);
      case 'delivered':
      case 'completed':
        return _StatusInfo("تم التوصيل", Colors.green);
      case 'cancelled':
        return _StatusInfo("ملغي", Colors.red);
      default:
        return _StatusInfo(status, Colors.grey);
    }
  }
}

class _StatusInfo {
  final String text;
  final Color color;

  _StatusInfo(this.text, this.color);
}
