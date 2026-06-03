/// Global app configuration.
///
/// The backend is the Flask server in `backend/`, deployed on Render and backed
/// by MongoDB Atlas. The default points at the live cloud server, so the app
/// works on any device, anywhere, with no LAN setup.
///
/// To target a backend running on your own machine instead, override at build:
///   `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080`   (Android emulator)
///   `flutter run --dart-define=API_BASE_URL=http://YOUR-PC-LAN-IP:8080` (physical device)
class AppConfig {
  AppConfig._();

  /// Base URL of the backend. Defaults to the deployed Render service;
  /// override per-environment with --dart-define=API_BASE_URL=...
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://career-counselling-backend-ku30.onrender.com',
  );

  /// Network timeouts.
  static const Duration connectTimeout = Duration(seconds: 30);

  /// AI generation calls (recommendations / job sections) can be slow.
  static const Duration receiveTimeout = Duration(seconds: 120);

  /// Supported UI languages: English, Hindi, Bengali (matches the web app).
  static const List<String> supportedLanguages = ['en', 'hi', 'bn'];
}
