import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio _dio;
  String? Function()? _tokenProvider;

  ApiClient({
    String? baseUrl,
    String? Function()? tokenProvider,
  }) {
    _tokenProvider = tokenProvider;
    final resolvedBaseUrl = baseUrl ?? EnvConfig.apiBaseUrl;

    _dio = Dio(
      BaseOptions(
        baseUrl: resolvedBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Attach Sanctum Bearer token if available
          final token = _tokenProvider?.call();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          final apiException = _transformDioException(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: apiException,
              type: error.type,
              response: error.response,
              message: apiException.message,
            ),
          );
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint('[API] $obj'),
        ),
      );
    }
  }

  void updateTokenProvider(String? Function() tokenProvider) {
    _tokenProvider = tokenProvider;
  }

  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  ApiException _transformDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.error is SocketException) {
      return const ApiException(
        message: 'Unable to connect to server. Please check your internet connection.',
        isNetworkError: true,
      );
    }

    final response = e.response;
    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final message = data['message'] as String? ??
          data['error'] as String? ??
          'Request failed with status ${response.statusCode}';
      final errorCode = data['error_code'] as String?;

      return ApiException(
        message: message,
        statusCode: response.statusCode,
        errorCode: errorCode,
        responseData: data,
      );
    }

    return ApiException(
      message: e.message ?? 'An unexpected network error occurred.',
      statusCode: response?.statusCode,
      isNetworkError: false,
    );
  }

  // GET
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters, options: options);
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw _transformDioException(e);
    }
  }

  // POST
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw _transformDioException(e);
    }
  }

  // PUT
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw _transformDioException(e);
    }
  }

  // DELETE
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw _transformDioException(e);
    }
  }

  // Multipart upload (e.g. for avatar)
  Future<dynamic> uploadFile(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (extraData != null) ...extraData,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw _transformDioException(e);
    }
  }
}
