import 'package:flutter/material.dart';
import 'package:ztajir_furniture/data/models/product_model.dart';
import 'package:ztajir_furniture/data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  // State
  List<ProductModel> _products = []; // Main list (if needed)
  List<ProductModel> _newProducts = [];
  List<ProductModel> _mostPopularProducts = []; // Featured
  List<ProductModel> _suggestedProducts = []; // On Sale / Suggestions
  List<ProductModel> _categoryProducts = []; // Products by Category
  List<ProductModel> _brandProducts = []; // Products by Brand

  bool _isLoading = false;
  String? _error;

  // Getters
  List<ProductModel> get products => _products;
  List<ProductModel> get newProducts => _newProducts;
  List<ProductModel> get mostPopularProducts => _mostPopularProducts;
  List<ProductModel> get suggestedProducts => _suggestedProducts;
  List<ProductModel> get categoryProducts => _categoryProducts;
  List<ProductModel> get brandProducts => _brandProducts;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Fetch Main Products (General)
  Future<void> fetchProducts() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _repository.getProducts();
    } catch (e) {
      print('❌ Error fetching products: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch New Arrivals
  Future<void> fetchNewProducts({int retryCount = 0}) async {
    try {
      _newProducts = await _repository.getNewProducts();
      _error = null; // Clear error on success
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching new products: $e');
      _error = e.toString();

      // Retry up to 2 times with exponential backoff
      if (retryCount < 2) {
        await Future.delayed(Duration(seconds: 2 * (retryCount + 1)));
        return fetchNewProducts(retryCount: retryCount + 1);
      }
      notifyListeners();
    }
  }

  /// Fetch Most Popular (Featured)
  Future<void> fetchMostPopularProducts({int retryCount = 0}) async {
    try {
      _mostPopularProducts = await _repository.getMostPopularProducts();
      _error = null;
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching most popular: $e');
      _error = e.toString();

      if (retryCount < 2) {
        await Future.delayed(Duration(seconds: 2 * (retryCount + 1)));
        return fetchMostPopularProducts(retryCount: retryCount + 1);
      }
      notifyListeners();
    }
  }

  /// Fetch Suggestions (On Sale)
  Future<void> fetchSuggestedProducts({int retryCount = 0}) async {
    try {
      _suggestedProducts = await _repository.getSuggestedProducts();
      _error = null;
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching suggestions: $e');
      _error = e.toString();

      if (retryCount < 2) {
        await Future.delayed(Duration(seconds: 2 * (retryCount + 1)));
        return fetchSuggestedProducts(retryCount: retryCount + 1);
      }
      notifyListeners();
    }
  }

  /// Fetch Products by Category
  Future<void> fetchProductsByCategory(String? slug) async {
    if (_isLoading) return;
    _isLoading = true;
    _categoryProducts = []; // Clear previous
    notifyListeners();
    try {
      _categoryProducts = await _repository.getProductsByCategory(slug);
    } catch (e) {
      print('❌ Error fetching category products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch Products by Brand ID
  Future<void> fetchProductsByBrandId(int brandId) async {
    if (_isLoading) return;
    _isLoading = true;
    _brandProducts = []; // Clear previous
    notifyListeners();
    try {
      _brandProducts = await _repository.getProductsByBrandId(brandId);
    } catch (e) {
      print('❌ Error fetching brand products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get product by ID
  ProductModel? getProductById(int id) {
    try {
      return _products.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }
}
