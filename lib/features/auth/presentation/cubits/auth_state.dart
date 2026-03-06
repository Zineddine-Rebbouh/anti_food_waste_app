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

/// Auth operation in progress (login / register / logout).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated. [userType] is "consumer", "merchant", or "charity".
/// [verificationStatus] is "approved", "pending", "rejected", or "suspended".
class AuthAuthenticated extends AuthState {
  final String userType;
  final String verificationStatus;

  const AuthAuthenticated(this.userType, this.verificationStatus);

  bool get isApproved => verificationStatus == 'approved';

  @override
  List<Object?> get props => [userType, verificationStatus];
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
