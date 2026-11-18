/// Custom exception class representing errors encountered during API calls.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic responseData;
  final bool isNetworkError;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.responseData,
    this.isNetworkError = false,
  });

  /// Specific error code for restricted category/feature access
  bool get isLoginRequired =>
      errorCode == 'LOGIN_REQUIRED' ||
      statusCode == 403 ||
      message.toLowerCase().contains('login required') ||
      message.toLowerCase().contains('reserved for kids tv members');

  bool get isUnauthenticated =>
      statusCode == 401 ||
      errorCode == 'UNAUTHENTICATED' ||
      message.toLowerCase().contains('unauthenticated');

  bool get isNotFound => statusCode == 404;

  @override
  String toString() {
    if (errorCode != null) {
      return 'ApiException: [$errorCode] $message (status: $statusCode)';
    }
    return 'ApiException: $message (status: $statusCode)';
  }
}
