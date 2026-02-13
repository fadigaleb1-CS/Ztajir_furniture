import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/utiles/snack_bar_helper.dart';
import 'package:ztajir_furniture/data/models/coupon_model.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final AppLocalizations loc;

  const CouponCard({super.key, required this.coupon, required this.loc});

  @override
  Widget build(BuildContext context) {
    bool isExpired = !coupon.isValid;
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.05),
            blurRadius: 10.w,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.w),
        child: Row(
          children: [
            // Left Side (Visual)
            Container(
              width: 100.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: isExpired
                    ? AppColors.darkGreyColor
                    : AppColors.primaryColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(coupon.discountPercentage * 100).toInt()}%',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'OFF',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Right Side (Details)
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.code,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: isExpired
                            ? AppColors.darkGreyColor
                            : theme.textTheme.titleMedium?.color,
                        letterSpacing: 1.5.w,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      coupon.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.6,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${loc.translate('valid_until')} ${coupon.expiryDate.toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: isExpired
                                ? AppColors.redColor
                                : AppColors.darkGreyColor,
                          ),
                        ),
                        if (!isExpired)
                          InkWell(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: coupon.code),
                              );
                              SnackBarHelper.show(
                                context: context,
                                message: loc.translate('code_copied'),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.copy,
                                  size: 14.w,
                                  color: AppColors.primaryColor,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  loc.translate('copy_code'),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
