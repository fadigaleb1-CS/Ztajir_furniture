// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/routes/app_route.dart';
import 'package:ztajir_furniture/core/utiles/snack_bar_helper.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/auth_card.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/auth_profile.dart';
import 'package:ztajir_furniture/presentation/views/widgets/primary_button.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  /// مسح جميع خانات الـ OTP
  void _clearOtpFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    // إعادة التركيز للخانة الأولى
    _focusNodes[0].requestFocus();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _verifyCode() {
    final code = _controllers.map((e) => e.text).join();
    final loc = AppLocalizations.of(context)!;

    if (code.length < 6) {
      SnackBarHelper.show(
        context: context,
        message: loc.translate('enter_full_code'),
      );
      return;
    }

    // Checking logic here (API)
    SnackBarHelper.show(
      context: context,
      message: loc.translate('code_verified_success'),
    );
    Navigator.pushReplacementNamed(context, AppRoutes.resetPasswordScreen);
  }

  void _onDigitChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
    } else {
      if (index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          child: Column(
            children: [
              _VerificationHeader(
                title: loc.translate('verification_title'),
                subtitle: loc.translate('verification_subtitle'),
                email: "exam***@email.com",
              ),
              SizedBox(height: 30.h),
              AuthCard(
                chiled: Column(
                  children: [
                    _OtpInputRow(
                      controllers: _controllers,
                      focusNodes: _focusNodes,
                      onChanged: _onDigitChanged,
                    ),
                    SizedBox(height: 30.h),
                    PrimaryButton(
                      text: loc.translate('verify_button'),
                      onPressed: _verifyCode,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25.h),
              _ResendCodeSection(
                infoText: loc.translate('resend_code_text'),
                buttonText: loc.translate('resend_button'),
                onResend: () {
                  // مسح الخانات عند إعادة الإرسال
                  _clearOtpFields();
                  SnackBarHelper.show(
                    context: context,
                    message: loc.translate('code_resent_success'),
                    backgroundColor: AppColors.primaryColor,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerificationHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String email;

  const _VerificationHeader({
    required this.title,
    required this.subtitle,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthProfile(icon: Icons.mark_email_read, size: 70.w),
        SizedBox(height: 20.h),
        Text(
          title,
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
        SizedBox(height: 10.h),
        Text(
          email,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}

class _OtpInputRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(String, int) onChanged;

  const _OtpInputRow({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _OtpDigitField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              onChanged: (val) => onChanged(val, index),
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpDigitField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpDigitField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // مربع
      child: LayoutBuilder(
        builder: (context, constraints) {
          // حجم الخط يعتمد على حجم الخانة (40% من العرض)
          final fontSize = constraints.maxWidth * 0.45;

          return Container(
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(10.w),
              border: Border.all(
                color: AppColors.darkGreyColor.withOpacity(0.5),
                width: 1.5.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Center(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                  height: 1.2,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: onChanged,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResendCodeSection extends StatelessWidget {
  final String infoText;
  final String buttonText;
  final VoidCallback onResend;

  const _ResendCodeSection({
    required this.infoText,
    required this.buttonText,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(infoText, style: TextStyle(color: AppColors.darkGreyColor)),
        TextButton(
          onPressed: onResend,
          child: Text(
            buttonText,
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
