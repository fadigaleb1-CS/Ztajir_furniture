import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/presentation/view_model/auth_provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/utiles/snack_bar_helper.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/custom_text_field.dart';
import 'package:ztajir_furniture/presentation/views/widgets/primary_button.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      try {
        await Provider.of<AuthProvider>(context, listen: false).changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

        if (mounted) {
          SnackBarHelper.show(
            context: context,
            message: loc.translate('password_changed_success'),
            backgroundColor: AppColors.primaryColor,
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          SnackBarHelper.show(
            context: context,
            message: e.toString().replaceAll('Exception: ', ''),
            backgroundColor: AppColors.redColor,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: StaticAppBar(appBarName: loc.translate('change_password')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('change_password_subtitle'),
                style: TextStyle(
                  color: AppColors.darkGreyColor,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 30.h),

              CustomTextField(
                controller: _currentPasswordController,
                labelText: loc.translate('current_password'),
                hintText: '********',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.translate('enter_current_password');
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              CustomTextField(
                controller: _newPasswordController,
                labelText: loc.translate('new_password'),
                hintText: '********',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.translate('enter_new_password');
                  }
                  if (value.length < 6) {
                    return loc.translate('password_min_length');
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              CustomTextField(
                controller: _confirmPasswordController,
                labelText: loc.translate('confirm_password'),
                hintText: '********',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.translate('confirm_new_password');
                  }
                  if (value != _newPasswordController.text) {
                    return loc.translate('password_mismatch');
                  }
                  return null;
                },
              ),

              SizedBox(height: 50.h),

              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return PrimaryButton(
                    text: loc.translate('save_changes'),
                    isLoading: auth.isLoading,
                    onPressed: _submit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
