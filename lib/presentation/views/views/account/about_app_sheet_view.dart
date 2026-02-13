import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/auth_profile.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/title_text.dart';
import 'package:ztajir_furniture/presentation/views/widgets/quick_action_item.dart';
import 'package:ztajir_furniture/presentation/views/widgets/social_media_button.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class AboutAppSheet extends StatelessWidget {
  const AboutAppSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparentColor,
      builder: (context) => const AboutAppSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: SizeConfig.screenHeight * 0.85),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40.w)),
        ),
        child: Stack(
          children: [
            // Top Gradient Background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0.15),
                      AppColors.secondaryColor.withOpacity(0.15),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(40.w),
                  ),
                ),
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.h),
                // Drag Handle
                Container(
                  width: 50.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: AppColors.darkGreyColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      children: [
                        // Header Section
                        Column(
                          children: [
                            AuthProfile(icon: Icons.chair_rounded, size: 60.w),
                            SizedBox(height: 15.h),
                            TitleText(title: loc.translate('app_name_ar')),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.w),
                              ),
                              child: Text(
                                "Version 1.0.0",
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 30.h),

                        // Vision Section
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(25.w),
                          ),
                          child: Column(
                            children: [
                              Text(
                                loc.translate('our_vision'),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                loc.translate('vision_content'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  height: 1.6,
                                  color: AppColors.blackColor.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 25.h),

                        // Quick Actions Section
                        Row(
                          children: [
                            QuickActionItem(
                              icon: Icons.language_rounded,
                              label: loc.translate('our_website'),
                              color: Colors.blue,
                            ),
                            SizedBox(width: 12.w),
                            QuickActionItem(
                              icon: Icons.privacy_tip_outlined,
                              label: loc.translate('privacy'),
                              color: Colors.orange,
                            ),
                            SizedBox(width: 12.w),
                            QuickActionItem(
                              icon: Icons.star_rate_rounded,
                              label: loc.translate('rate_us'),
                              color: Colors.amber,
                            ),
                          ],
                        ),

                        SizedBox(height: 25.h),

                        // Footer Section
                        Column(
                          children: [
                            Text(
                              loc.translate('follow_us'),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreyColor,
                              ),
                            ),
                            SizedBox(height: 15.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SocialMediaButton(
                                  svgPath: 'assets/icons/facebook.svg',
                                  color: const Color(0xFF1877F2),
                                ),
                                SocialMediaButton(
                                  svgPath: 'assets/icons/instagram.svg',
                                  color: const Color(0xFFC13584),
                                ),
                                SocialMediaButton(
                                  icon: Icons.email_rounded,
                                  color: AppColors.redColor,
                                ),
                                SocialMediaButton(
                                  svgPath: 'assets/icons/whatsapp.svg',
                                  color: AppColors.greenColor,
                                ),
                              ],
                            ),
                            SizedBox(height: 30.h),
                            Text(
                              loc.translate('made_with_love'),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.darkGreyColor,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
