import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ztajir_furniture/data/models/product_model.dart';
import 'package:ztajir_furniture/data/repositories/product_repository.dart';

class SearchProvider extends ChangeNotifier {
  final ProductRepository _productRepository = ProductRepository();

  // Search Results
  List<ProductModel> _searchResults = [];
  List<ProductModel> get searchResults => _searchResults;

  // Search Query
  String _currentQuery = '';
  String get currentQuery => _currentQuery;

  // Filters
  double? _minPrice;
  double? get minPrice => _minPrice;

  double? _maxPrice;
  double? get maxPrice => _maxPrice;

  String? _selectedSortOption;
  String? get selectedSortOption => _selectedSortOption;

  Map<String, String> _sortOptions = {};
  Map<String, String> get sortOptions => _sortOptions;

  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Timer? _debounce;

  SearchProvider() {
    _fetchFilterOptions();
  }

  void _fetchFilterOptions() async {
    try {
      _sortOptions = await _productRepository.getFilterOptions();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load filter options: $e');
    }
  }

  void updateSearchQuery(String query) {
    if (query.trim() == _currentQuery) return;
    _currentQuery = query.trim();
    _triggerSearch();
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  void setSortOption(String? option) {
    _selectedSortOption = option;
    _triggerSearch(); // Trigger update immediately when sort changes
  }

  void applyFilters() {
    _triggerSearch();
  }

  void clearFilters() {
    _minPrice = null;
    _maxPrice = null;
    _selectedSortOption = null;
    // Don't clear query here, only filters
    _triggerSearch();
  }

  void clearSearch() {
    _currentQuery = '';
    _searchResults = [];
    _error = null;
    _debounce?.cancel();
    _isLoading = false;
    notifyListeners();
  }

  void _triggerSearch() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _isLoading = true;
    _error = null;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    // We removed the condition blocking execution if query is empty.
    // Now, even if query is empty, it proceeds to fetch products and apply filters.
    // This allows "Filter Only" scenario to work.

    try {
      // Fetch "raw" products from API (ignore backend filtering parameters)
      // We explicitly DO NOT pass minPrice, maxPrice, sort, or search to the backend
      // to avoid buggy backend filtering returning empty results.
      // We fetch a larger batch (50) and filter purely on client side.
      final products = await _productRepository.getProducts(limit: 50);

      var results = products;

      // 1. Local Text Search Filtering
      if (_currentQuery.isNotEmpty) {
        final queryLower = _currentQuery.toLowerCase();
        results = results.where((product) {
          final titleLower = product.title.toLowerCase();
          final descLower = product.describtion.toLowerCase();
          final brandLower = (product.brandName ?? '').toLowerCase();
          final categoryLower = (product.categorySlug ?? '').toLowerCase();

          return titleLower.contains(queryLower) ||
              descLower.contains(queryLower) ||
              brandLower.contains(queryLower) ||
              categoryLower.contains(queryLower);
        }).toList();
      }

      // 2. Local Price Filtering
      if (_minPrice != null || _maxPrice != null) {
        results = results.where((product) {
          final price = product.price;
          if (_minPrice != null && price < _minPrice!) return false;
          if (_maxPrice != null && price > _maxPrice!) return false;
          return true;
        }).toList();
      }

      // 3. Local Sorting
      if (_selectedSortOption != null) {
        switch (_selectedSortOption) {
          case 'price_asc':
            results.sort((a, b) => a.price.compareTo(b.price));
            break;
          case 'price_desc':
            results.sort((a, b) => b.price.compareTo(a.price));
            break;
          case 'latest':
            // Provided product has isNew flag but no date,
            // relying on ID as proxy for "latest" usually works for auto-increment DBs
            results.sort((a, b) => b.id.compareTo(a.id));
            break;
        }
      }

      _searchResults = results;
    } catch (e) {
      _error = 'Failed to fetch results';
      debugPrint('Search error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
