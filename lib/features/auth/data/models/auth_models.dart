/// Request / response models for the auth API.
/// No code-generation required — plain Dart classes.

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String email;
  final String phone;
  final String password;
  final String passwordConfirm;
  final String userType;
  final Map<String, dynamic>? profileData;

  const RegisterRequest({
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirm,
    required this.userType,
    this.profileData,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirm': passwordConfirm,
      'user_type': userType,
      if (profileData != null && profileData!.isNotEmpty)
        'profile_data': profileData,
    };
  }
}

class AuthResponse {
  final String access;
  final String refresh;
  final String userId;
  final String userType;
  final String email;
  final bool emailVerified;

  /// "approved" | "pending" | "rejected" | "suspended"
  /// Always "approved" for consumers.
  final String verificationStatus;

  const AuthResponse({
    required this.access,
    required this.refresh,
    required this.userId,
    required this.userType,
    required this.email,
    required this.emailVerified,
    required this.verificationStatus,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      userId: json['user_id'] as String,
      userType: json['user_type'] as String,
      email: json['email'] as String,
      emailVerified: json['email_verified'] as bool? ?? false,
      verificationStatus: json['verification_status'] as String? ?? 'approved',
    );
  }
}

class ForgotPasswordRequest {
  final String email;
  const ForgotPasswordRequest({required this.email});
  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordRequest {
  final String token;
  final String newPassword;
  final String newPasswordConfirm;

  const ResetPasswordRequest({
    required this.token,
    required this.newPassword,
    required this.newPasswordConfirm,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'new_password': newPassword,
        'new_password_confirm': newPasswordConfirm,
      };
}
