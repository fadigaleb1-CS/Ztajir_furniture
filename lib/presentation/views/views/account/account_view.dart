import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/presentation/view_model/auth_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/favorite_provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/routes/app_route.dart';
import 'package:ztajir_furniture/presentation/views/widgets/account/account_menu_item.dart';
import 'package:ztajir_furniture/presentation/views/views/account/address/address_view.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/views/account/account_header.dart';
import 'package:ztajir_furniture/presentation/views/widgets/account/account_section_card.dart';
import 'package:ztajir_furniture/presentation/views/widgets/account/account_section_header.dart';
import 'package:ztajir_furniture/presentation/views/widgets/custom_confirmation_dialog.dart';
import 'about_app_sheet_view.dart';
import 'help_support_sheet_view.dart';
import 'package:ztajir_furniture/presentation/views/views/account/settings/settings_view.dart';
import 'package:ztajir_furniture/presentation/views/views/account/payment/payment_view.dart';
import 'package:ztajir_furniture/presentation/views/views/home/notifications_view.dart';
import 'package:ztajir_furniture/presentation/views/views/account/coupons_view.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // إذا لم يكن المستخدم مسجل دخول، نعرض واجهة مخصصة
    if (!authProvider.isAuthenticated) {
      return _buildGuestAccountView(context);
    }

    var loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: StaticAppBar(appBarName: loc.translate('account_title')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
        child: Column(
          children: [
            // --- 1. الهيدر المطور (أكثر بروزاً) ---
            const AccountHeader(),

            SizedBox(height: 35.h),

            // --- 2. قسم المعاملات ---
            AccountSectionName(title: loc.translate('transactions')),
            AccountSectionCard(
              items: [
                AccountMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: loc.translate('menu_my_orders'),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.orderScreenState);
                  },
                ),
                AccountMenuItem(
                  icon: Icons.location_on_outlined,
                  title: loc.translate('menu_saved_addresses'),
                  // تم تعديل هذا السطر لينقلك للشاشة الجديدة مباشرة
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddressesScreen(),
                      ),
                    );
                  },
                ),
                AccountMenuItem(
                  icon: Icons.local_activity_outlined,
                  title: loc.translate('menu_my_coupons'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CouponsScreen(),
                      ),
                    );
                  },
                ),
                AccountMenuItem(
                  icon: Icons.credit_card_outlined,
                  title: loc.translate('menu_payment_methods'),
                  showDivider: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentMethodsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 25.h),

            // --- 3. قسم الإعدادات ---
            AccountSectionName(title: loc.translate('general_settings')),
            AccountSectionCard(
              items: [
                AccountMenuItem(
                  icon: Icons.notifications_none_rounded,
                  title: loc.translate('notifications_title'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsView(),
                      ),
                    );
                  },
                ),
                AccountMenuItem(
                  icon: Icons.settings_outlined,
                  title: loc.translate('menu_settings'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                AccountMenuItem(
                  icon: Icons.help_outline_rounded,
                  title: loc.translate('menu_help_support'),
                  onTap: () {
                    HelpSupportSheet.show(context);
                  },
                ),
                AccountMenuItem(
                  icon: Icons.info_outline_rounded,
                  title: loc.translate('menu_about_app'),
                  showDivider: false,
                  onTap: () {
                    // استدعاء الكلاس المنفصل
                    AboutAppSheet.show(context);
                  },
                ),
              ],
            ),

            SizedBox(height: 25.h),

            // --- 4. تسجيل الخروج (كارت منفصل بارز) ---
            AccountSectionCard(
              items: [
                AccountMenuItem(
                  icon: Icons.logout_rounded,
                  title: loc.translate('menu_logout'),
                  isDestructive: true,
                  showDivider: false,
                  onTap: () async {
                    final shouldExit = await CustomConfirmationDialog.show(
                      context: context,
                      title: loc.translate('logout_confirmation_title'),
                      content: loc.translate('logout_confirmation_message'),
                      confirmText: loc.translate('exit'),
                      cancelText: loc.translate('cancel'),
                      icon: Icons.logout_rounded,
                    );

                    if (shouldExit == true) {
                      if (context.mounted) {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        // مسح المفضلة المحلية قبل تسجيل الخروج
                        final favoriteProvider = Provider.of<FavoriteProvider>(
                          context,
                          listen: false,
                        );
                        favoriteProvider.clearFavorites();

                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.main,
                            (route) => false,
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),

            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestAccountView(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: StaticAppBar(appBarName: loc.translate('account_title')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة الحساب
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 50.w,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 24.h),

              // العنوان
              Text(
                loc.translate('account_login_prompt'),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // الوصف
              Text(
                loc.translate('account_login_subtitle'),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.darkGreyColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),

              // زر تسجيل الدخول
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.loginScreen);
                  },
                  child: Text(
                    loc.translate('login_button'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // زر إنشاء حساب
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.registerScreen);
                  },
                  child: Text(
                    loc.translate('register_button'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
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
