import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/widgets/account/account_section_card.dart';
import 'package:ztajir_furniture/presentation/views/widgets/settings_action_tile.dart';
import 'package:ztajir_furniture/presentation/views/widgets/settings_toggle_tile.dart';
import 'package:ztajir_furniture/presentation/views/views/account/settings/change_password_view.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  // Mock values for toggles
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: StaticAppBar(
        appBarName: loc.translate(
          'security',
        ), // Ensure this key exists or is added
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.blackColor, // Or AppColors.iconColor if defined
            size: 20.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
        child: Column(
          children: [
            // Authentication Section
            AccountSectionCard(
              items: [
                SettingsActionTile(
                  icon: Icons.lock_outline_rounded,
                  title: loc.translate('change_password'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                SettingsToggleTile(
                  icon: Icons.security_rounded,
                  title: loc.translate('two_factor_auth'),
                  value: _twoFactorEnabled,
                  onChanged: (value) {
                    setState(() {
                      _twoFactorEnabled = value;
                    });
                  },
                ),
                SettingsToggleTile(
                  icon: Icons.fingerprint_rounded,
                  title: loc.translate('biometric_auth'),
                  value: _biometricEnabled,
                  showDivider: false,
                  onChanged: (value) {
                    setState(() {
                      _biometricEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
