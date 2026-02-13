import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/widgets/section_content.dart';
import 'package:ztajir_furniture/presentation/views/widgets/section_divider.dart';
import 'package:ztajir_furniture/presentation/views/widgets/section_title.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: StaticAppBar(appBarName: loc.translate('terms_conditions')),
      body: const TermsBody(),
    );
  }
}

class TermsBody extends StatelessWidget {
  const TermsBody({super.key});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: loc.translate('terms_intro_title')),
          SectionContent(content: loc.translate('terms_intro_content')),
          const SectionDivider(),

          SectionTitle(title: loc.translate('terms_account_title')),
          SectionContent(content: loc.translate('terms_account_content')),
          const SectionDivider(),

          SectionTitle(title: loc.translate('terms_usage_title')),
          SectionContent(content: loc.translate('terms_usage_content')),
          const SectionDivider(),

          SectionTitle(title: loc.translate('terms_payment_title')),
          SectionContent(content: loc.translate('terms_payment_content')),
          const SectionDivider(),

          SectionTitle(title: loc.translate('terms_ip_title')),
          SectionContent(content: loc.translate('terms_ip_content')),
          const SectionDivider(),

          SectionTitle(title: loc.translate('terms_changes_title')),
          SectionContent(content: loc.translate('terms_changes_content')),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
