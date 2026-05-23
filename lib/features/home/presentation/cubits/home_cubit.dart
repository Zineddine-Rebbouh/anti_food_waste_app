import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/consumer/data/repositories/consumer_repository.dart';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';
import 'package:anti_food_waste_app/core/services/location_service.dart';
import 'package:anti_food_waste_app/core/services/wilaya_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final String locationLabel;
  const HomeLoading({this.locationLabel = 'Locating...'});

  @override
  List<Object?> get props => [locationLabel];
}

class HomeLoaded extends HomeState {
  final List<FoodListing> recommended;
  final List<FoodListing> nearBy;
  final List<FoodListing> closingSoon;
  final List<FoodListing> borderListings;
  final String userName;
  final double? userLat;
  final double? userLng;
  final String locationLabel;
  final int? wilayaCode;
  final String? wilayaName;
  final bool isExpanded;

  const HomeLoaded({
    required this.recommended,
    required this.nearBy,
    required this.closingSoon,
    required this.borderListings,
    required this.userName,
    this.userLat,
    this.userLng,
    required this.locationLabel,
    this.wilayaCode,
    this.wilayaName,
    this.isExpanded = false,
  });

  @override
  List<Object?> get props => [
        recommended,
        nearBy,
        closingSoon,
        borderListings,
        userName,
        userLat,
        userLng,
        locationLabel,
        wilayaCode,
        wilayaName,
        isExpanded,
      ];

  HomeLoaded copyWith({
    List<FoodListing>? recommended,
    List<FoodListing>? nearBy,
    List<FoodListing>? closingSoon,
    List<FoodListing>? borderListings,
    String? userName,
    double? userLat,
    double? userLng,
    String? locationLabel,
    int? wilayaCode,
    String? wilayaName,
    bool? isExpanded,
  }) {
    return HomeLoaded(
      recommended: recommended ?? this.recommended,
      nearBy: nearBy ?? this.nearBy,
      closingSoon: closingSoon ?? this.closingSoon,
      borderListings: borderListings ?? this.borderListings,
      userName: userName ?? this.userName,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      locationLabel: locationLabel ?? this.locationLabel,
      wilayaCode: wilayaCode ?? this.wilayaCode,
      wilayaName: wilayaName ?? this.wilayaName,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
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
  final WilayaService _wilayaService;
  
  double? _selectedLat;
  double? _selectedLng;
  String _locationLabel = 'Locating...';
  
  int? _currentWilayaCode;
  String? _currentWilayaName;
  bool _isExpanded = false;
  int? _radiusKm;

  String get currentLocationLabel => _locationLabel;

  HomeCubit({ConsumerRepository? repository, WilayaService? wilayaService})
      : _repository = repository ?? ConsumerRepository(),
        _wilayaService = wilayaService ?? WilayaService(),
        super(const HomeInitial());

  Future<void> _restoreCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _locationLabel = prefs.getString('last_location_label') ?? 'Locating...';
      _selectedLat = prefs.getDouble('last_lat');
      _selectedLng = prefs.getDouble('last_lng');
      _currentWilayaCode = prefs.getInt('last_wilaya_code');
      _currentWilayaName = prefs.getString('last_wilaya_name');
    } catch (_) {}
  }

  Future<void> load() async {
    await _restoreCachedLocation();
    
    if (_selectedLat != null && _selectedLng != null && 
        (_locationLabel == 'Current Location' || _locationLabel == 'Locating...' || _locationLabel == 'Unknown location')) {
      final address = await LocationService.getAddressFromCoordinates(_selectedLat!, _selectedLng!);
      if (address != null) {
        _locationLabel = address;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_location_label', address);
      }
    }

    emit(HomeLoading(locationLabel: _locationLabel));
    
    // Only attempt to fetch device GPS if we don't have a cached location
    if (_selectedLat == null || _selectedLng == null) {
      try {
        final pos = await LocationService.getCurrentPosition();
        if (pos != null) {
          _selectedLat = pos.lat;
          _selectedLng = pos.lng;
          
          final address = await LocationService.getAddressFromCoordinates(pos.lat, pos.lng);
          if (address != null) {
            _locationLabel = address;
          } else {
             _locationLabel = 'Unknown location';
          }
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('last_location_label', _locationLabel);
          await prefs.setDouble('last_lat', pos.lat);
          await prefs.setDouble('last_lng', pos.lng);
          
          final wilaya = await _wilayaService.detectWilaya(pos.lat, pos.lng);
          _currentWilayaCode = wilaya?.code;
          _currentWilayaName = wilaya?.name;
          
          if (wilaya != null) {
             await prefs.setInt('last_wilaya_code', wilaya.code);
             await prefs.setString('last_wilaya_name', wilaya.name);
          }
        } else if (_locationLabel == 'Locating...' || _locationLabel == 'Current Location') {
          _locationLabel = 'Unknown location';
        }
      } catch (_) {
        if (_locationLabel == 'Locating...' || _locationLabel == 'Current Location') {
          _locationLabel = 'Unknown location';
        }
      }
    }
    
    await _loadForCurrentSelection();
  }

  Future<void> expandToRadius(int radiusKm) async {
    _isExpanded = true;
    _radiusKm = radiusKm;
    emit(HomeLoading(locationLabel: _locationLabel));
    await _loadForCurrentSelection();
  }

  Future<void> expandToWilaya(int code, String name) async {
    _isExpanded = false;
    _currentWilayaCode = code;
    _currentWilayaName = name;
    _radiusKm = null;
    emit(HomeLoading(locationLabel: _locationLabel));
    await _loadForCurrentSelection();
  }

  Future<void> resetToMyArea() async {
    _isExpanded = false;
    _radiusKm = null;
    await load();
  }

  Future<void> useCurrentLocation() async {
    emit(const HomeLoading(locationLabel: 'Locating...'));
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null) {
        _selectedLat = pos.lat;
        _selectedLng = pos.lng;
        
        final address = await LocationService.getAddressFromCoordinates(pos.lat, pos.lng);
        if (address != null) {
          _locationLabel = address;
        } else {
          _locationLabel = 'Unknown location';
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_location_label', _locationLabel);
        await prefs.setDouble('last_lat', pos.lat);
        await prefs.setDouble('last_lng', pos.lng);
        
        final wilaya = await _wilayaService.detectWilaya(pos.lat, pos.lng);
        _currentWilayaCode = wilaya?.code;
        _currentWilayaName = wilaya?.name;
        
        if (wilaya != null) {
           await prefs.setInt('last_wilaya_code', wilaya.code);
           await prefs.setString('last_wilaya_name', wilaya.name);
        }
      } else {
        _locationLabel = 'Unknown location';
      }
    } catch (_) {
      _locationLabel = 'Unknown location';
    }
    
    await _loadForCurrentSelection();
  }

  Future<void> setSelectedLocation({
    required double lat,
    required double lng,
    required String label,
  }) async {
    _selectedLat = lat;
    _selectedLng = lng;
    _locationLabel = label;
    
    // Persist
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_location_label', label);
    await prefs.setDouble('last_lat', lat);
    await prefs.setDouble('last_lng', lng);
    
    emit(HomeLoading(locationLabel: _locationLabel));
    
    final wilaya = await _wilayaService.detectWilaya(lat, lng);
    _currentWilayaCode = wilaya?.code;
    _currentWilayaName = wilaya?.name;
    
    if (wilaya != null) {
       await prefs.setInt('last_wilaya_code', wilaya.code);
       await prefs.setString('last_wilaya_name', wilaya.name);
    }
    
    await _loadForCurrentSelection();
  }

  Future<void> _loadForCurrentSelection() async {
    try {
      final lat = _selectedLat;
      final lng = _selectedLng;

      // 1. Fetch the main feed using the new intelligent proximity endpoint
      final feedResult = await _repository.fetchFeed(
        lat: lat,
        lng: lng,
        wilayaCode: _currentWilayaCode,
        expand: _isExpanded,
        radiusKm: _radiusKm,
        sort: 'distance',
      );

      final List<FoodListing> allProximityListings = feedResult['listings'];
      // The "nearBy" list should include EVERYTHING within range, sorted by distance (already sorted by backend)
      // We keep the separate lists for legacy UI if needed, but primaryListings should be the full feed.
      final primaryListings = allProximityListings;
      final borderListings = allProximityListings.where((l) => l.isBorderArea).toList();

      // 2. Fetch other sections + profile in parallel
      final results = await Future.wait([
        _safeListings(ordering: '-created_at'), // newest → "recommended"
        _safeListings(ordering: 'pickup_end'), // closing soonest → "closing soon"
        _safeUserName(),
      ]);

      emit(HomeLoaded(
        recommended: results[0] as List<FoodListing>,
        nearBy: primaryListings,
        closingSoon: results[1] as List<FoodListing>,
        borderListings: borderListings,
        userName: results[2] as String,
        userLat: lat,
        userLng: lng,
        locationLabel: _locationLabel,
        wilayaCode: _currentWilayaCode,
        wilayaName: _currentWilayaName,
        isExpanded: _isExpanded,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  // ── Best-effort helpers ──────────────────────────────────────────────────

  Future<List<FoodListing>> _safeListings({String? ordering}) async {
    try {
      return await _repository.fetchListings(ordering: ordering);
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
