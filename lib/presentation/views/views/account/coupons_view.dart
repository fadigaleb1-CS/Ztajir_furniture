import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/data/models/coupon_model.dart';
import 'package:ztajir_furniture/presentation/views/widgets/account/coupon_card.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  static final List<CouponModel> coupons = [
    CouponModel(
      code: 'SAVE20',
      discountPercentage: 0.20,
      description: '20% Off on all furniture',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
    ),
    CouponModel(
      code: 'WELCOME10',
      discountPercentage: 0.10,
      description: '10% Welcome Bonus for new users',
      expiryDate: DateTime.now().add(const Duration(days: 365)),
    ),
    CouponModel(
      code: 'SUMMER50',
      discountPercentage: 0.50,
      description: '50% Off Summer Sale',
      expiryDate: DateTime.now().subtract(const Duration(days: 1)), // Expired
      isActive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: StaticAppBar(
        appBarName: loc.translate('my_coupons'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.w),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: coupons.length,
        itemBuilder: (context, index) {
          final coupon = coupons[index];
          return CouponCard(coupon: coupon, loc: loc);
        },
      ),
    );
  }
}
