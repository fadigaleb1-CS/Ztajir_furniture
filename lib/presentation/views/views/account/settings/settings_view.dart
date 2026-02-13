import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/widgets/account/account_section_card.dart';
import 'package:ztajir_furniture/presentation/views/widgets/account/account_section_header.dart';
import 'package:ztajir_furniture/presentation/views/widgets/settings_action_tile.dart';
import 'package:ztajir_furniture/presentation/views/widgets/settings_toggle_tile.dart';
import 'package:ztajir_furniture/presentation/views/views/account/settings/security_view.dart';
import 'package:ztajir_furniture/presentation/views/views/account/settings/privacy_view.dart';
import 'package:ztajir_furniture/presentation/views/views/account/settings/terms_view.dart';
import 'package:ztajir_furniture/presentation/view_model/language_provider.dart';

import 'package:ztajir_furniture/presentation/views/widgets/custom_confirmation_dialog.dart';
import 'package:ztajir_furniture/presentation/views/widgets/language_selection_sheet.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // قيم افتراضية للتجربة
  bool _notificationsEnabled = true;

  void _showDeleteAccountDialog(BuildContext context) async {
    var loc = AppLocalizations.of(context)!;
    final shouldDelete = await CustomConfirmationDialog.show(
      context: context,
      title: loc.translate('delete_account_title'),
      content: loc.translate('delete_account_confirm'),
      confirmText: loc.translate('delete'),
      cancelText: loc.translate('cancel'),
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.redColor,
      confirmColor: AppColors.redColor,
    );

    if (shouldDelete) {
      // TODO: Add actual delete account API call here
      Navigator.pop(context);
    }
  }

  void _showLanguageBottomSheet(BuildContext context) {
    LanguageSelectionSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    var langProvider = Provider.of<LanguageProvider>(context);

    // Determines current language label to show
    String currentLangLabel;
    if (langProvider.isSystemLanguage) {
      currentLangLabel = loc.translate('system_language');
    } else if (langProvider.selectedLanguage == 'ar') {
      currentLangLabel = 'العربية';
    } else {
      currentLangLabel = 'English';
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: StaticAppBar(appBarName: loc.translate('settings_title')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
        child: Column(
          children: [
            // --- 1. إعدادات التطبيق ---
            AccountSectionName(title: loc.translate('app_settings')),
            AccountSectionCard(
              items: [
                SettingsToggleTile(
                  icon: Icons.notifications_outlined,
                  title: loc.translate('notifications'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                SettingsActionTile(
                  icon: Icons.language,
                  title: loc.translate('app_language'),
                  value: currentLangLabel,
                  onTap: () {
                    _showLanguageBottomSheet(context);
                  },
                ),
              ],
            ),

            SizedBox(height: 25.h),

            // --- 2. الأمان والخصوصية ---
            AccountSectionName(title: loc.translate('security_privacy')),
            AccountSectionCard(
              items: [
                SettingsActionTile(
                  icon: Icons.security_rounded,
                  title: loc.translate('security'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SecurityScreen(),
                      ),
                    );
                  },
                ),
                SettingsActionTile(
                  icon: Icons.privacy_tip_outlined,
                  title: loc.translate('privacy_policy'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyView(),
                      ),
                    );
                  },
                ),
                SettingsActionTile(
                  icon: Icons.description_outlined,
                  title: loc.translate('terms_conditions'),
                  showDivider: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsView(),
                      ),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 25.h),

            // --- 3. معلومات أخرى ---
            AccountSectionName(title: loc.translate('info')),
            AccountSectionCard(
              items: [
                SettingsActionTile(
                  icon: Icons.info_outline,
                  title: loc.translate('version'),
                  value: '1.0.0',
                  showDivider: false,
                  onTap: () {}, // عادة لا يوجد إجراء هنا
                ),
              ],
            ),

            SizedBox(height: 25.h),

            // --- 4. إدارة الحساب ---
            AccountSectionName(title: loc.translate('account_management')),
            AccountSectionCard(
              items: [
                SettingsActionTile(
                  icon: Icons.delete_outline_rounded,
                  title: loc.translate('delete_account'),
                  isDestructive: true,
                  showDivider: false,
                  onTap: () {
                    _showDeleteAccountDialog(context);
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
}
