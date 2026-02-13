import 'package:ztajir_furniture/core/network/api_client.dart';
import 'package:ztajir_furniture/data/models/branding_model.dart';

class BrandingRepository {
  final ApiClient _apiClient;

  BrandingRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Fetch branding data from API
  /// Endpoint: /branding
  Future<BrandingModel> getBranding() async {
    try {
      // استخدام رابط مخصص (بدون /front) لأن الروت مختلف
      // الرابط الحالي للـ API Client يضيف /api/v1/front تلقائياً (من ApiConstants.apiUrl)
      // لذلك سنستخدم Dio مباشرة أو نطلب رابطاً كاملاً إذا كانApiClient يدعم ذلك.
      //
      // الحل الأبسط: استخدام .. (للتراجع خطوة) أو مجرد path مختلف إذا كان الـ Client يسمح بذلك.
      // لكن ApiConstants.apiUrl هو BaseURL للـ Dio instance.
      //
      // بما أن ApiConstants.apiUrl = .../api/v1/front
      // ونحن نريد .../api/v1/branding
      //
      // الحل: طلب '../../branding' (للرجوع للخلف)
      final response = await _apiClient.get('../../branding');

      print('🌐 Branding API Response: ${response.data}');

      if (response.data['success'] == true) {
        return BrandingModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch branding');
      }
    } catch (e) {
      print('❌ Error fetching branding: $e');
      // Return default branding on error
      return BrandingModel.defaultBranding();
    }
  }
}
