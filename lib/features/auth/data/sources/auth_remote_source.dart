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
}
