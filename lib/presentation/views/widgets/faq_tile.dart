import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class FAQTile extends StatelessWidget {
  final String question;
  final String answer;

  const FAQTile({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.darkGreyColor),
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.primaryColor,
          title: Text(
            question,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          childrenPadding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: 16.h,
          ),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.blackColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
