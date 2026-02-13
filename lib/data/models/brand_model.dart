import 'package:ztajir_furniture/core/constants/api_constants.dart';

class BrandModel {
  final int id;
  final String name;
  final String slug;
  final String? logo;
  final String? description;
  final bool isFeatured;

  BrandModel({
    required this.id,
    required this.name,
    required this.slug,
    this.logo,
    this.description,
    this.isFeatured = false,
  });

  /// Create BrandModel from JSON (API response)
  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      logo: json['logo'] as String?,
      description: json['description'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
    );
  }

  /// Convert BrandModel to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'logo': logo,
      'description': description,
      'is_featured': isFeatured,
    };
  }

  /// Create a list of BrandModel from JSON list
  static List<BrandModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => BrandModel.fromJson(json)).toList();
  }

  /// Get full logo URL (for displaying images)
  String? get logoUrl {
    if (logo == null || logo!.isEmpty) return null;
    // If logo is already a full URL, return it as-is
    if (logo!.startsWith('http')) return logo;
    // Otherwise, prepend the base URL
    return '${ApiConstants.storageUrl}/$logo';
  }

  /// Backward compatibility - returns logo for old code using 'image'
  String get image => logoUrl ?? '';
}
