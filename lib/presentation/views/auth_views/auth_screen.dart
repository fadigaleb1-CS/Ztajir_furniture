// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
// import 'package:get_x/get.dart'; // تم حذف هذا الاستيراد لأنه غير مستخدم هنا ويسبب خطأ (GetX/Get.dart)

import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/routes/app_route.dart';
import 'package:ztajir_furniture/presentation/views/widgets/app_button_text.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/auth_card.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/auth_profile.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({Key? key}) : super(key: key);

  double buttonHeight = 50.h;
  double buttonWidth = double.infinity;

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
            child: Column(
              children: [
                AuthProfile(icon: Icons.chair, size: 100.w), // Header
                SizedBox(height: 25.h),
                Text(
                  loc.translate('auth_welcome_title'),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  loc.translate('auth_welcome_subtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
                SizedBox(height: 40.h),

                //  Card Buttons
                AuthCard(
                  chiled: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(buttonWidth, buttonHeight),
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                        ),
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.loginScreen,
                        ),
                        child: AppButtonText(
                          text: loc.translate('login_button'),
                          color: AppColors.secondaryColor,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(buttonWidth, buttonHeight),
                          side: BorderSide(color: AppColors.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                        ),
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.registerScreen,
                        ),
                        child: AppButtonText(
                          text: loc.translate('register_button'),
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25.h),

                //  Login as Guest Button
                TextButton.icon(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.main),
                  icon: Icon(
                    Icons.person_outline,
                    color: AppColors.darkGreyColor,
                    size: 24.sp,
                  ),
                  label: Text(
                    loc.translate('login_as_guest'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreyColor,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
