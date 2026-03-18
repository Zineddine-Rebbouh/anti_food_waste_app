import 'package:dio/dio.dart';
import 'package:anti_food_waste_app/core/network/api_client.dart';
import 'package:anti_food_waste_app/features/auth/data/models/auth_models.dart';

/// Raw HTTP calls to the Django auth endpoints.
class AuthRemoteSource {
  final Dio _dio;

  AuthRemoteSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  /// POST /auth/login/ → returns [AuthResponse] with JWT tokens.
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      'auth/login/',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /auth/register/ → returns [AuthResponse] with JWT tokens.
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _dio.post(
      'auth/register/',
      data: request.toJson(),
    );
    // The register endpoint returns: { message, user_id, user_type }
    // We need to immediately log in to get the tokens.
    // So after a successful registration, perform a login automatically.
    final loginResp = await login(
      LoginRequest(email: request.email, password: request.password),
    );
    return loginResp;
  }

  /// POST /auth/logout/ — blacklists the refresh token on the server.
  Future<void> logout(String refreshToken) async {
    await _dio.post(
      'auth/logout/',
      data: {'refresh': refreshToken},
    );
  }

  /// POST /auth/verify-email/ — verifies email with a 6-digit OTP.
  Future<void> verifyEmail(String token) async {
    await _dio.post('auth/verify-email/', data: {'token': token});
  }

  /// POST /auth/resend-verification/ — resends OTP (requires auth header).
  Future<void> resendVerificationEmail() async {
    await _dio.post('auth/resend-verification/');
  }

  /// POST /auth/password-reset/ — requests a password-reset OTP email.
  Future<void> requestPasswordReset(String email) async {
    await _dio.post('auth/password-reset/', data: {'email': email});
  }

  /// POST /auth/password-reset/confirm/ — sets a new password using the OTP.
  Future<void> resetPassword(ResetPasswordRequest request) async {
    await _dio.post('auth/password-reset/confirm/', data: request.toJson());
  }
}
