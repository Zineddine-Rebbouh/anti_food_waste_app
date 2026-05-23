import 'package:anti_food_waste_app/core/config/app_config.dart';

/// Domain model for a consumer's order, mapped from OrderListSerializer /
/// OrderDetailSerializer responses.
class ConsumerOrder {
  final String id;
  final String merchantName;
  final String merchantImage;
  final String listingTitle;
  final double totalPrice;
  final double unitPrice;
  final int quantity;
  final String currency;
  final String orderStatus; // backend value: pending/reserved/collected/cancelled/no_show
  final String paymentMethod;
  final String paymentStatus;
  final String pickupCode;
  final String orderNumber;
  final String createdAt;
  final String pickupStart; // "HH:MM"
  final String pickupEnd;   // "HH:MM"
  final String pickupStartRaw; // ISO datetime for display
  final String pickupEndRaw;   // ISO datetime for display
  final String merchantAddress;
  final String merchantPhone;
  final double? merchantLatitude;
  final double? merchantLongitude;
  final String merchantLogoUrl;
  final String merchantCoverUrl;
  final String cancellationReason;
  final String notes;
  final String? collectedAt; // ISO datetime string

  const ConsumerOrder({
    required this.id,
    required this.merchantName,
    required this.merchantImage,
    required this.listingTitle,
    required this.totalPrice,
    required this.unitPrice,
    required this.quantity,
    required this.currency,
    required this.orderStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.pickupCode,
    required this.orderNumber,
    required this.createdAt,
    required this.pickupStart,
    required this.pickupEnd,
    required this.pickupStartRaw,
    required this.pickupEndRaw,
    required this.merchantAddress,
    required this.merchantPhone,
    this.merchantLatitude,
    this.merchantLongitude,
    required this.merchantLogoUrl,
    required this.merchantCoverUrl,
    required this.cancellationReason,
    required this.notes,
    this.collectedAt,
  });

  bool get isActive =>
      orderStatus == 'pending' || orderStatus == 'accepted' || orderStatus == 'reserved';

  bool get isCompleted => orderStatus == 'collected';

  bool get isCancelled =>
      orderStatus == 'cancelled' || orderStatus == 'no_show';

  bool get hasLocation =>
      merchantLatitude != null && merchantLongitude != null;

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

    final rawPickupStart =
        (listing?['pickup_start'] as String?) ?? (json['pickup_start'] as String?) ?? '';
    final rawPickupEnd =
        (listing?['pickup_end'] as String?) ?? (json['pickup_end'] as String?) ?? '';

    final pickupStart = trimTime(rawPickupStart);
    final pickupEnd = trimTime(rawPickupEnd);

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
      unitPrice: _toDoubleCO(json['unit_price']),
      quantity: (json['quantity'] as int?) ?? 1,
      currency: json['currency'] as String? ?? 'DZD',
      orderStatus: json['order_status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      pickupCode: json['pickup_code'] as String? ?? '',
      orderNumber: orderNumber,
      createdAt: json['created_at'] as String? ?? '',
      pickupStart: pickupStart,
      pickupEnd: pickupEnd,
      pickupStartRaw: rawPickupStart,
      pickupEndRaw: rawPickupEnd,
      merchantAddress: json['merchant_address'] as String? ?? '',
      merchantPhone: json['merchant_phone'] as String? ?? '',
      merchantLatitude: _toNullableDouble(json['merchant_latitude']),
      merchantLongitude: _toNullableDouble(json['merchant_longitude']),
      merchantLogoUrl: normalizeUrl(json['merchant_logo_url'] as String? ?? ''),
      merchantCoverUrl: normalizeUrl(json['merchant_cover_url'] as String? ?? json['merchant_cover_image_url'] as String? ?? ''),
      cancellationReason: json['cancellation_reason'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      collectedAt: json['collected_at'] as String?,
    );
  }
}

double _toDoubleCO(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

double? _toNullableDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}
