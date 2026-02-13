import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/views/widgets/primary_button.dart';

/// شاشة عدم وجود اتصال بالإنترنت
class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة عدم الاتصال
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackColor.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 64.w,
                  color: AppColors.primaryColor,
                ),
              ),

              SizedBox(height: 32.h),

              // العنوان
              Text(
                loc.translate('no_internet_title'),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12.h),

              // الوصف
              Text(
                loc.translate('no_internet_message'),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.darkGreyColor,
                  height: 1.5,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 48.h),

              // زر إعادة المحاولة
              PrimaryButton(
                text: loc.translate('retry'),
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
