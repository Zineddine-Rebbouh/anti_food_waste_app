import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Provides GPS location access with permission handling.
///
/// Call [getCurrentPosition] to attempt to get the device's current location.
/// Returns `null` if permission is denied or location is unavailable.
class LocationService {
  const LocationService._();

  /// Requests location permission if not already granted, then returns the
  /// current GPS position.  Returns `null` on any failure (denied, disabled,
  /// timeout, etc.) so callers can fall back gracefully.
  static Future<({double lat, double lng})?> getCurrentPosition() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // You can prompt the user to enable location services here
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return null;
    }

    try {
      // Short timeout for fresh position, then fallback to last known
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );
      return (lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return (lat: last.latitude, lng: last.longitude);
      } catch (_) {}
      return null;
    }
  }

  /// Converts coordinates into a human-readable address (e.g. "Sidi M'Hamed, Algiers").
  static Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        // Construct a preferred short label: "Sublocality, City" or "Locality, AdministrativeArea"
        final name = p.subLocality ?? p.locality ?? p.name ?? '';
        final city = p.subAdministrativeArea ?? p.administrativeArea ?? '';
        
        if (name.isNotEmpty && city.isNotEmpty) {
          if (name == city) return name;
          return '$name, $city';
        }
        return name.isNotEmpty ? name : (city.isNotEmpty ? city : null);
      }
    } catch (_) {}
    return null;
  }
}
