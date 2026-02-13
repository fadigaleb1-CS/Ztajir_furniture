import 'package:ztajir_furniture/core/network/api_client.dart';
import 'package:ztajir_furniture/core/constants/api_constants.dart';
import 'package:ztajir_furniture/data/models/brand_model.dart';

/// Brand Repository - Handles all brand-related API calls
class BrandRepository {
  final ApiClient _apiClient;

  BrandRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Fetch all brands from API
  /// Returns a list of [BrandModel]
  Future<List<BrandModel>> getBrands({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.brands,
        queryParameters: {'page': page},
      );

      if (response.data['success'] == true) {
        final List<dynamic> brandsJson = response.data['data']['data'];
        return BrandModel.fromJsonList(brandsJson);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch brands');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch a single brand by ID
  Future<BrandModel> getBrandById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.brands}/$id');

      if (response.data['success'] == true) {
        return BrandModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch brand');
      }
    } catch (e) {
      rethrow;
    }
  }
}
