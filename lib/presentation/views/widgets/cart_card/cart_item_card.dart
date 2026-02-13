// presentation/widgets/cart_card/cart_item_card.dart

import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/core/utiles/price_formatter.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/data/models/cart_item_model.dart';
import 'package:ztajir_furniture/presentation/view_model/cart_service.dart';
import 'package:ztajir_furniture/presentation/views/widgets/build_quantity_button.dart';
import 'package:ztajir_furniture/presentation/views/widgets/custom_confirmation_dialog.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onQuantityChanged;
  final Function(String) onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  void _handleQuantityChange(BuildContext context, int delta) {
    final service = Provider.of<CartService>(context, listen: false);

    int newQuantity = item.quantity + delta;

    if (newQuantity <= 0) {
      // إذا كانت الكمية الجديدة 0 أو أقل، نطلب تأكيد الحذف
      onRemove(item.id);
      return;
    }

    // هنا نستخدم دالة التحديث (Update)
    // إذا كان السيرفر يدعم PUT، فهذا هو الأفضل.
    // إذا لم يدعم، سنرى Error في اللوج، وسنحتاج للعودة للحلول الالتفافية.
    service.updateItemQuantity(item.id, newQuantity);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreyColor.withOpacity(0.1),
            blurRadius: 8.w,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12.w),
            child: (item.image.startsWith('http'))
                ? Image.network(
                    item.image,
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80.w,
                        height: 80.w,
                        color: AppColors.darkGreyColor,
                        child: Icon(
                          Icons.broken_image,
                          color: AppColors.darkGreyColor,
                          size: 30.w,
                        ),
                      );
                    },
                  )
                : Image.asset(
                    item.image,
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80.w,
                        height: 80.w,
                        color: AppColors.darkGreyColor,
                        child: Icon(
                          Icons.broken_image,
                          color: AppColors.darkGreyColor,
                          size: 30.w,
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(width: 12.w),

          // 2. Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "${formatPrice(item.price)} ${item.currency}",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),

                // 3. Quantity Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BuildQuantityButton(
                      icon: Icons.remove,
                      onPressed: () => _handleQuantityChange(context, -1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        item.quantity.toString(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    BuildQuantityButton(
                      icon: Icons.add,
                      onPressed: () => _handleQuantityChange(context, 1),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 4. Delete Button with Confirmation
          InkWell(
            onTap: () async {
              final shouldRemove = await CustomConfirmationDialog.show(
                context: context,
                title: loc.translate('remove_cart_item_title'),
                content: loc.translate('remove_cart_item_confirm'),
                confirmText: loc.translate('delete'),
                cancelText: loc.translate('cancel'),
                icon: Icons.delete_outline,
                confirmColor: AppColors.redColor,
                iconColor: AppColors.redColor,
              );

              if (shouldRemove) {
                CartService().removeAllOfItem(item.id);
              }
            },
            child: Padding(
              padding: EdgeInsets.only(top: 4.h, left: 4.w),
              child: Icon(
                Icons.delete_outline,
                color: AppColors.redColor,
                size: 24.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
