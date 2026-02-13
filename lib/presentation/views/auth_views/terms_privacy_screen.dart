import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/views/views/account/settings/privacy_view.dart';
import 'package:ztajir_furniture/presentation/views/views/account/settings/terms_view.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(context, loc),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 10.h),

            ExpandableSectionCard(
              title: loc.translate('terms_conditions'),
              icon: Icons.description_outlined,
              content: const TermsBody(),
              initiallyExpanded: true,
            ),

            SizedBox(height: 16.h),

            ExpandableSectionCard(
              title: loc.translate('privacy_policy'),
              icon: Icons.shield_outlined,
              content: const PrivacyBody(),
              initiallyExpanded: false,
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, AppLocalizations loc) {
    return AppBar(
      backgroundColor: AppColors.transparentColor,
      elevation: 0,
      foregroundColor: AppColors.primaryColor,
      leading: IconButton(
        icon: Icon(Icons.close, color: AppColors.primaryColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        loc.translate('terms_and_privacy'),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
      ),
      centerTitle: true,
    );
  }
}

class ExpandableSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;
  final bool initiallyExpanded;

  const ExpandableSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.w),
        side: BorderSide(color: AppColors.darkGreyColor),
      ),
      color: AppColors.whiteColor,
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(
          context,
        ).copyWith(dividerColor: AppColors.transparentColor),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 24.w),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: AppColors.primaryColor,
            ),
          ),
          children: [SizedBox(height: 400.h, child: content)],
        ),
      ),
    );
  }
}
