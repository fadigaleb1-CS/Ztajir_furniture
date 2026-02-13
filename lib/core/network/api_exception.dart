/// API Exceptions - Custom exception classes for API error handling

/// Base API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// No Internet Connection Exception
class NoInternetException extends ApiException {
  NoInternetException()
    : super(
        message: 'No internet connection. Please check your network.',
        statusCode: null,
      );
}

/// Server Exception (5xx errors)
class ServerException extends ApiException {
  ServerException({String? message, int? statusCode})
    : super(
        message: message ?? 'Server error occurred. Please try again later.',
        statusCode: statusCode,
      );
}

/// Unauthorized Exception (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException({String? message})
    : super(
        message: message ?? 'Unauthorized. Please login again.',
        statusCode: 401,
      );
}

/// Not Found Exception (404)
class NotFoundException extends ApiException {
  NotFoundException({String? message})
    : super(message: message ?? 'Resource not found.', statusCode: 404);
}

/// Bad Request Exception (400)
class BadRequestException extends ApiException {
  BadRequestException({String? message, dynamic data})
    : super(message: message ?? 'Bad request.', statusCode: 400, data: data);
}

/// Timeout Exception
class TimeoutException extends ApiException {
  TimeoutException()
    : super(message: 'Request timeout. Please try again.', statusCode: null);
}

/// Request Cancelled Exception
class RequestCancelledException extends ApiException {
  RequestCancelledException()
    : super(message: 'Request was cancelled.', statusCode: null);
}
