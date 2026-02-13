// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class AuthCard extends StatelessWidget {
  AuthCard({super.key, required this.chiled});
  Widget chiled;
  static final double CardBorderRadius = 20.w;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondaryColor,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CardBorderRadius),
      ),
      child: Padding(padding: EdgeInsets.all(20.w), child: chiled),
    );
  }
}
