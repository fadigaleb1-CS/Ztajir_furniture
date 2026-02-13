import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/routes/app_route.dart';
import 'package:ztajir_furniture/core/utiles/snack_bar_helper.dart';
import 'package:ztajir_furniture/presentation/view_model/auth_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/favorite_provider.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/auth_card.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/auth_profile.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/custom_text_field.dart';
import 'package:ztajir_furniture/presentation/views/widgets/primary_button.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/social_button.dart';

import 'package:ztajir_furniture/core/utiles/size_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadSavedCredentials() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final credentials = await authProvider.loadCredentials();
    if (credentials != null) {
      if (!mounted) return;
      _showSavedAccountSheet(credentials);
    }
  }

  void _showSavedAccountSheet(Map<String, String> credentials) {
    if (!mounted) return;
    var loc = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.w)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  margin: EdgeInsets.only(bottom: 20.h, top: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreyColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Title
              Text(
                loc.translate('saved_account_found'),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 20.h),

              // Account Card
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: AppColors.darkGreyColor,
                  borderRadius: BorderRadius.circular(15.w),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25.w,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryColor,
                        size: 28.w,
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            credentials['email']!,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "******", // Masked password hint
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.darkGreyColor,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primaryColor,
                      size: 24.w,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: BorderSide(color: AppColors.darkGreyColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                      ),
                      child: Text(
                        loc.translate('dismiss'),
                        style: TextStyle(
                          color: AppColors.darkGreyColor,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _emailController.text = credentials['email']!;
                          _passwordController.text = credentials['password']!;
                          _rememberMe = true;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                      ),
                      child: Text(
                        loc.translate('use_this_account'),
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    var loc = AppLocalizations.of(context)!;
    if (formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        // إدارة خيار تذكرني
        if (_rememberMe) {
          await authProvider.saveCredentials(
            _emailController.text,
            _passwordController.text,
          );
        } else {
          await authProvider.clearCredentials();
        }

        // إعادة تحميل المفضلة للحساب الجديد
        final favoriteProvider = Provider.of<FavoriteProvider>(
          context,
          listen: false,
        );
        await favoriteProvider.fetchFavorites();

        SnackBarHelper.show(
          context: context,
          message: loc.translate('login_success'),
          backgroundColor: AppColors.primaryColor,
        );
        // مسح كل الـ navigation stack لمنع ظهور زر الرجوع
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.main,
          (route) => false,
        );
      } else {
        // تحويل رسالة الخطأ التقنية إلى رسالة مفهومة للمستخدم
        final String userFriendlyError = _getLoginErrorMessage(
          authProvider.error,
          loc,
        );
        SnackBarHelper.show(
          context: context,
          message: userFriendlyError,
          backgroundColor: AppColors.redColor,
        );
      }
    }
  }

  /// تحويل رسائل الخطأ التقنية إلى رسائل مفهومة للمستخدم
  String _getLoginErrorMessage(String? error, AppLocalizations loc) {
    if (error == null) {
      return loc.translate('login_error_generic');
    }

    final errorLower = error.toLowerCase();

    // أخطاء بيانات الدخول
    if (errorLower.contains('401') ||
        errorLower.contains('unauthorized') ||
        errorLower.contains('invalid') ||
        errorLower.contains('credentials') ||
        errorLower.contains('password') ||
        errorLower.contains('email')) {
      return loc.translate('login_error_invalid_credentials');
    }

    // أخطاء الاتصال
    if (errorLower.contains('connection') ||
        errorLower.contains('network') ||
        errorLower.contains('socket') ||
        errorLower.contains('timeout') ||
        errorLower.contains('internet')) {
      return loc.translate('login_error_no_connection');
    }

    // خطأ عام
    return loc.translate('login_error_generic');
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              children: [
                //  Header
                Column(
                  children: [
                    AuthProfile(icon: Icons.person, size: 70.w),
                    SizedBox(height: 10.h),
                    Text(
                      loc.translate('login_welcome_title'),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      loc.translate('login_welcome_subtitle'),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.darkGreyColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30.h),

                //  Card
                AuthCard(
                  chiled: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          onTap: _loadSavedCredentials,
                          hintText: loc.translate('email_hint'),
                          labelText: loc.translate('email_label'),
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null ||
                                !value.contains("@") ||
                                value.isEmpty) {
                              return loc.translate('enter_valid_email');
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 15.h),

                        CustomTextField(
                          controller: _passwordController,
                          hintText: loc.translate('password_hint'),
                          labelText: loc.translate('password_label'),
                          icon: Icons.lock,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return loc.translate('password_min_length_error');
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 15.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.forgetPasswordScreen,
                              ),
                              child: Text(
                                loc.translate('forgot_password'),
                                style: TextStyle(color: AppColors.primaryColor),
                              ),
                            ),

                            Row(
                              children: [
                                Text(
                                  loc.translate('remember_me'),
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      _rememberMe = newValue ?? false;
                                    });
                                  },
                                  activeColor: AppColors.primaryColor,
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 25.h),

                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            if (auth.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return PrimaryButton(
                              text: loc.translate('login_button'),
                              onPressed: _handleLogin,
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

                SizedBox(height: 25.h),

                //  Register Redirect
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loc.translate('no_account'),
                      style: const TextStyle(color: AppColors.darkGreyColor),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.registerScreen,
                        );
                      },
                      child: Text(
                        loc.translate('register_button'),
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
      ),
    );
  }
}
