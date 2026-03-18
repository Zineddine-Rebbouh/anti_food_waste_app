import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/consumer/data/repositories/consumer_repository.dart';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';
import 'package:anti_food_waste_app/core/services/location_service.dart';

// ─── States ────────────────────────────────────────────────────────────────

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<FoodListing> recommended;
  final List<FoodListing> nearBy;
  final List<FoodListing> closingSoon;
  final String userName;
  final double? userLat;
  final double? userLng;
  final String locationLabel;

  const HomeLoaded({
    required this.recommended,
    required this.nearBy,
    required this.closingSoon,
    required this.userName,
    this.userLat,
    this.userLng,
    required this.locationLabel,
  });

  @override
  List<Object?> get props =>
      [recommended, nearBy, closingSoon, userName, userLat, userLng, locationLabel];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Cubit ─────────────────────────────────────────────────────────────────

/// Manages the consumer home screen listings and greeting name.
///
/// Calls [ConsumerRepository.fetchListings] three times with different
/// orderings to populate the three horizontal scroll sections.
/// Also attempts to obtain the device GPS position so the "near you" section
/// returns listings ordered by real proximity distance.
class HomeCubit extends Cubit<HomeState> {
  final ConsumerRepository _repository;
  double? _selectedLat;
  double? _selectedLng;
  String _locationLabel = 'Current Location';

  HomeCubit({ConsumerRepository? repository})
      : _repository = repository ?? ConsumerRepository(),
        super(const HomeInitial());

  Future<void> load() async {
    emit(const HomeLoading());
    try {
      // Try to get the device GPS position for the nearBy section.
      final pos = await LocationService.getCurrentPosition();
      _selectedLat = pos?.lat;
      _selectedLng = pos?.lng;
      _locationLabel = pos == null ? 'Unknown location' : 'Current Location';

      await _loadForCurrentSelection();
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> useCurrentLocation() async {
    emit(const HomeLoading());
    try {
      final pos = await LocationService.getCurrentPosition();
      _selectedLat = pos?.lat;
      _selectedLng = pos?.lng;
      _locationLabel = pos == null ? 'Unknown location' : 'Current Location';

      await _loadForCurrentSelection();
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> setSelectedLocation({
    required double lat,
    required double lng,
    required String label,
  }) async {
    emit(const HomeLoading());
    _selectedLat = lat;
    _selectedLng = lng;
    _locationLabel = label;
    await _loadForCurrentSelection();
  }

  Future<void> _loadForCurrentSelection() async {
    final lat = _selectedLat;
    final lng = _selectedLng;

    // Fetch three different orderings + user name in parallel.
    final results = await Future.wait([
      _safeListings(ordering: '-created_at'), // newest → "recommended"
      _safeListings(
        // real proximity → "near you"
        ordering: (lat != null && lng != null) ? 'distance' : 'discounted_price',
        lat: lat,
        lng: lng,
        radius: 10,
      ),
      _safeListings(ordering: 'pickup_end'), // closing soonest → "closing soon"
      _safeUserName(),
    ]);

    emit(HomeLoaded(
      recommended: results[0] as List<FoodListing>,
      nearBy: results[1] as List<FoodListing>,
      closingSoon: results[2] as List<FoodListing>,
      userName: results[3] as String,
      userLat: lat,
      userLng: lng,
      locationLabel: _locationLabel,
    ));
  }

  // ── Best-effort helpers ──────────────────────────────────────────────────

  Future<List<FoodListing>> _safeListings({
    String? ordering,
    double? lat,
    double? lng,
    double? radius,
  }) async {
    try {
      return await _repository.fetchListings(
        ordering: ordering,
        lat: lat,
        lng: lng,
        radius: radius,
      );
    } catch (_) {
      return [];
    }
  }

  Future<String> _safeUserName() async {
    try {
      final user = await _repository.fetchProfile();
      return user.name;
    } catch (_) {
      return '';
    }
  }
}
