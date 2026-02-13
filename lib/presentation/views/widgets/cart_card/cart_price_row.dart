import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/core/utiles/price_formatter.dart';

class CartPriceRow extends StatelessWidget {
  const CartPriceRow({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.isBold,
    this.currency = 'YER',
  });

  final String title;
  final double amount;
  final Color color;
  final bool isBold;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isBold ? 16.sp : 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.textColor : AppColors.darkGreyColor,
            ),
          ),
          Text(
            "${formatPrice(amount)} $currency",
            style: TextStyle(
              fontSize: isBold ? 16.sp : 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
