import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/data/models/branding_model.dart';
import 'package:ztajir_furniture/data/repositories/branding_repository.dart';

/// Provider for managing branding/theme colors from API
class BrandingProvider extends ChangeNotifier {
  final BrandingRepository _repository = BrandingRepository();

  BrandingModel _branding = BrandingModel.defaultBranding();
  bool _isLoading = false;
  String? _error;

  // Getters
  BrandingModel get branding => _branding;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Color Getters
  Color get primaryColor => _branding.colors.primary.main;
  Color get secondaryColor => _branding.colors.secondary.main;
  Color get accentColor => _branding.colors.accent.main;

  // Other Getters
  String get fontFamily => _branding.typography.fontFamily;
  BrandingLogos get logos => _branding.logos;
  BrandingSocial get social => _branding.social;

  /// Fetch branding from API and update AppColors
  Future<void> fetchBranding() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _branding = await _repository.getBranding();

      // ✅ تحديث AppColors بالألوان من الـ API
      AppColors.updateFromApi(
        primaryColor: _branding.colors.primary.main,
        secondaryColor: _branding.colors.secondary.main,
        accentColor: _branding.colors.accent.main,
      );

      print('✅ Branding loaded successfully');
    } catch (e) {
      _error = e.toString();
      print('❌ Error loading branding: $e');
      // Keep default branding on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update branding manually (for testing or local changes)
  void updateBranding(BrandingModel newBranding) {
    _branding = newBranding;

    // تحديث AppColors أيضاً
    AppColors.updateFromApi(
      primaryColor: newBranding.colors.primary.main,
      secondaryColor: newBranding.colors.secondary.main,
      accentColor: newBranding.colors.accent.main,
    );

    notifyListeners();
  }
}
