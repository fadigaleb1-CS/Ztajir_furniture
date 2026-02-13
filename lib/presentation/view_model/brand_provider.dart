import 'package:flutter/material.dart';
import 'package:ztajir_furniture/data/models/brand_model.dart';
import 'package:ztajir_furniture/data/repositories/brand_repository.dart';

/// Brand Provider - Manages brand state and API calls
class BrandProvider extends ChangeNotifier {
  final BrandRepository _repository;

  BrandProvider({BrandRepository? repository})
    : _repository = repository ?? BrandRepository();

  // State
  List<BrandModel> _brands = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BrandModel> get brands => _brands;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Fetch brands from API
  Future<void> fetchBrands() async {
    // Avoid duplicate calls
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _brands = await _repository.getBrands();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('❌ Error fetching brands: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh brands (clear and reload)
  Future<void> refreshBrands() async {
    _brands = [];
    await fetchBrands();
  }

  /// Get brand by ID from local list
  BrandModel? getBrandById(int id) {
    try {
      return _brands.firstWhere((brand) => brand.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get brand name by ID
  String getBrandName(int id) {
    return getBrandById(id)?.name ?? 'Unknown';
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
