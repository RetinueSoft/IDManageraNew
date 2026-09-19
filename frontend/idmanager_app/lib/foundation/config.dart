/// Backend base URL (Foundation Engine responsibility: API client
/// initialization). Override at build/run time with:
///   flutter run --dart-define=API_BASE_URL=https://your-api-host/api
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5080/api',
  );
}
