import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/routes/app_route.dart';
import 'package:ztajir_furniture/presentation/view_model/auth_provider.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/auth_profile.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    // محاكاة تحميل البيانات أو فحص حالة الدخول
    // Start animation delay
    final minDelay = Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Wait for the auth provider to finish checking local storage
    while (!authProvider.isAutoLoginCheckComplete) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    // Ensure strict minimum splash duration
    await minDelay;

    if (mounted) {
      if (authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.authScreen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //  Header
              AuthProfile(icon: Icons.chair, size: 120.w),
              SizedBox(height: 20.h),
              Text(
                AppLocalizations.of(
                  context,
                )!.translate('auth_furniture_app_title'),
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 50.h),
              SizedBox(
                height: 50.h,
                width: 50.w,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                  strokeWidth: 5.w,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
