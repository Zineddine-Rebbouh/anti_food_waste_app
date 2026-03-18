import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/consumer/data/repositories/consumer_repository.dart';
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

/// Emitted while an update operation is in flight.
class ProfileUpdating extends ProfileState {
  final AppUser user;
  const ProfileUpdating(this.user);

  @override
  List<Object?> get props => [user];
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
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileInitial());

  final _repo = ConsumerRepository();

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Loads the user profile from the backend API.
  ///
  /// Emits [ProfileLoading] → [ProfileLoaded] (or [ProfileError] on failure).
  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    try {
      final user = await _repo.fetchProfile();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// Updates the user's profile fields and refreshes state.
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(ProfileUpdating(current.user));
    try {
      final updated = await _repo.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      emit(ProfileLoaded(updated));
    } catch (e) {
      // Restore previous loaded state so the UI still shows data
      emit(current);
      rethrow;
    }
  }

  /// Updates the user's avatar with the image at [path].
  ///
  /// Uploads the file to the backend and updates avatar_url.
  Future<void> updateAvatar(String path) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(ProfileUpdating(current.user));
    try {
      final avatarUrl = await _repo.uploadAvatar(path);
      final updated = current.user.copyWith(avatarUrl: avatarUrl);
      emit(ProfileLoaded(updated));
    } catch (e) {
      emit(current);
      rethrow;
    }
  }

  /// Toggles the favourite status for [listingId].
  ///
  /// In production this should persist the change via the repository.
  void toggleFavorite(String listingId) {
    // TODO: Implement favourite toggling with backend sync.
  }
}
