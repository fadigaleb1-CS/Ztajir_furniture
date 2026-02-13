import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'language_code';
  static const String systemLanguage = 'system';

  String _selectedLanguage = systemLanguage; // 'system', 'ar', or 'en'
  Locale? _appLocale;

  Locale get appLocale {
    if (_selectedLanguage == systemLanguage) {
      // Get system locale
      final systemLocale = ui.PlatformDispatcher.instance.locale;
      // Return Arabic if system is Arabic, otherwise English
      if (systemLocale.languageCode == 'ar') {
        return const Locale('ar');
      }
      return const Locale('en');
    }
    return _appLocale ?? const Locale('ar');
  }

  String get selectedLanguage => _selectedLanguage;

  bool get isSystemLanguage => _selectedLanguage == systemLanguage;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_languageKey);

    if (languageCode != null) {
      _selectedLanguage = languageCode;
      if (languageCode != systemLanguage) {
        _appLocale = Locale(languageCode);
      }
    }
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    if (_selectedLanguage == languageCode) return;

    _selectedLanguage = languageCode;

    if (languageCode == systemLanguage) {
      _appLocale = null; // Will use system locale
    } else {
      _appLocale = Locale(languageCode);
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }
}
