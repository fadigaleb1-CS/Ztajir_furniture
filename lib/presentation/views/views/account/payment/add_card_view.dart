import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/data/models/card_model.dart';
import 'package:ztajir_furniture/presentation/views/views/account/payment/credit_card_preview.dart';
import 'package:ztajir_furniture/presentation/views/views/account/payment/payment_text_field.dart';
import 'package:ztajir_furniture/core/utiles/card_formatters.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final formKey = GlobalKey<FormState>();
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  final cardHolderController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: StaticAppBar(
        appBarName: loc.translate('add_new_card'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textColor,
            size: 20.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // Card Preview (Mockup)
              CreditCardPreview(
                cardNumber: cardNumberController.text,
                cardHolder: cardHolderController.text,
                expiryDate: expiryController.text,
                loc: loc,
              ),

              SizedBox(height: 30.h),

              // Form Fields
              PaymentTextField(
                controller: cardNumberController,
                label: loc.translate('card_number'),
                hint: loc.translate('card_number_hint'),
                icon: Icons.credit_card_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  CardNumberFormatter(),
                ],
              ),
              SizedBox(height: 20.h),

              Row(
                children: [
                  Expanded(
                    child: PaymentTextField(
                      controller: expiryController,
                      label: loc.translate('card_expiry'),
                      hint: loc.translate('card_expiry_hint'),
                      icon: Icons.calendar_today_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        ExpiryDateFormatter(),
                      ],
                      onChanged: (val) => setState(() {}),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: PaymentTextField(
                      controller: cvvController,
                      label: loc.translate('card_cvv'),
                      hint: loc.translate('card_cvv_hint'),
                      icon: Icons.lock_outline_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              PaymentTextField(
                controller: cardHolderController,
                label: loc.translate('card_holder_name'),
                hint: loc.translate('card_holder_hint'),
                icon: Icons.person_outline_rounded,
                onChanged: (val) => setState(() {}),
              ),

              SizedBox(height: 40.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newCard = CardModel(
                        id: DateTime.now().toString(),
                        cardNumber: cardNumberController.text,
                        holderName: cardHolderController.text,
                        expiryDate: expiryController.text,
                        cvv: cvvController.text,
                      );
                      Navigator.pop(context, newCard);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.w),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    loc.translate('save_card'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
