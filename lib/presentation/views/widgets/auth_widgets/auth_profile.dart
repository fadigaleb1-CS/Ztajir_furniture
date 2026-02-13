// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class AuthProfile extends StatelessWidget {
  AuthProfile({super.key, required this.icon, this.size});
  IconData icon;
  double? size;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size ?? 60.w, color: AppColors.primaryColor),
    );
  }
}
