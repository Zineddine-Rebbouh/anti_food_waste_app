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
  Future<({String userType, String verificationStatus, bool emailVerified})>
      login(String email, String password) async {
    final resp =
        await _remote.login(LoginRequest(email: email, password: password));
    await TokenStorage.saveTokens(
      access: resp.access,
      refresh: resp.refresh,
      userType: resp.userType,
      verificationStatus: resp.verificationStatus,
      emailVerified: resp.emailVerified,
      email: resp.email,
    );
    return (
      userType: resp.userType,
      verificationStatus: resp.verificationStatus,
      emailVerified: resp.emailVerified,
    );
  }

  /// Registers and immediately logs in to obtain tokens.
  Future<({String userType, String verificationStatus, bool emailVerified})>
      register(RegisterRequest request) async {
    final resp = await _remote.register(request);
    await TokenStorage.saveTokens(
      access: resp.access,
      refresh: resp.refresh,
      userType: resp.userType,
      verificationStatus: resp.verificationStatus,
      emailVerified: resp.emailVerified,
      email: resp.email,
    );
    return (
      userType: resp.userType,
      verificationStatus: resp.verificationStatus,
      emailVerified: resp.emailVerified,
    );
  }

  /// Logs out — blacklists token on server and clears local storage.
  Future<void> logout() async {
    final refresh = await TokenStorage.getRefreshToken();
    if (refresh != null) {
      try {
        await _remote.logout(refresh);
      } on DioException {
        // Server-side logout failed — still clear locally.
      }
    }
    await TokenStorage.clearTokens();
  }

  /// Returns stored session data if it exists, else null.
  Future<
      ({
        String userType,
        String verificationStatus,
        bool emailVerified,
        String email,
      })?> getSavedSession() async {
    final userType = await TokenStorage.getUserType();
    if (userType == null) return null;
    final verificationStatus =
        await TokenStorage.getVerificationStatus() ?? 'approved';
    final emailVerified = await TokenStorage.getEmailVerified();
    final email = await TokenStorage.getEmail();
    return (
      userType: userType,
      verificationStatus: verificationStatus,
      emailVerified: emailVerified,
      email: email,
    );
  }

  /// Verifies email using the 6-digit OTP and marks it verified in storage.
  Future<void> verifyEmail(String token) async {
    await _remote.verifyEmail(token);
    await TokenStorage.setEmailVerified();
  }

  /// Resends the email verification OTP (requires stored access token).
  Future<void> resendVerificationEmail() async {
    await _remote.resendVerificationEmail();
  }

  /// Requests a password-reset OTP email. Always succeeds (anti-enumeration).
  Future<void> requestPasswordReset(String email) async {
    await _remote.requestPasswordReset(email);
  }

  /// Submits the OTP + new password to complete a password reset.
  Future<void> resetPassword(
      String token, String newPassword, String newPasswordConfirm) async {
    await _remote.resetPassword(
      ResetPasswordRequest(
        token: token,
        newPassword: newPassword,
        newPasswordConfirm: newPasswordConfirm,
      ),
    );
  }
}

/// Converts a Dio error response into a readable message.
String dioErrorMessage(DioException e) {
  if (e.response != null) {
    final data = e.response!.data;
    if (data is Map) {
      // Django standard format: {"error": {"code": "...", "message": "...", "details": ...}}
      final error = data['error'];
      if (error is Map) {
        final details = error['details'];
        if (details is Map && (details as Map).isNotEmpty) {
          final msgs = details.values.map((v) {
            if (v is List) return (v as List).join(' ');
            return v.toString();
          });
          return msgs.join(' ');
        }
        final message = error['message'];
        if (message != null) return message.toString();
      }
      // DRF field-level errors: {"field": ["error"]}
      final values = data.values.map((v) {
        if (v is List) return (v as List).join(' ');
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
