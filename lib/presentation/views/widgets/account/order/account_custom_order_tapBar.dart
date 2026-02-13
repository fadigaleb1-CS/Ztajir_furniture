// 2. ويدجت منفصل للـ TabBar
import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';

import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class CustomOrderTabBar extends StatelessWidget {
  const CustomOrderTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.05),
            blurRadius: 10.w,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: AppColors.transparentColor,
          highlightColor: AppColors.transparentColor,
        ),
        child: TabBar(
          dividerColor: AppColors.transparentColor,
          splashFactory: NoSplash.splashFactory,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(12.w),
            color: AppColors.primaryColor,
          ),
          labelColor: AppColors.whiteColor,
          unselectedLabelColor: AppColors.darkGreyColor,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: AppLocalizations.of(context)!.translate('tab_active')),
            Tab(text: AppLocalizations.of(context)!.translate('tab_completed')),
            Tab(text: AppLocalizations.of(context)!.translate('tab_cancelled')),
          ],
        ),
      ),
    );
  }
}
