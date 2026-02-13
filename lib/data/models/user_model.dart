class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final String? phone;

  String get name => '$firstName $lastName';

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    this.phone,
  });

  /// Create UserModel from JSON (API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar'] ?? json['avatar_url'],
      phone: json['phone'],
    );
  }

  /// Convert UserModel to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'avatar': avatarUrl,
      'phone': phone,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? avatarUrl,
    String? phone,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
    );
  }
}
