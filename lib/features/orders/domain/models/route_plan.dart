/// Domain model for an optimized pickup route plan.
///
/// Mapped from the backend response of POST /orders/route-plan/.
class RoutePlan {
  final int totalStops;
  final double totalDistanceKm;
  final int estimatedDurationMinutes;
  final List<RouteStop> stops;
  final List<String> warnings;
  final List<List<double>> path;

  const RoutePlan({
    required this.totalStops,
    required this.totalDistanceKm,
    required this.estimatedDurationMinutes,
    required this.stops,
    required this.warnings,
    this.path = const [],
  });

  factory RoutePlan.fromJson(Map<String, dynamic> json) {
    var roadPath = <List<double>>[];
    if (json['path'] != null) {
      roadPath = (json['path'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((v) => _toDouble(v)).toList())
          .toList();
    }

    return RoutePlan(
      totalStops: json['total_stops'] as int? ?? 0,
      totalDistanceKm: _toDouble(json['total_distance_km']),
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int? ?? 0,
      stops: (json['stops'] as List<dynamic>? ?? [])
          .map((e) => RouteStop.fromJson(e as Map<String, dynamic>))
          .toList(),
      warnings: (json['warnings'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      path: roadPath,
    );
  }

  bool get hasWarnings => warnings.isNotEmpty;
  bool get isEmpty => stops.isEmpty;
}

/// A single stop in the optimized route.
class RouteStop {
  final int order;
  final String orderId;
  final String merchantName;
  final String merchantAddress;
  final double latitude;
  final double longitude;
  final double distanceFromPreviousKm;
  final String? pickupStart;
  final String? pickupEnd;
  final String listingTitle;
  final String listingPhoto;
  final String? warning;

  const RouteStop({
    required this.order,
    required this.orderId,
    required this.merchantName,
    required this.merchantAddress,
    required this.latitude,
    required this.longitude,
    required this.distanceFromPreviousKm,
    this.pickupStart,
    this.pickupEnd,
    required this.listingTitle,
    required this.listingPhoto,
    this.warning,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      order: json['order'] as int? ?? 0,
      orderId: json['order_id'] as String? ?? '',
      merchantName: json['merchant_name'] as String? ?? '',
      merchantAddress: json['merchant_address'] as String? ?? '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      distanceFromPreviousKm: _toDouble(json['distance_from_previous_km']),
      pickupStart: json['pickup_start'] as String?,
      pickupEnd: json['pickup_end'] as String?,
      listingTitle: json['listing_title'] as String? ?? '',
      listingPhoto: json['listing_photo'] as String? ?? '',
      warning: json['warning'] as String?,
    );
  }

  bool get hasWarning => warning != null && warning!.isNotEmpty;

  /// Formatted pickup window string (e.g. "14:00 – 16:00").
  String get pickupWindow {
    final start = _formatTime(pickupStart);
    final end = _formatTime(pickupEnd);
    if (start.isEmpty && end.isEmpty) return '';
    return '$start – $end';
  }

  static String _formatTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt != null) {
      final local = dt.toLocal();
      return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }
    final match = RegExp(r'(\d{2}:\d{2})').firstMatch(raw);
    return match?.group(1) ?? raw;
  }
}

double _toDouble(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}
