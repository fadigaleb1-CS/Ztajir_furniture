import 'package:flutter/material.dart';

/// AppColors - Dynamic color system with API support
///
/// primaryColor, secondaryColor, accentColor → من الـ API
/// باقي الألوان → ثابتة
class AppColors {
  // === الألوان الديناميكية (من الـ API) ===
  static Color _primaryColor = const Color(0xFF8B4513);
  static Color _secondaryColor = const Color(0xFFFFFBF0);
  static Color _accentColor = const Color(0xFFF59E0B);

  // Getters للألوان الديناميكية
  static Color get primaryColor => _primaryColor;
  static Color get secondaryColor => _secondaryColor;
  static Color get accentColor => _accentColor;

  // === تحديث الألوان من الـ API ===
  static void updateFromApi({
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
  }) {
    if (primaryColor != null) _primaryColor = primaryColor;
    if (secondaryColor != null) _secondaryColor = secondaryColor;
    if (accentColor != null) _accentColor = accentColor;

    print('✅ AppColors updated from API');
    print('   Primary: $_primaryColor');
    print('   Secondary: $_secondaryColor');
    print('   Accent: $_accentColor');
  }

  // === الألوان الثابتة ===
  static const Color textColor = Color(0xFF333333);
  static const Color darkGreyColor = Color(0xFF808080);
  static const Color backgroundColor = Color(0xFFFFFBF0);

  // Basic Colors
  static const Color transparentColor = Colors.transparent;
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;

  // Status Colors
  static const Color redColor = Colors.red;
  static const Color greenColor = Color(0xFF25D366);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);
}
