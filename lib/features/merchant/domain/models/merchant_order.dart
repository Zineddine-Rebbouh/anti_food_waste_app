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
