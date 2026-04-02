import 'package:anti_food_waste_app/core/config/app_config.dart';

/// Domain model for a consumer's order, mapped from OrderListSerializer /
/// OrderDetailSerializer responses.
class ConsumerOrder {
  final String id;
  final String merchantName;
  final String merchantImage;
  final String listingTitle;
  final double totalPrice;
  final String currency;
  final String orderStatus; // backend value: pending/reserved/collected/cancelled/no_show
  final String paymentMethod;
  final String pickupCode;
  final String orderNumber;
  final String createdAt;
  final String pickupStart; // "HH:MM"
  final String pickupEnd;   // "HH:MM"
  final String merchantAddress;

  const ConsumerOrder({
    required this.id,
    required this.merchantName,
    required this.merchantImage,
    required this.listingTitle,
    required this.totalPrice,
    required this.currency,
    required this.orderStatus,
    required this.paymentMethod,
    required this.pickupCode,
    required this.orderNumber,
    required this.createdAt,
    required this.pickupStart,
    required this.pickupEnd,
    required this.merchantAddress,
  });

  bool get isActive =>
      orderStatus == 'pending' || orderStatus == 'reserved';

  bool get isCompleted => orderStatus == 'collected';

  bool get isCancelled =>
      orderStatus == 'cancelled' || orderStatus == 'no_show';

  factory ConsumerOrder.fromJson(Map<String, dynamic> json) {
    // The list endpoint returns flat fields; the detail endpoint nests listing.
    final listing = json['listing'] as Map<String, dynamic>?;

    String trimTime(String? raw) {
      if (raw == null || raw.isEmpty) return '';
      final s = raw.trim();

      // Works for ISO-8601 datetime strings coming from DRF:
      // e.g. "2026-03-18T14:30:00Z" → "14:30"
      final tryDt = DateTime.tryParse(s);
      if (tryDt != null) {
        final hh = tryDt.hour.toString().padLeft(2, '0');
        final mm = tryDt.minute.toString().padLeft(2, '0');
        return '$hh:$mm';
      }

      // Also support "HH:MM:SS" / "HH:MM"
      final match = RegExp(r'(\d{2}:\d{2})').firstMatch(s);
      if (match != null) return match.group(1)!;

      // Fallback
      return s.length >= 5 ? s.substring(0, 5) : s;
    }

    final pickupStart = trimTime(
      (listing?['pickup_start'] as String?) ?? (json['pickup_start'] as String?),
    );
    final pickupEnd = trimTime(
      (listing?['pickup_end'] as String?) ?? (json['pickup_end'] as String?),
    );

    final image = listing?['primary_photo_url'] as String? ??
        json['listing_photo'] as String? ??
        '';

    final title = listing?['title'] as String? ??
        json['listing_title'] as String? ??
        '';

    final rawId = json['id']?.toString() ?? '';
    // Short human-readable reference: first 8 chars of UUID in upper case
    final shortRef = rawId.replaceAll('-', '').substring(0, rawId.replaceAll('-', '').length.clamp(0, 8)).toUpperCase();
    final orderNumber = '#SF-$shortRef';

    String normalizeUrl(String url) {
      if (url.isEmpty) return '';
      final baseAppUrl = AppConfig.baseUrl.split('/api/').first;
      if (url.startsWith('http')) {
        if (url.contains('://127.0.0.1') || url.contains('://localhost')) {
          final path = Uri.parse(url).path;
          return '$baseAppUrl$path';
        }
        return url;
      }
      final cleanUrl = url.startsWith('/') ? url : '/$url';
      return '$baseAppUrl$cleanUrl';
    }

    return ConsumerOrder(
      id: rawId,
      merchantName: json['merchant_name'] as String? ?? '',
      merchantImage: normalizeUrl(image),
      listingTitle: title,
      totalPrice: _toDoubleCO(json['total_price']),
      currency: json['currency'] as String? ?? 'DZD',
      orderStatus: json['order_status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      pickupCode: json['pickup_code'] as String? ?? '',
      orderNumber: orderNumber,
      createdAt: json['created_at'] as String? ?? '',
      pickupStart: pickupStart,
      pickupEnd: pickupEnd,
      merchantAddress: json['merchant_address'] as String? ?? '',
    );
  }
}

double _toDoubleCO(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}
