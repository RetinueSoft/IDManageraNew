/// Thrown by [ApiClient] for any non-2xx response. [fieldErrors] is populated
/// when the backend returned a `{"errors": {field: message}}` validation body
/// (see IDManager.Api's EndpointResults.ToHttpResult) - repositories surface it as
/// a [ValidationException] instead of this raw form wherever the caller cares about
/// per-field messages.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.fieldErrors});

  final String message;
  final int? statusCode;
  final Map<String, String>? fieldErrors;

  @override
  String toString() => message;
}
