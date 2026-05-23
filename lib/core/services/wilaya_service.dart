import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anti_food_waste_app/features/consumer/data/repositories/consumer_repository.dart';

/// Handles wilaya detection, caching, and distance formatting.
class WilayaService {
  final ConsumerRepository _repository;
  static const String _cacheKey = 'cached_wilaya';
  static const Duration _cacheTtl = Duration(hours: 24);

  WilayaService({ConsumerRepository? repository})
      : _repository = repository ?? ConsumerRepository();

  /// Detects the wilaya from GPS coordinates using the backend utility.
  /// Results are cached for 24 hours.
  Future<({int code, String name})?> detectWilaya(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedStr = prefs.getString(_cacheKey);

    if (cachedStr != null) {
      final cached = jsonDecode(cachedStr) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cached['timestamp']);
      
      // If cached coordinate is very close to current, use cache
      final double cachedLat = cached['lat'];
      final double cachedLng = cached['lng'];
      final diff = (cachedLat - lat).abs() + (cachedLng - lng).abs();

      if (DateTime.now().difference(timestamp) < _cacheTtl && diff < 0.01) {
        return (
          code: cached['code'] as int,
          name: cached['name'] as String,
        );
      }
    }

    try {
      final result = await _repository.fetchWilayaFromCoords(lat, lng);
      final code = result['wilaya_code'] as int;
      final name = result['wilaya_name_fr'] as String;

      await prefs.setString(
        _cacheKey,
        jsonEncode({
          'code': code,
          'name': name,
          'lat': lat,
          'lng': lng,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return (code: code, name: name);
    } catch (e) {
      return null;
    }
  }

  /// Formats distance according to proximity rules:
  /// - < 1km: "X m away"
  /// - < 10km: "X.X km away"
  /// - >= 10km: "X km away"
  static String formatDistance(double? km) {
    if (km == null) return '';
    
    if (km < 1.0) {
      final meters = (km * 1000).round();
      return '$meters m away';
    }
    
    if (km < 10.0) {
      return '${km.toStringAsFixed(1)} km away';
    }
    
    return '${km.round()} km away';
  }

  /// Clears the cached wilaya detection.
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
