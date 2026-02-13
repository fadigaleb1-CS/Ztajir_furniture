import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/views/widgets/contact_card.dart';
import 'package:ztajir_furniture/presentation/views/widgets/faq_tile.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class HelpSupportSheet extends StatelessWidget {
  const HelpSupportSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparentColor,
      builder: (context) => const HelpSupportSheet(),
    );
  }

  Future<void> _launchAction(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching $urlString: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(maxHeight: SizeConfig.screenHeight * 0.9),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40.w)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
            width: 50.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: AppColors.darkGreyColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.w),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    loc.translate('help_center_title'),
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    loc.translate('help_center_subtitle'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.darkGreyColor,
                    ),
                  ),

                  SizedBox(height: 25.h),

                  // Contact Cards
                  Row(
                    children: [
                      ContactCard(
                        title: loc.translate('contact_whatsapp'),
                        subtitle: loc.translate('contact_whatsapp_desc'),
                        svgPath: 'assets/icons/whatsapp.svg',
                        color: AppColors.greenColor,
                        onTap: () =>
                            _launchAction("whatsapp://send?phone=967717771247"),
                      ),
                      SizedBox(width: 15.w),
                      ContactCard(
                        title: loc.translate('contact_phone'),
                        subtitle: loc.translate('contact_phone_desc'),
                        icon: Icons.phone_in_talk_rounded,
                        color: AppColors.primaryColor,
                        onTap: () => _launchAction("tel:+967717771247"),
                      ),
                    ],
                  ),

                  SizedBox(height: 35.h),

                  // FAQ Section
                  Text(
                    loc.translate('faq_title'),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  FAQTile(
                    question: loc.translate('faq_q1'),
                    answer: loc.translate('faq_a1'),
                  ),
                  FAQTile(
                    question: loc.translate('faq_q2'),
                    answer: loc.translate('faq_a2'),
                  ),
                  FAQTile(
                    question: loc.translate('faq_q3'),
                    answer: loc.translate('faq_a3'),
                  ),

                  SizedBox(height: 30.h),

                  // Footer
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(25.w),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.access_time_filled_rounded,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          loc.translate('working_hours'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          loc.translate('working_hours_time'),
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
