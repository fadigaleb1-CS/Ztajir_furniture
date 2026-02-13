//auth screen
import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class AppButtonText extends StatelessWidget {
  final String text;
  final Color color;

  const AppButtonText({Key? key, required this.text, required this.color})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
