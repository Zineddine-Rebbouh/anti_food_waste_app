import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/profile/domain/models/app_user.dart';

// ─── States ────────────────────────────────────────────────────────────────

/// Base state for the [ProfileCubit].
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action is dispatched.
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Emitted while the profile data is being fetched.
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Emitted when the profile has been successfully loaded.
class ProfileLoaded extends ProfileState {
  final AppUser user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];

  ProfileLoaded copyWith({AppUser? user}) =>
      ProfileLoaded(user ?? this.user);
}

/// Emitted when an error occurs during profile operations.
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Cubit ─────────────────────────────────────────────────────────────────

/// Manages profile-related state.
///
/// Currently backed by [AppUser.mock]. Replace the data layer calls with
/// real repository methods when integrating with a backend.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileInitial());

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Loads the user profile.
  ///
  /// Emits [ProfileLoading] → [ProfileLoaded] (or [ProfileError] on failure).
  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    try {
      // Simulate network latency; replace with a real repository call.
      await Future<void>.delayed(const Duration(milliseconds: 500));
      emit(const ProfileLoaded(AppUser.mock));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// Updates the user's avatar with the image at [path].
  ///
  /// In production this should upload the file and refresh the profile URL.
  Future<void> updateAvatar(String path) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    try {
      // TODO: Upload file to storage and obtain the remote URL.
      // For now, optimistically keep the current user data.
      emit(current.copyWith(user: current.user));
    } catch (e) {
      emit(ProfileError(e.toString()));
      // Restore previous state so the UI can recover.
      emit(current);
    }
  }

  /// Toggles the favourite status for [listingId].
  ///
  /// In production this should persist the change via the repository.
  void toggleFavorite(String listingId) {
    // TODO: Implement favourite toggling with backend sync.
  }
}
