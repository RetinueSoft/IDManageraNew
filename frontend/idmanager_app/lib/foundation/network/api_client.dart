import 'package:dio/dio.dart';

import '../config.dart';
import 'api_exception.dart';

/// Base HTTP client for talking to the IDManager API (Foundation Engine
/// responsibility - API client initialization). This app is fully online, so every
/// Infrastructure repository goes through this client directly; there is no local
/// database or synchronization layer to fall back to.
class ApiClient {
  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio dio;
  String? _token;

  void setToken(String? token) => _token = token;

  /// Wraps [request], turning a Dio failure into an [ApiException] with the
  /// backend's `{error}` / `{errors: {field: msg}}` body parsed out.
  Future<T> guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final body = e.response?.data;
    final statusCode = e.response?.statusCode;

    if (body is Map<String, dynamic>) {
      if (body['errors'] is Map) {
        final fieldErrors = (body['errors'] as Map).map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
        return ApiException(
          'Please correct the highlighted fields.',
          statusCode: statusCode,
          fieldErrors: fieldErrors,
        );
      }
      if (body['error'] != null) {
        return ApiException(body['error'].toString(), statusCode: statusCode);
      }
    }
    return ApiException(e.message ?? 'Network error.', statusCode: statusCode);
  }
}
