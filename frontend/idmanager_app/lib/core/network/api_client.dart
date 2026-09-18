import 'package:dio/dio.dart';
import '../config.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Thin wrapper around Dio that attaches the bearer token to every request and
/// unwraps the backend's `ApiResponse { success, message, data }` envelope, turning a
/// `success: false` response (or a network/HTTP failure) into an [ApiException].
class ApiClient {
  final Dio dio;
  String? _token;

  ApiClient() : dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl)) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
    ));
  }

  void setToken(String? token) => _token = token;

  Future<T> _unwrap<T>(Future<Response<dynamic>> request, T Function(dynamic data) parse) async {
    try {
      final response = await request;
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == false) {
        throw ApiException(body['message'] as String? ?? 'Request failed.');
      }
      return parse(body['data']);
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map<String, dynamic> && body['message'] != null) {
        throw ApiException(body['message'] as String);
      }
      throw ApiException(e.message ?? 'Network error.');
    }
  }

  Future<T> getJson<T>(String path, T Function(dynamic data) parse, {Map<String, dynamic>? query}) =>
      _unwrap(dio.get(path, queryParameters: query), parse);

  Future<T> postJson<T>(String path, dynamic body, T Function(dynamic data) parse) =>
      _unwrap(dio.post(path, data: body), parse);

  Future<T> postForm<T>(String path, FormData form, T Function(dynamic data) parse) =>
      _unwrap(dio.post(path, data: form), parse);

  /// For endpoints that return a raw file (e.g. the generated card PDF) rather than
  /// the JSON envelope.
  Future<List<int>> postForBytes(String path, dynamic body) async {
    try {
      final response = await dio.post<List<int>>(
        path,
        data: body,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? [];
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Network error.');
    }
  }
}
