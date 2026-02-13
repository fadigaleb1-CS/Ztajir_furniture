import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/view_model/payment_provider.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/views/account/payment/add_card_view.dart';
import 'package:ztajir_furniture/presentation/views/widgets/custom_confirmation_dialog.dart';
import 'package:ztajir_furniture/data/models/card_model.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:
          AppColors.secondaryColor, // Secondary color for premium feel
      appBar: StaticAppBar(
        appBarName: loc.translate('payment_methods_title'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.blackColor,
            size: 20.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(loc.translate('other_methods')),
                SizedBox(height: 15.h),

                // International/Global Methods
                _buildMethodTile(
                  context,
                  id: 'cash',
                  title: loc.translate('cash_on_delivery'),
                  isSelected: provider.selectedMethodId == 'cash',
                  onTap: () => provider.selectMethod('cash'),
                ),
                SizedBox(height: 12.h),
                _buildMethodTile(
                  context,
                  id: 'jeeb',
                  title: loc.translate('jeeb'),
                  imagePath: 'images/wallets/1.png',
                  isSelected: provider.selectedMethodId == 'jeeb',
                  onTap: () => provider.selectMethod('jeeb'),
                ),
                SizedBox(height: 12.h),
                _buildMethodTile(
                  context,
                  id: 'mobile_money',
                  title: loc.translate('mobile_money'),
                  imagePath: 'images/wallets/2.jpeg',
                  isSelected: provider.selectedMethodId == 'mobile_money',
                  onTap: () => provider.selectMethod('mobile_money'),
                ),
                SizedBox(height: 12.h),
                _buildMethodTile(
                  context,
                  id: 'jawali',
                  title: loc.translate('jawali'),
                  imagePath: 'images/wallets/3.jpeg',
                  isSelected: provider.selectedMethodId == 'jawali',
                  onTap: () => provider.selectMethod('jawali'),
                ),

                SizedBox(height: 35.h),

                // Cards Section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle(loc.translate('my_cards')),
                    InkWell(
                      onTap: () => _navigateToAddCard(context),
                      borderRadius: BorderRadius.circular(8.w),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add,
                              size: 18.w,
                              color: AppColors.primaryColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              loc.translate('add_new_card'),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),

                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (provider.cards.isEmpty)
                  _buildNoCardsState(loc)
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.cards.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final card = provider.cards[index];
                      return _buildCardItem(context, card, provider, loc);
                    },
                  ),

                SizedBox(height: 30.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildMethodTile(
    BuildContext context, {
    required String id,
    required String title,
    String? iconPath,
    String? imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.w),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor, // اللون ثابت دائماً
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.darkGreyColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 32.h,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(8.w),
                border: Border.all(color: AppColors.darkGreyColor),
              ),
              child: imagePath != null
                  ? Image.asset(imagePath, fit: BoxFit.contain)
                  : iconPath != null
                  ? Image.asset(iconPath, fit: BoxFit.contain)
                  : const Icon(Icons.payment),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.textColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 24.w,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: AppColors.darkGreyColor,
                size: 24.w,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    CardModel card,
    PaymentProvider provider,
    AppLocalizations loc,
  ) {
    bool isSelected = provider.selectedMethodId == card.id;

    return InkWell(
      onTap: () => provider.selectMethod(card.id),
      borderRadius: BorderRadius.circular(16.w),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : const Color(0xFF2C3E50), // Dark background for cards
          borderRadius: BorderRadius.circular(16.w),
          boxShadow: [
            BoxShadow(
              color:
                  (isSelected
                          ? AppColors.primaryColor
                          : const Color(0xFF2C3E50))
                      .withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.credit_card,
                  color: AppColors.whiteColor.withOpacity(0.8),
                  size: 28.w,
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.whiteColor,
                    size: 24,
                  ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              '**** **** **** ${card.cardNumber.length >= 4 ? card.cardNumber.substring(card.cardNumber.length - 4) : card.cardNumber}',
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 18.sp,
                letterSpacing: 2,
                fontFamily: 'Courier', // Monospace for card numbers
              ),
            ),
            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('card_holder_name'),
                      style: TextStyle(
                        color: AppColors.whiteColor.withOpacity(0.6),
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      card.holderName.isNotEmpty
                          ? card.holderName.toUpperCase()
                          : 'UNKNOWN',
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () async {
                    final shouldDelete = await CustomConfirmationDialog.show(
                      context: context,
                      title: loc.translate('delete_card_title'),
                      content: loc.translate('delete_card_confirm'),
                      confirmText: loc.translate('delete'),
                      cancelText: loc.translate('cancel'),
                      icon: Icons.credit_card_off_rounded,
                      confirmColor: AppColors.redColor,
                      iconColor: AppColors.primaryColor,
                      // Customizing dialog for card deletion visual
                    );

                    if (shouldDelete) {
                      provider.removeCard(card.id);
                    }
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.whiteColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCardsState(AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: AppColors.darkGreyColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.credit_card_off_outlined,
            size: 40.w,
            color: AppColors.darkGreyColor.withOpacity(0.2),
          ),
          SizedBox(height: 10.h),
          Text(
            loc.translate('no_payment_methods'),
            style: TextStyle(
              color: AppColors.darkGreyColor.withOpacity(0.2),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddCard(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCardScreen()),
    );

    if (result != null && result is CardModel) {
      if (!mounted) return;
      Provider.of<PaymentProvider>(context, listen: false).addCard(result);
    }
  }
}
