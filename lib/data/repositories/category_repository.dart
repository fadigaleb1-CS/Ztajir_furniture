import 'package:ztajir_furniture/core/network/api_client.dart';
import 'package:ztajir_furniture/core/constants/api_constants.dart';
import 'package:ztajir_furniture/data/models/category_model.dart';

/// Category Repository - Handles all category-related API calls
class CategoryRepository {
  final ApiClient _apiClient;

  CategoryRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Fetch all categories from API
  /// Returns a list of [CategoryModel]
  Future<List<CategoryModel>> getCategories({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.categories,
        queryParameters: {'page': page},
      );

      if (response.data['success'] == true) {
        // According to user provided JSON, 'data' contains the list directly
        final List<dynamic> categoriesJson = response.data['data'];
        return CategoryModel.fromJsonList(categoriesJson);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch categories',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch a single category by ID
  Future<CategoryModel> getCategoryById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.categories}/$id');

      if (response.data['success'] == true) {
        return CategoryModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch category');
      }
    } catch (e) {
      rethrow;
    }
  }
}
