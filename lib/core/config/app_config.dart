/// Global app configuration.
///
/// The backend is the existing Flask server (see ../career_counselling/backend).
/// On the Android emulator, `10.0.2.2` maps to the host machine's `localhost`.
/// On the iOS simulator, use `http://localhost:8080`.
/// On a physical device, pass your dev machine's LAN IP, e.g.:
///
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.42:8080
class AppConfig {
  AppConfig._();

  /// Base URL of the Flask backend. Override per-environment with --dart-define.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  /// Network timeouts.
  static const Duration connectTimeout = Duration(seconds: 30);

  /// AI generation calls (recommendations / job sections) can be slow.
  static const Duration receiveTimeout = Duration(seconds: 120);

  /// Supported UI languages: English, Hindi, Bengali (matches the web app).
  static const List<String> supportedLanguages = ['en', 'hi', 'bn'];
}
