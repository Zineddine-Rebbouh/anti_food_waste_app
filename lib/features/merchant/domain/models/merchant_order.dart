enum OrderStatus { pending, completed, cancelled, noShow }

enum PaymentMethod { paidOnline, cashOnPickup }

class MerchantOrder {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final double customerEcoScore;
  final String listingId;
  final String listingTitle;
  final int quantity;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final DateTime orderedAt;
  final DateTime pickupStart;
  final DateTime pickupEnd;
  final String? specialInstructions;
  final bool isDonation;

  const MerchantOrder({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEcoScore,
    required this.listingId,
    required this.listingTitle,
    required this.quantity,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.orderedAt,
    required this.pickupStart,
    required this.pickupEnd,
    this.specialInstructions,
    this.isDonation = false,
  });

  // ── JSON deserialization ─────────────────────────────────────────────────

  factory MerchantOrder.fromJson(Map<String, dynamic> json) {
    // order_status: pending | reserved | collected | cancelled | no_show
    final statusStr = json['order_status'] as String? ?? 'pending';
    final status = _statusFromString(statusStr);

    // payment_method: cash | online
    final paymentStr = json['payment_method'] as String? ?? 'cash';
    final payment = paymentStr == 'online'
        ? PaymentMethod.paidOnline
        : PaymentMethod.cashOnPickup;

    // Listing details may come nested (detail serializer) or as flat fields.
    final listing = json['listing'] as Map<String, dynamic>?;
    final listingId = listing?['id'] as String? ?? '';
    final listingTitle =
        listing?['title'] as String? ?? json['listing_title'] as String? ?? '';

    // Pickup window: detail serializer nests `listing`, but list serializer
    // (OrderListSerializer) exposes `pickup_start/pickup_end` at top-level.
    final now = DateTime.now();
    final pickupStart = listing != null && listing['pickup_start'] != null
        ? DateTime.parse(listing['pickup_start'] as String)
        : (json['pickup_start'] != null
            ? DateTime.parse(json['pickup_start'] as String)
            : now);
    final pickupEnd = listing != null && listing['pickup_end'] != null
        ? DateTime.parse(listing['pickup_end'] as String)
        : (json['pickup_end'] != null
            ? DateTime.parse(json['pickup_end'] as String)
            : now.add(const Duration(hours: 2)));

    // Consumer info — only present when the merchant fetches order detail.
    final customerName =
        json['consumer_name'] as String? ?? 'Customer';
    final customerPhone =
        json['consumer_phone'] as String? ?? '';
    final customerEcoScore =
        (json['consumer_eco_score'] as num?)?.toDouble() ?? 50.0;

    return MerchantOrder(
      id: json['id'] as String,
      orderNumber: json['pickup_code'] as String? ?? json['id'] as String,
      customerId: '',
      customerName: customerName,
      customerPhone: customerPhone,
      customerEcoScore: customerEcoScore,
      listingId: listingId,
      listingTitle: listingTitle,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      totalAmount: double.tryParse(json['total_price'].toString()) ?? 0,
      paymentMethod: payment,
      status: status,
      orderedAt: DateTime.parse(json['created_at'] as String),
      pickupStart: pickupStart,
      pickupEnd: pickupEnd,
      specialInstructions: json['notes'] as String?,
      isDonation: false,
    );
  }

  // ── Static helpers ────────────────────────────────────────────────────────

  static OrderStatus _statusFromString(String s) {
    switch (s) {
      case 'collected':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'no_show':
        return OrderStatus.noShow;
      case 'pending':
      case 'reserved':
      default:
        return OrderStatus.pending;
    }
  }

  // ── Computed properties ────────────────────────────────────────────────────

  double get netEarnings => totalAmount * 0.88;

  double get platformFee => totalAmount * 0.12;

  String get maskedPhone {
    if (customerPhone.length < 7) return customerPhone;
    return '${customerPhone.substring(0, 7)}***';
  }

  bool get isPending => status == OrderStatus.pending;

  Duration get timeUntilPickupEnd => pickupEnd.difference(DateTime.now());

  bool get isUrgent => timeUntilPickupEnd.inMinutes < 60;

  bool get isCritical => timeUntilPickupEnd.inMinutes < 10;

  MerchantOrder copyWith({OrderStatus? status}) {
    return MerchantOrder(
      id: id,
      orderNumber: orderNumber,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEcoScore: customerEcoScore,
      listingId: listingId,
      listingTitle: listingTitle,
      quantity: quantity,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      status: status ?? this.status,
      orderedAt: orderedAt,
      pickupStart: pickupStart,
      pickupEnd: pickupEnd,
      specialInstructions: specialInstructions,
      isDonation: isDonation,
    );
  }
}
