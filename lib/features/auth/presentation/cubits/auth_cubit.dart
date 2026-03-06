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
      emit(AuthAuthenticated(session.userType, session.verificationStatus));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Logs in with email + password.
  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    try {
      final session = await _repository.login(email, password);
      emit(AuthAuthenticated(session.userType, session.verificationStatus));
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
      emit(AuthAuthenticated(session.userType, session.verificationStatus));
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
}
