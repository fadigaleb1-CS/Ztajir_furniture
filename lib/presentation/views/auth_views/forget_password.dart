import 'package:flutter/material.dart'; // استيراد عناصر الواجهة // استيراد مكتبة GetX للتنقل
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/routes/app_route.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/auth_card.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/auth_profile.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/custom_text_field.dart';
import 'package:ztajir_furniture/presentation/views/widgets/primary_button.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetCode() {
    var loc = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('code_sent_success')),
          backgroundColor: AppColors.primaryColor,
        ),
      );
      Navigator.pushNamed(context, AppRoutes.verificationScreen);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //  Header
              Column(
                children: [
                  AuthProfile(icon: Icons.lock_reset, size: 70.w),

                  SizedBox(height: 15.h),

                  Text(
                    loc.translate('forgot_password_title'),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  Text(
                    loc.translate('forgot_password_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.darkGreyColor,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 25.h),

              //  Card
              AuthCard(
                chiled: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        hintText: loc.translate('email_hint'),
                        labelText: loc.translate('email_label'),
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              !value.contains('@') ||
                              value.isEmpty) {
                            return loc.translate('enter_valid_email_short');
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 25.h),

                      PrimaryButton(
                        text: loc.translate('send_code_button'),
                        onPressed: _sendResetCode,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25.h),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                child: Text(
                  loc.translate('back_to_login'),
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
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
