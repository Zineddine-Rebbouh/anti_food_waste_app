import 'package:dio/dio.dart';
import 'package:anti_food_waste_app/core/services/token_storage.dart';
import 'package:anti_food_waste_app/features/auth/data/models/auth_models.dart';
import 'package:anti_food_waste_app/features/auth/data/sources/auth_remote_source.dart';

/// Orchestrates auth calls and token persistence.
class AuthRepository {
  final AuthRemoteSource _remote;

  AuthRepository({AuthRemoteSource? remote})
      : _remote = remote ?? AuthRemoteSource();

  /// Logs in and stores tokens.
  /// Returns `(userType, verificationStatus)` on success or throws.
  Future<({String userType, String verificationStatus})> login(
      String email, String password) async {
    final resp =
        await _remote.login(LoginRequest(email: email, password: password));
    await TokenStorage.saveTokens(
      access: resp.access,
      refresh: resp.refresh,
      userType: resp.userType,
      verificationStatus: resp.verificationStatus,
    );
    return (userType: resp.userType, verificationStatus: resp.verificationStatus);
  }

  /// Registers and immediately logs in to obtain tokens.
  /// Returns `(userType, verificationStatus)` on success or throws.
  Future<({String userType, String verificationStatus})> register(
      RegisterRequest request) async {
    final resp = await _remote.register(request);
    await TokenStorage.saveTokens(
      access: resp.access,
      refresh: resp.refresh,
      userType: resp.userType,
      verificationStatus: resp.verificationStatus,
    );
    return (userType: resp.userType, verificationStatus: resp.verificationStatus);
  }

  /// Logs out — blacklists token on server and clears local storage.
  Future<void> logout() async {
    final refresh = await TokenStorage.getRefreshToken();
    if (refresh != null) {
      try {
        await _remote.logout(refresh);
      } on DioException {
        // Server-side logout failed (e.g. token expired) — still clear locally.
      }
    }
    await TokenStorage.clearTokens();
  }

  /// Returns stored session data if it exists, else null.
  Future<({String userType, String verificationStatus})?> getSavedSession() async {
    final userType = await TokenStorage.getUserType();
    if (userType == null) return null;
    final verificationStatus =
        await TokenStorage.getVerificationStatus() ?? 'approved';
    return (userType: userType, verificationStatus: verificationStatus);
  }
}

/// Converts a Dio error response into a readable message.
String dioErrorMessage(DioException e) {
  if (e.response != null) {
    final data = e.response!.data;
    if (data is Map) {
      // DRF returns errors as {"field": ["message"]} or {"detail": "message"}
      final values = data.values.map((v) {
        if (v is List) return v.join(' ');
        return v.toString();
      });
      return values.join(' ');
    }
    return e.response!.statusMessage ?? 'Server error';
  }
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return 'Connection timed out. Check your internet connection.';
  }
  if (e.type == DioExceptionType.connectionError) {
    return 'Cannot reach the server. Make sure the backend is running.';
  }
  return e.message ?? 'Unknown error';
}
