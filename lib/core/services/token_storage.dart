import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure, encrypted key-value store for JWT tokens and user metadata.
class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage();

  static const _keyAccess = 'access_token';
  static const _keyRefresh = 'refresh_token';
  static const _keyUserType = 'user_type';
  static const _keyVerificationStatus = 'verification_status';

  static Future<void> saveTokens({
    required String access,
    required String refresh,
    required String userType,
    required String verificationStatus,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccess, value: access),
      _storage.write(key: _keyRefresh, value: refresh),
      _storage.write(key: _keyUserType, value: userType),
      _storage.write(key: _keyVerificationStatus, value: verificationStatus),
    ]);
  }

  static Future<String?> getAccessToken() =>
      _storage.read(key: _keyAccess);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: _keyRefresh);

  static Future<String?> getUserType() =>
      _storage.read(key: _keyUserType);

  static Future<String?> getVerificationStatus() =>
      _storage.read(key: _keyVerificationStatus);

  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _keyAccess),
      _storage.delete(key: _keyRefresh),
      _storage.delete(key: _keyUserType),
      _storage.delete(key: _keyVerificationStatus),
    ]);
  }
}
