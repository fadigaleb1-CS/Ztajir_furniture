import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/routes/app_route.dart';
import 'package:ztajir_furniture/core/utiles/snack_bar_helper.dart';
import 'package:ztajir_furniture/presentation/view_model/auth_provider.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/auth_card.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/auth_profile.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/custom_text_field.dart';
import 'package:ztajir_furniture/presentation/views/widgets/primary_button.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/social_button.dart';

import 'package:ztajir_furniture/core/utiles/size_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  double sizedBoxHight = 15.h;
  bool _agreePrivacy = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    var loc = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      if (!_agreePrivacy) {
        SnackBarHelper.show(
          context: context,
          message: loc.translate('privacy_required'),
          backgroundColor: AppColors.redColor,
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        SnackBarHelper.show(
          context: context,
          message: loc.translate('register_success'),
          backgroundColor: AppColors.primaryColor,
        );

        if (authProvider.isAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.main,
            (route) => false,
          );
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        }
      } else {
        SnackBarHelper.show(
          context: context,
          message: authProvider.error ?? 'Error registering',
          backgroundColor: AppColors.redColor,
        );
      }
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
              //  Header
              Column(
                children: [
                  AuthProfile(icon: Icons.person_add_alt_1, size: 70.w),
                  SizedBox(height: 10.h),
                  Text(
                    loc.translate('register_title'),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    loc.translate('register_subtitle'),
                    style: TextStyle(
                      fontSize: 14.sp,
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
                      // الاسم الأول
                      CustomTextField(
                        controller: _firstNameController,
                        hintText: loc.translate('first_name'),
                        labelText: loc.translate('first_name'),
                        icon: Icons.person,
                        validator: (value) => value == null || value.isEmpty
                            ? loc.translate('required')
                            : null,
                      ),

                      SizedBox(height: sizedBoxHight),

                      // الاسم الأخير
                      CustomTextField(
                        controller: _lastNameController,
                        hintText: loc.translate('last_name'),
                        labelText: loc.translate('last_name'),
                        icon: Icons.person,
                        validator: (value) => value == null || value.isEmpty
                            ? loc.translate('required')
                            : null,
                      ),

                      SizedBox(height: sizedBoxHight),

                      CustomTextField(
                        controller: _emailController,
                        hintText: loc.translate('email_hint'),
                        labelText: loc.translate('email_label'),
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || !value.contains("@")) {
                            return loc.translate('enter_valid_email');
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: sizedBoxHight),

                      CustomTextField(
                        controller: _phoneController,
                        hintText: loc.translate('phone_label'),
                        labelText: loc.translate('phone_label'),
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.length < 9) {
                            return loc.translate('enter_valid_phone');
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: sizedBoxHight),

                      CustomTextField(
                        controller: _passwordController,
                        hintText: loc.translate('password_hint'),
                        labelText: loc.translate('password_label'),
                        icon: Icons.lock,
                        isPassword: true,
                        onChanged: (val) {
                          setState(() {});
                          if (_confirmPasswordController.text.isNotEmpty) {
                            _formKey.currentState?.validate();
                          }
                        },
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return loc.translate('password_weak');
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: sizedBoxHight),

                      CustomTextField(
                        controller: _confirmPasswordController,
                        hintText: loc.translate('confirm_password_label'),
                        labelText: loc.translate('confirm_password_label'),
                        icon: Icons.lock,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return loc.translate('reenter_password');
                          }
                          if (value != _passwordController.text) {
                            return loc.translate('password_mismatch_error');
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: sizedBoxHight),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _agreePrivacy,
                            onChanged: (val) {
                              setState(() {
                                _agreePrivacy = val ?? false;
                              });
                            },
                            activeColor: AppColors.primaryColor,
                          ),
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  loc.translate('agree_to'),
                                  style: const TextStyle(
                                    color: AppColors.darkGreyColor,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.termsPrivacyScreen,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    loc.translate('terms_and_privacy'),
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          if (auth.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return PrimaryButton(
                            text: loc.translate('register_button'),
                            onPressed: _handleRegister,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25.h),

              SizedBox(height: 25.h),

              // Social Login Section
              Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppColors.darkGreyColor),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Text(
                          loc.translate('or_continue_with'),
                          style: TextStyle(
                            color: AppColors.darkGreyColor,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppColors.darkGreyColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialButton(
                        assetPath: 'assets/icons/google.svg',
                        onTap: () {
                          // Placeholder for Google Login Logic
                        },
                      ),
                      SizedBox(width: 20.w),
                      SocialButton(
                        assetPath: 'assets/icons/facebook.svg',
                        onTap: () {
                          // Placeholder for Facebook Login Logic
                        },
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              //  Login Redirect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loc.translate('already_have_account'),
                    style: const TextStyle(color: AppColors.darkGreyColor),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.loginScreen,
                      );
                    },
                    child: Text(
                      loc.translate('login_button'),
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
