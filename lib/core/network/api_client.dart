import 'package:dio/dio.dart';
import 'package:anti_food_waste_app/core/config/app_config.dart';
import 'package:anti_food_waste_app/core/services/token_storage.dart';

class ApiClient {
  ApiClient._();

  static final Dio dio = _build();

  static Dio _build() {
    final d = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    d.interceptors.add(_AuthInterceptor());
    d.interceptors.add(_TokenRefreshInterceptor(d));
    d.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('[DIO] $obj'),
    ));
    return d;
  }
}

/// Attaches the stored JWT access token to every outgoing request,
/// except for fully-public endpoints that must not carry a Bearer token.
class _AuthInterceptor extends Interceptor {
  static const _publicPaths = {
    'auth/login/',
    'auth/register/',
    'auth/verify-email/',
    'auth/resend-verification/',
    'auth/password-reset/',
    'auth/password-reset/confirm/',
    'auth/refresh/',
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isPublic = _publicPaths.any((p) => options.path.endsWith(p));
    if (!isPublic) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}

/// Silently refreshes the access token on 401 responses and retries the
/// original request once.  On refresh failure the tokens are cleared so the
/// app can redirect the user to the login screen.
class _TokenRefreshInterceptor extends Interceptor {
  final Dio _mainDio;

  _TokenRefreshInterceptor(this._mainDio);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Never try to refresh when the failing call was a token endpoint or
    // when it is already the retried request (prevents an infinite loop).
    final path = err.requestOptions.path;
    if (path.endsWith('auth/refresh/') || path.endsWith('auth/login/')) {
      return handler.next(err);
    }
    if (err.requestOptions.extra['isRetry'] == true) {
      return handler.next(err);
    }

    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) {
      await TokenStorage.clearTokens();
      return handler.next(err);
    }

    // Use a fresh Dio instance so this interceptor is not triggered again.
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: _mainDio.options.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    try {
      final res = await refreshDio.post(
        'auth/refresh/',
        data: {'refresh': refreshToken},
      );

      final newAccess = res.data['access'] as String;
      final newRefresh = (res.data['refresh'] as String?) ?? refreshToken;

      await TokenStorage.saveTokens(
        access: newAccess,
        refresh: newRefresh,
        userType: await TokenStorage.getUserType() ?? '',
        verificationStatus: await TokenStorage.getVerificationStatus() ?? '',
        emailVerified: await TokenStorage.getEmailVerified(),
        email: await TokenStorage.getEmail(),
      );

      // Retry the original request with the refreshed token.
      // Mark as retry so the interceptor does not fire again on another 401.
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
      err.requestOptions.extra['isRetry'] = true;
      final retry = await _mainDio.fetch(err.requestOptions);
      return handler.resolve(retry);
    } catch (_) {
      await TokenStorage.clearTokens();
      return handler.next(err);
    }
  }
}

