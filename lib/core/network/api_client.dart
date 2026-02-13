import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ztajir_furniture/core/constants/api_constants.dart';
import 'package:ztajir_furniture/core/network/api_exception.dart';

/// API Client - Dio wrapper for making HTTP requests
///
/// This class provides a centralized way to make API calls with:
/// - Automatic error handling
/// - Request/Response interceptors
/// - Token management
class ApiClient {
  late final Dio _dio;
  String? _authToken;

  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants
            .apiUrl, // تم التصحيح: استخدام apiUrl بدلاً من baseUrl لتشمل /api/v1/front
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
        },
      ),
    );

    _setupInterceptors();
    _loadTokenFromPrefs(); // Load token
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ensure token is loaded
          if (_authToken == null) {
            final prefs = await SharedPreferences.getInstance();
            _authToken = prefs.getString('auth_token');
            if (_authToken != null) {
              print('🔐 Auth Token Loaded (Interceptor): $_authToken');
            }
          }

          // Add auth token if available (skip if request has skipAuth flag)
          final skipAuth = options.extra['skipAuth'] == true;
          if (!skipAuth && _authToken != null) {
            options.headers[ApiConstants.authorizationHeader] =
                '${ApiConstants.bearerPrefix}$_authToken';
          }

          // Log request (for debugging)
          print('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
          print('🌐 FULL URI: ${options.uri}');
          print('🌐 Query Params: ${options.queryParameters}');

          handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response (for debugging)
          print(
            '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );

          handler.next(response);
        },
        onError: (error, handler) {
          // Log error (for debugging)
          print(
            '❌ ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
          );
          print('❌ ERROR MESSAGE: ${error.message}');
          if (error.response?.data != null) {
            print('❌ ERROR DATA: ${error.response?.data}');
          }

          handler.next(error);
        },
      ),
    );
  }

  /// Set authentication token
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Clear authentication token
  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> _loadTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    if (_authToken != null) {
      print('🔐 Auth Token Loaded: $_authToken');
    }
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to custom exceptions
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();

      case DioExceptionType.connectionError:
        return NoInternetException();

      case DioExceptionType.cancel:
        return RequestCancelledException();

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      default:
        return ApiException(
          message: error.message ?? 'Unknown error occurred',
          statusCode: error.response?.statusCode,
        );
    }
  }

  /// Handle HTTP response errors
  ApiException _handleResponseError(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final data = response?.data;

    // Try to extract error message from response
    String? message;
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? data['msg'];
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(message: message, data: data);
      case 401:
        return UnauthorizedException(message: message);
      case 404:
        return NotFoundException(message: message);
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(message: message, statusCode: statusCode);
      default:
        return ApiException(
          message: message ?? 'Error occurred',
          statusCode: statusCode,
          data: data,
        );
    }
  }
}
