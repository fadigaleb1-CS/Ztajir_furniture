import 'package:ztajir_furniture/core/network/api_client.dart';
import 'package:ztajir_furniture/data/models/product_model.dart';
import 'package:ztajir_furniture/core/constants/api_constants.dart';

/// Product Repository - Handles all product-related API calls
class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<ProductModel>> getProducts({
    int page = 1,
    double? minPrice,
    double? maxPrice,
    String? sort,
    String? search, // Added search param
    int? limit, // Added limit/per_page param
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page};

      if (limit != null) queryParams['per_page'] = limit;

      // Force Params to String to avoid any type confusion on Backend
      if (minPrice != null)
        queryParams['min_price'] = minPrice.toInt().toString();
      if (maxPrice != null)
        queryParams['max_price'] = maxPrice.toInt().toString();
      if (sort != null) queryParams['sort'] = sort;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      // Debugging: Print All Params
      print('🚀 [API START] Fetching Products');
      print('🚀 Query Params: $queryParams');
      if (search != null) print('🚀 Search Term: "$search"');
      if (minPrice != null) print('🚀 Min Price: $minPrice');
      if (maxPrice != null) print('🚀 Max Price: $maxPrice');

      final response = await _apiClient.get(
        ApiConstants.products,
        queryParameters: queryParams,
      );

      print('🚀 [API RESPONSE] Status: ${response.statusCode}');
      // print('🚀 [API URL]: ${response.realUri}'); // If using Dio, realUri shows the final URL

      if (response.data['success'] == true) {
        final List<dynamic> productsJson = response.data['data']['data'];
        print('🚀 Found ${productsJson.length} products');
        return ProductModel.fromJsonList(productsJson);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch products');
      }
    } catch (e) {
      print('🚀 Error fetching products: $e');
      rethrow;
    }
  }

  /// Get Filter Options (Sorting)
  Future<Map<String, String>> getFilterOptions() async {
    try {
      final response = await _apiClient.get(ApiConstants.filtersOptions);

      if (response.data['success'] == true) {
        final Map<String, dynamic> sortOptions =
            response.data['data']['sort_options'];

        // تصفية الخيارات لإزالة خيارات الاسم
        // نسمح فقط بـ: latest, price_asc, price_desc
        final Map<String, String> filteredOptions = {};
        sortOptions.forEach((key, value) {
          if (key == 'latest' || key == 'price_asc' || key == 'price_desc') {
            filteredOptions[key] = value.toString();
          }
        });

        // إذا لم نجد أي خيارات مطابقة، نرجع الافتراضي لتجنب قائمة فارغة
        if (filteredOptions.isEmpty) {
          return {
            'latest': 'الأحدث',
            'price_asc': 'السعر: من الأقل للأعلى',
            'price_desc': 'السعر: من الأعلى للأقل',
          };
        }

        return filteredOptions;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch filter options',
        );
      }
    } catch (e) {
      // Return default options if API fails
      return {
        'latest': 'الأحدث',
        'price_asc': 'السعر: من الأقل للأعلى',
        'price_desc': 'السعر: من الأعلى للأقل',
      };
    }
  }

  /// 1. New Arrivals: /home/products/new?limit=8
  Future<List<ProductModel>> getNewProducts() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.homeProductsNew,
        queryParameters: {'limit': 8},
      );
      if (response.data['success'] == true) {
        return ProductModel.fromJsonList(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 2. Suggestions (On Sale): /home/products/on-sale?limit=8
  Future<List<ProductModel>> getSuggestedProducts() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.homeProductsOnSale,
        queryParameters: {'limit': 8},
      );
      if (response.data['success'] == true) {
        return ProductModel.fromJsonList(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 3. Most Popular (Featured): /home/products/featured?limit=8
  Future<List<ProductModel>> getMostPopularProducts() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.homeProductsFeatured,
        queryParameters: {'limit': 8},
      );
      if (response.data['success'] == true) {
        return ProductModel.fromJsonList(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get Products by Category Slug
  Future<List<ProductModel>> getProductsByCategory(String? slug) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.products,
        queryParameters: slug != null ? {'category_slug': slug} : {},
      );

      if (response.data['success'] == true) {
        // Data nested in data.data usually for pagination
        var data = response.data['data'];
        if (data is Map && data.containsKey('data')) {
          return ProductModel.fromJsonList(data['data']);
        } else if (data is List) {
          return ProductModel.fromJsonList(data);
        }
        return [];
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get Products by Brand ID
  Future<List<ProductModel>> getProductsByBrandId(int brandId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.products,
        queryParameters: {'brand_id': brandId},
      );

      if (response.data['success'] == true) {
        var data = response.data['data'];
        if (data is Map && data.containsKey('data')) {
          return ProductModel.fromJsonList(data['data']);
        } else if (data is List) {
          return ProductModel.fromJsonList(data);
        }
        return [];
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
