class ApiConstants {
  static const String baseUrl = 'https://furniture-store.ztajir.com';
  static const String apiVersion = '/api/v1/front';

  // Base API URL
  static const String apiUrl = '$baseUrl$apiVersion';
  static const String storageUrl = '$baseUrl/storage';

  // Network Configuration
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';

  // Auth Endpoints
  static const String login = '$apiUrl/auth/login';
  static const String register = '$apiUrl/auth/register';
  static const String logout = '$apiUrl/auth/logout';
  static const String profile = '$apiUrl/auth/profile';
  static const String user = '$apiUrl/auth/user';// Added user endpoint if needed

  // Product Endpoints
  static const String products = '$apiUrl/products';
  static const String categories = '$apiUrl/categories';
  static const String brands = '$apiUrl/brands';
  static const String sliders = '$apiUrl/sliders';
  static const String filtersOptions = '$apiUrl/products/filters';

  // Home Products
  static const String homeProductsNew = '$apiUrl/home/products/new';
  static const String homeProductsOnSale = '$apiUrl/home/products/on-sale';
  static const String homeProductsFeatured = '$apiUrl/home/products/featured';

  // Cart & Order
  static const String checkCoupon = '$apiUrl/coupons/check';
  static const String orders = '$apiUrl/orders';
  static const String checkout = '$apiUrl/checkout';
  static const String cart = '$apiUrl/cart';
  static const String cartItems = '$apiUrl/cart/items';
}
