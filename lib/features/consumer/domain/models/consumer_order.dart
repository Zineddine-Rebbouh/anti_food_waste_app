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
      return raw.length >= 5 ? raw.substring(0, 5) : raw;
    }

    final pickupStart = trimTime(listing?['pickup_start'] as String?);
    final pickupEnd = trimTime(listing?['pickup_end'] as String?);

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

    return ConsumerOrder(
      id: rawId,
      merchantName: json['merchant_name'] as String? ?? '',
      merchantImage: image,
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
