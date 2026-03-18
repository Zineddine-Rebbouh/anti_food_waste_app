/// Centralised configuration for the app environment.
///
/// Override values at build time with `--dart-define`:
///   flutter run --dart-define=BASE_URL=http://10.0.2.2:8000/api/v1/
///   flutter run --dart-define=BASE_URL=https://api.savefood.dz/api/v1/
///   flutter run --dart-define=ENV=prod
class AppConfig {
  AppConfig._();

  static const String _envName =
      String.fromEnvironment('ENV', defaultValue: 'dev');

  static bool get isDev => _envName != 'prod';
  static bool get isProd => _envName == 'prod';

  /// Base URL for the Django REST API.
  ///
  /// • Physical device on the same LAN: use your PC's IPv4 (from `ipconfig`).
  /// • Android emulator:               use 10.0.2.2 instead of localhost.
  /// • Production:                      set ENV=prod and BASE_URL accordingly.
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.51.30:8080/api/v1/',
  );
}
