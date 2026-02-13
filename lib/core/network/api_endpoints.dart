/// API Endpoints - Contains all API endpoint paths
///
/// Update these endpoints with your actual paths from Postman
class ApiEndpoints {
  // Categories
  static const String categories = '/categories';

  // Brands
  static const String brands = '/brands';

  // Products
  static const String products = '/products';
  static const String newProducts = '/products/new';
  static const String featuredProducts = '/products/featured';
  static const String recommendedProducts = '/products/recommended';

  // Cart
  static const String cart = '/cart';
  static const String addToCart = '/cart/add';
  static const String removeFromCart = '/cart/remove';
  static const String updateCart = '/cart/update';

  // Wishlist
  static const String wishlist = '/wishlist';
  static const String addToWishlist = '/wishlist/add';
  static const String removeFromWishlist = '/wishlist/remove';

  // Search
  static const String search = '/search';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
}
