import 'package:geolocator/geolocator.dart';

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
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // You can prompt the user to enable location services here
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
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
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      return (lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      // Timeout or platform error — try last known position
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return (lat: last.latitude, lng: last.longitude);
      } catch (_) {}
      return null;
    }
  }
}
