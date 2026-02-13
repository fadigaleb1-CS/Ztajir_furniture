import 'package:flutter/material.dart';
import 'package:ztajir_furniture/presentation/views/auth_views/auth_screen.dart';
import 'package:ztajir_furniture/presentation/views/auth_views/forget_password.dart';
import 'package:ztajir_furniture/presentation/views/auth_views/login_screen.dart';
import 'package:ztajir_furniture/presentation/views/auth_views/register_screen.dart';
import 'package:ztajir_furniture/presentation/views/auth_views/splash_view.dart';
import 'package:ztajir_furniture/presentation/views/views/main_views/main_screen.dart';
import 'package:ztajir_furniture/presentation/views/views/account/order_view_state.dart';
import 'package:ztajir_furniture/presentation/views/auth_views/verification_screen.dart';
import 'package:ztajir_furniture/presentation/views/auth_views/reset_password_screen.dart';
import 'package:ztajir_furniture/presentation/views/auth_views/terms_privacy_screen.dart';

class AppRoutes {
  static const String splashScreen = '/splash_screen';
  static const String authScreen = '/auth_screen';
  static const String loginScreen = '/login_screen';
  static const String registerScreen = '/register_screen';
  static const String forgetPasswordScreen = '/forget_password_screen';
  static const String main = '/main_screen';
  static const String orderScreenState = '/order_screen_state';
  static const String verificationScreen = '/verification_screen';
  static const String resetPasswordScreen = '/reset_password_screen';
  static const String termsPrivacyScreen = '/terms_privacy_screen';

  static Map<String, WidgetBuilder> routes = {
    splashScreen: (context) => const SplashScreen(),
    authScreen: (context) => AuthScreen(),
    loginScreen: (context) => const LoginScreen(),
    registerScreen: (context) => const RegisterScreen(),
    forgetPasswordScreen: (context) => const ForgotPasswordScreen(),
    main: (context) => const MainScreen(),
    orderScreenState: (context) => const OrderScreen(),
    verificationScreen: (context) => const VerificationScreen(),
    resetPasswordScreen: (context) => const ResetPasswordScreen(),
    termsPrivacyScreen: (context) => const TermsPrivacyScreen(),
  };

  // static List<GetPage> pages = [
  //   GetPage(
  //     name: splashScreen,
  //     page: () => const SplashScreen(),
  //     transition: Transition.cupertinoDialog,
  //     transitionDuration: Duration(milliseconds: 400), // ← الحركة هنا
  //   ),
  //   GetPage(
  //     name: authScreen,
  //     page: () => AuthScreen(),
  //     transition: Transition.cupertinoDialog,
  //     transitionDuration: Duration(milliseconds: 400),
  //   ),
  //   GetPage(
  //     name: loginScreen,
  //     page: () => const LoginScreen(),
  //     transition: Transition.cupertinoDialog,
  //     transitionDuration: Duration(milliseconds: 400),
  //   ),
  //   GetPage(
  //     name: registerScreen,
  //     page: () => const RegisterScreen(),
  //     transition: Transition.cupertinoDialog,
  //     transitionDuration: Duration(milliseconds: 400),
  //   ),
  //   GetPage(
  //     name: forgetPasswordScreen,
  //     page: () => const ForgotPasswordScreen(),
  //     transition: Transition.cupertinoDialog,
  //     transitionDuration: Duration(milliseconds: 400),
  //   ),
  // ];
}
