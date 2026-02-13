class CouponModel {
  final String code;
  final double discountPercentage; // e.g., 0.20 for 20%
  final String description;
  final DateTime expiryDate;
  final bool isActive;

  CouponModel({
    required this.code,
    required this.discountPercentage,
    required this.description,
    required this.expiryDate,
    this.isActive = true,
  });

  bool get isValid {
    return isActive && DateTime.now().isBefore(expiryDate);
  }
}
