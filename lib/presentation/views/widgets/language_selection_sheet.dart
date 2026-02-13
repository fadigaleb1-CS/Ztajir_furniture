import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/view_model/language_provider.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class LanguageSelectionSheet extends StatelessWidget {
  const LanguageSelectionSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.w)),
      ),
      builder: (context) => const LanguageSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // System Language Option
          ListTile(
            leading: Icon(
              Icons.phone_android,
              size: 24.w,
              color: AppColors.primaryColor,
            ),
            title: Text(loc.translate('system_language')),
            trailing: langProvider.isSystemLanguage
                ? Icon(Icons.check_circle, color: AppColors.primaryColor)
                : null,
            onTap: () {
              langProvider.changeLanguage('system');
              Navigator.pop(context);
            },
          ),
          const Divider(),
          // English Option
          ListTile(
            leading: Text('🇺🇸', style: TextStyle(fontSize: 24.sp)),
            title: const Text('English'),
            trailing: langProvider.selectedLanguage == 'en'
                ? Icon(Icons.check_circle, color: AppColors.primaryColor)
                : null,
            onTap: () {
              langProvider.changeLanguage('en');
              Navigator.pop(context);
            },
          ),
          // Arabic Option
          ListTile(
            leading: Text('🇾🇪', style: TextStyle(fontSize: 24.sp)),
            title: const Text('العربية'),
            trailing: langProvider.selectedLanguage == 'ar'
                ? Icon(Icons.check_circle, color: AppColors.primaryColor)
                : null,
            onTap: () {
              langProvider.changeLanguage('ar');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
