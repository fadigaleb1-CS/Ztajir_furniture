import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/routes/app_route.dart';
import 'package:ztajir_furniture/core/utiles/snack_bar_helper.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/auth_card.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/auth_profile.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/custom_text_field.dart';
import 'package:ztajir_furniture/presentation/views/widgets/primary_button.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    var loc = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      SnackBarHelper.show(
        context: context,
        message: loc.translate('password_reset_success'),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.loginScreen,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          child: Column(
            children: [
              // Header
              AuthProfile(icon: Icons.lock_reset, size: 70.w),
              SizedBox(height: 20.h),
              Text(
                loc.translate('reset_password_title'),
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              Text(
                loc.translate('reset_password_subtitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.darkGreyColor,
                ),
              ),

              SizedBox(height: 30.h),

              // Form Card
              AuthCard(
                chiled: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _passController,
                        hintText: loc.translate('new_password_hint'),
                        labelText: loc.translate('new_password_label'),
                        icon: Icons.lock_outline,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return loc.translate('password_weak');
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 15.h),

                      CustomTextField(
                        controller: _confirmPassController,
                        hintText: loc.translate('confirm_new_password_hint'),
                        labelText: loc.translate('confirm_new_password_label'),
                        icon: Icons.lock,
                        isPassword: true,
                        validator: (value) {
                          if (value != _passController.text) {
                            return loc.translate('password_mismatch_error');
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 25.h),

                      PrimaryButton(
                        text: loc.translate('save_password_button'),
                        onPressed: _resetPassword,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
