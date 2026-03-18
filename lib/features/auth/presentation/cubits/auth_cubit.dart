import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/auth/data/models/auth_models.dart';
import 'package:anti_food_waste_app/features/auth/data/repositories/auth_repository.dart';
import 'package:anti_food_waste_app/features/auth/presentation/cubits/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit({AuthRepository? repository})
      : _repository = repository ?? AuthRepository(),
        super(const AuthInitial());

  /// Called at app startup — resumes session if a stored token exists.
  Future<void> checkAuthStatus() async {
    final session = await _repository.getSavedSession();
    if (session != null) {
      emit(AuthAuthenticated(
        session.userType,
        session.verificationStatus,
        emailVerified: session.emailVerified,
      ));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Logs in with email + password.
  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    try {
      final session = await _repository.login(email, password);
      emit(AuthAuthenticated(
        session.userType,
        session.verificationStatus,
        emailVerified: session.emailVerified,
      ));
    } on DioException catch (e) {
      emit(AuthError(dioErrorMessage(e)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Registers a new account then automatically logs in.
  Future<void> register(RegisterRequest request) async {
    emit(const AuthLoading());
    try {
      final session = await _repository.register(request);
      emit(AuthAuthenticated(
        session.userType,
        session.verificationStatus,
        emailVerified: session.emailVerified,
      ));
    } on DioException catch (e) {
      emit(AuthError(dioErrorMessage(e)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Logs out — clears local tokens and emits unauthenticated.
  Future<void> logout() async {
    emit(const AuthLoading());
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }

  // ── Email Verification ─────────────────────────────────────────────────────

  /// Submits the 6-digit OTP to verify email. On success re-emits
  /// [AuthAuthenticated] with [emailVerified] = true.
  Future<void> verifyEmail(String token) async {
    emit(const AuthLoading());
    try {
      await _repository.verifyEmail(token);
      final session = await _repository.getSavedSession();
      if (session != null) {
        emit(AuthAuthenticated(
          session.userType,
          session.verificationStatus,
          emailVerified: true,
        ));
      } else {
        emit(const AuthUnauthenticated());
      }
    } on DioException catch (e) {
      emit(AuthError(dioErrorMessage(e)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Requests a new verification OTP to be emailed to the user.
  Future<void> resendVerificationEmail() async {
    emit(const AuthLoading());
    try {
      await _repository.resendVerificationEmail();
      emit(const AuthEmailVerificationSent());
    } on DioException catch (e) {
      emit(AuthError(dioErrorMessage(e)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ── Password Reset ─────────────────────────────────────────────────────────

  /// Sends a password-reset OTP to [email]. Always navigates to the reset
  /// screen regardless (prevents email enumeration on the backend).
  Future<void> requestPasswordReset(String email) async {
    emit(const AuthLoading());
    try {
      await _repository.requestPasswordReset(email);
      emit(const AuthPasswordResetSent());
    } on DioException catch (e) {
      emit(AuthError(dioErrorMessage(e)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Submits [token] + new password pair to complete the reset.
  Future<void> resetPassword(
      String token, String newPassword, String newPasswordConfirm) async {
    emit(const AuthLoading());
    try {
      await _repository.resetPassword(token, newPassword, newPasswordConfirm);
      emit(const AuthPasswordResetSuccess());
    } on DioException catch (e) {
      emit(AuthError(dioErrorMessage(e)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
