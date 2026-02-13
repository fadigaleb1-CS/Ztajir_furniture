import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class BodyMessage extends StatelessWidget {
  const BodyMessage({super.key, required this.messageEmpty});
  final String messageEmpty;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        messageEmpty,
        style: TextStyle(fontSize: 20.sp, color: AppColors.textColor),
      ),
    );
  }
}
