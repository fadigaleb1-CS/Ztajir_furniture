import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/data/models/address_model.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const AddressCard({
    super.key,
    required this.address,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasCoords = address.lat != 0.0;
    final loc = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(15.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withValues(alpha: 0.05),
              blurRadius: 10.w,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Icon(
                hasCoords ? Icons.map_rounded : Icons.edit_location_alt_rounded,
                color: AppColors.primaryColor,
                size: 24.w,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    address.details,
                    style: TextStyle(
                      color: AppColors.darkGreyColor,
                      fontSize: 12.sp,
                    ),
                  ),
                  if (hasCoords) ...[
                    SizedBox(height: 4.h),
                    Text(
                      loc.translate('tap_to_view_map'),
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.redColor),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
