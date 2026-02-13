import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';

class ViewAll extends StatelessWidget {
  const ViewAll({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "${AppLocalizations.of(context)!.translate('view_all')}>",
      style: TextStyle(
        fontSize: 14.sp,
        color: AppColors.primaryColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
