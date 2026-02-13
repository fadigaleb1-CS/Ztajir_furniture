import 'package:flutter/material.dart';
import 'package:ztajir_furniture/data/models/category_model.dart';
import 'package:ztajir_furniture/data/repositories/category_repository.dart';

/// Category Provider - Manages category state and API calls
class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoryProvider({CategoryRepository? repository})
    : _repository = repository ?? CategoryRepository();

  // State
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Fetch categories from API
  Future<void> fetchCategories({int retryCount = 0}) async {
    // Avoid duplicate calls
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _repository.getCategories();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('❌ Error fetching categories: $e');

      // Retry up to 2 times with exponential backoff
      if (retryCount < 2) {
        _isLoading = false;
        notifyListeners();
        await Future.delayed(Duration(seconds: 2 * (retryCount + 1)));
        return fetchCategories(retryCount: retryCount + 1);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh categories (clear and reload)
  Future<void> refreshCategories() async {
    _categories = [];
    await fetchCategories();
  }

  /// Get category by ID from local list
  CategoryModel? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get category name by ID
  String getCategoryName(int id) {
    return getCategoryById(id)?.name ?? 'Unknown';
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
