import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/widgets/section_content.dart';
import 'package:ztajir_furniture/presentation/views/widgets/section_divider.dart';
import 'package:ztajir_furniture/presentation/views/widgets/section_title.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: StaticAppBar(appBarName: loc.translate('privacy_policy')),
      body: const PrivacyBody(),
    );
  }
}

class PrivacyBody extends StatelessWidget {
  const PrivacyBody({super.key});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: loc.translate('privacy_intro_title')),
          SectionContent(content: loc.translate('privacy_intro_content')),
          const SectionDivider(),

          SectionTitle(title: loc.translate('privacy_data_title')),
          SectionContent(content: loc.translate('privacy_data_content')),
          const SectionDivider(),

          SectionTitle(title: loc.translate('privacy_usage_title')),
          SectionContent(content: loc.translate('privacy_usage_content')),
          const SectionDivider(),

          SectionTitle(title: loc.translate('privacy_sharing_title')),
          SectionContent(content: loc.translate('privacy_sharing_content')),
          const SectionDivider(),

          SectionTitle(title: loc.translate('privacy_security_title')),
          SectionContent(content: loc.translate('privacy_security_content')),
          const SectionDivider(),

          SectionTitle(title: loc.translate('privacy_deletion_title')),
          SectionContent(content: loc.translate('privacy_deletion_content')),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
