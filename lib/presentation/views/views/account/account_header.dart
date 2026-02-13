import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/view_model/auth_provider.dart';
import 'package:ztajir_furniture/data/mock/mock_data.dart';
import 'package:ztajir_furniture/presentation/views/views/account/edit_profile_screen.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class AccountHeader extends StatelessWidget {
  const AccountHeader({super.key});

  ImageProvider? _getProfileImage(AuthProvider authProvider) {
    final avatarUrl =
        authProvider.user?.avatarUrl ?? MockData.currentUser.avatarUrl;
    if (avatarUrl != null) {
      if (avatarUrl.startsWith('http')) {
        return NetworkImage(avatarUrl);
      } else if (avatarUrl.startsWith('/') || avatarUrl.contains('\\')) {
        return FileImage(File(avatarUrl));
      } else {
        return AssetImage(avatarUrl);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final name = authProvider.user?.name ?? MockData.currentUser.name;
        final email = authProvider.user?.email ?? MockData.currentUser.email;
        final avatarUrl =
            authProvider.user?.avatarUrl ?? MockData.currentUser.avatarUrl;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(30.w),
            gradient: LinearGradient(
              colors: [
                AppColors.secondaryColor,
                AppColors.whiteColor.withOpacity(0.5),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.1),
                blurRadius: 25.w,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: CircleAvatar(
                      key: ValueKey(avatarUrl ?? 'no-avatar'),
                      radius: 50.w,
                      backgroundColor: AppColors.whiteColor,
                      child: CircleAvatar(
                        key: ValueKey('inner-${avatarUrl ?? 'no-avatar'}'),
                        radius: 47.w,
                        backgroundColor: AppColors.primaryColor.withOpacity(
                          0.05,
                        ),
                        backgroundImage: _getProfileImage(authProvider),
                        child: avatarUrl == null
                            ? Icon(
                                Icons.person,
                                size: 50.w,
                                color: AppColors.primaryColor,
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                name,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                email,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.darkGreyColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20.h),
              // زر تعديل الملف الشخصي بشكل عصري
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.edit_note_rounded, size: 20.w),
                label: Text(
                  AppLocalizations.of(
                    context,
                  )!.translate('edit_profile_button'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.whiteColor,
                  elevation: 4,
                  shadowColor: AppColors.primaryColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.w),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
