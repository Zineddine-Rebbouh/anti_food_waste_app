import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no auth check has been performed yet.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Auth operation in progress (login / register / logout / verify / reset).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated.
/// [userType] — "consumer" | "merchant" | "charity".
/// [verificationStatus] — "approved" | "pending" | "rejected" | "suspended".
/// [emailVerified] — whether the user has confirmed their email address.
class AuthAuthenticated extends AuthState {
  final String userType;
  final String verificationStatus;
  final bool emailVerified;

  const AuthAuthenticated(
    this.userType,
    this.verificationStatus, {
    this.emailVerified = true,
  });

  /// True only when merchant/charity has been approved by admin.
  bool get isApproved => verificationStatus == 'approved';

  /// True when a consumer has not yet verified their email.
  bool get needsEmailVerification =>
      !emailVerified && userType == 'consumer';

  @override
  List<Object?> get props => [userType, verificationStatus, emailVerified];
}

/// No active session — user must log in.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An auth operation failed. [message] is a human-readable error.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted after a resend-verification API call succeeds.
/// UI should show a "Code resent" confirmation without navigating away.
class AuthEmailVerificationSent extends AuthState {
  const AuthEmailVerificationSent();
}

/// Emitted after `requestPasswordReset` — always fires (anti-enumeration).
/// UI should navigate to the "Enter reset code" screen.
class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

/// Emitted after a successful password reset.
/// UI should navigate to the login screen.
class AuthPasswordResetSuccess extends AuthState {
  const AuthPasswordResetSuccess();
}
