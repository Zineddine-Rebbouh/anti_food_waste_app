import 'package:dio/dio.dart';
import 'package:anti_food_waste_app/core/services/token_storage.dart';

/// Base URL for the Django backend.
///
/// Android emulator maps 10.0.2.2 → host machine's localhost.
/// Physical device: use your PC's LAN IP (run `ipconfig` and look for IPv4).
const String _baseUrl = 'http://192.168.140.136:8000/api/v1/';

class ApiClient {
  ApiClient._();

  static final Dio dio = _build();

  static Dio _build() {
    final d = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    d.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('[DIO] $obj'),
    ));
    d.interceptors.add(_AuthInterceptor());
    return d;
  }
}

/// Attaches the stored JWT access token to every outgoing request.
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
