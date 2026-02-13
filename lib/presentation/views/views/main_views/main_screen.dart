import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // نحتاجها للتحكم في إغلاق التطبيق برمجياً
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/views/views/Favorite/favorite_view.dart';
import 'package:ztajir_furniture/presentation/views/views/account/account_view.dart';
import 'package:ztajir_furniture/presentation/views/views/cart/cart_view.dart';
import 'package:ztajir_furniture/presentation/views/views/home/home_views.dart';
import 'package:ztajir_furniture/presentation/views/views/search/search_view.dart';
import 'package:ztajir_furniture/presentation/views/widgets/navigation_bar/app_navigation_bar.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

// ====================== Main Screen ======================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    CartScreen(),
    FavoriteScreen(),
    SearchScreen(),
    AccountScreen(),
  ];

  // دالة إظهار نافذة التأكيد بتصميم عصري
  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.w),
            ),
            title: Icon(
              Icons.logout_rounded,
              color: AppColors.primaryColor,
              size: 40.w,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  )!.translate('exit_confirmation_title'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.translate('exit_confirmation_message'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            actionsPadding: EdgeInsets.only(
              bottom: 20.h,
              left: 20.w,
              right: 20.w,
            ),
            actions: [
              Row(
                children: [
                  // زر الإلغاء (البقاء في التطبيق)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(
                          color: AppColors.primaryColor.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.translate('cancel'),
                        style: TextStyle(color: AppColors.textColor),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // زر الخروج الفعلي
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.whiteColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.translate('exit'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // نمنع الخروج التلقائي
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // إذا تم الخروج مسبقاً لا نفعل شيئاً

        // إظهار نافذة التأكيد
        final shouldPop = await _showExitDialog(context);

        if (shouldPop && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        resizeToAvoidBottomInset: false,

        body: Stack(
          children: [
            // ===== محتوى الصفحات =====
            Positioned.fill(child: screens[currentIndex]),

            // ===== الـ Bottom Nav Bar العائم فوق المحتوى =====
            Positioned(
              left: 0,
              right: 0,
              bottom: 12.h,
              child: Center(
                child: AppNavigationBarBar(
                  currentIndex: currentIndex,
                  onTap: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
