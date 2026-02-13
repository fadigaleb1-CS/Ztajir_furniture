class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String image;
  final String? description;
  final int? parentId;
  final List<CategoryModel>? children;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
    this.description,
    this.parentId,
    this.children,
  });

  /// Create CategoryModel from JSON (API response)
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      image: json['image'] as String? ?? '',
      description: json['description'] as String?,
      parentId: json['parent_id'] as int?,
      children: json['children'] != null
          ? (json['children'] as List)
                .map((e) => CategoryModel.fromJson(e))
                .toList()
          : [],
    );
  }

  /// Convert CategoryModel to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'image': image,
      'description': description,
      'parent_id': parentId,
      'children': children?.map((e) => e.toJson()).toList(),
    };
  }

  /// Create a list of CategoryModel from JSON list
  static List<CategoryModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
  }
}
