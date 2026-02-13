import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final String labelText;
  final bool isPassword;
  final IconData icon;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.controller,
    required this.labelText,
    this.onChanged,
    this.onTap,
  });
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  double textFiledBorderRadius = 14.w;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      textAlign: TextAlign.right,

      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
        ),

        prefixIcon: Icon(widget.icon, color: AppColors.primaryColor),

        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.primaryColor,
                ),
                onPressed: _toggleVisibility,
              )
            : null,

        filled: true,
        fillColor: AppColors.whiteColor,

        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 18.w),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(textFiledBorderRadius),
          borderSide: BorderSide(color: AppColors.darkGreyColor, width: 1.2),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(textFiledBorderRadius),
          borderSide: BorderSide(color: AppColors.darkGreyColor, width: 1.2),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(textFiledBorderRadius),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(textFiledBorderRadius),
          borderSide: BorderSide(color: AppColors.redColor, width: 1.2),
        ),
      ),
    );
  }
}
