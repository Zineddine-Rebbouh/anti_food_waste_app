class SubscriptionPlan {
  final int id;
  final String name;
  final String slug;
  final double monthlyPriceDzd;
  final int? maxActiveListings;
  final bool canReceiveDonations;
  final bool isActive;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.slug,
    required this.monthlyPriceDzd,
    this.maxActiveListings,
    required this.canReceiveDonations,
    required this.isActive,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      monthlyPriceDzd: double.tryParse(json['monthly_price_dzd']?.toString() ?? '') ?? 0.0,
      maxActiveListings: json['max_active_listings'] as int?,
      canReceiveDonations: json['can_receive_donations'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class MerchantSubscription {
  final int id;
  final int merchantId;
  final SubscriptionPlan plan;
  final String status;
  final DateTime? trialStartedAt;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final bool autoRenew;
  final bool isBillingActive;
  final int? daysRemaining;
  final int activeListingCount;
  final bool isAtListingLimit;

  MerchantSubscription({
    required this.id,
    required this.merchantId,
    required this.plan,
    required this.status,
    this.trialStartedAt,
    this.trialEndsAt,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    required this.autoRenew,
    required this.isBillingActive,
    this.daysRemaining,
    required this.activeListingCount,
    required this.isAtListingLimit,
  });

  factory MerchantSubscription.fromJson(Map<String, dynamic> json) {
    return MerchantSubscription(
      id: json['id'] as int,
      merchantId: json['merchant'] as int? ?? 0,
      plan: SubscriptionPlan.fromJson(json['plan'] as Map<String, dynamic>),
      status: json['status'] as String? ?? 'trial',
      trialStartedAt: json['trial_started_at'] != null
          ? DateTime.parse(json['trial_started_at'] as String)
          : null,
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.parse(json['trial_ends_at'] as String)
          : null,
      currentPeriodStart: json['current_period_start'] != null
          ? DateTime.parse(json['current_period_start'] as String)
          : null,
      currentPeriodEnd: json['current_period_end'] != null
          ? DateTime.parse(json['current_period_end'] as String)
          : null,
      autoRenew: json['auto_renew'] as bool? ?? true,
      isBillingActive: json['is_billing_active'] as bool? ?? false,
      daysRemaining: json['days_remaining'] as int?,
      activeListingCount: json['active_listing_count'] as int? ?? 0,
      isAtListingLimit: json['is_at_listing_limit'] as bool? ?? false,
    );
  }
}

class SubscriptionPayment {
  final String id;
  final int subscriptionId;
  final int merchantId;
  final SubscriptionPlan plan;
  final double amountDzd;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String status;
  final String paymentMethod;
  final String referenceNumber;
  final DateTime? paidAt;
  final String notes;
  final DateTime createdAt;

  SubscriptionPayment({
    required this.id,
    required this.subscriptionId,
    required this.merchantId,
    required this.plan,
    required this.amountDzd,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    required this.paymentMethod,
    required this.referenceNumber,
    this.paidAt,
    required this.notes,
    required this.createdAt,
  });

  factory SubscriptionPayment.fromJson(Map<String, dynamic> json) {
    return SubscriptionPayment(
      id: json['id']?.toString() ?? '',
      subscriptionId: json['subscription'] as int? ?? 0,
      merchantId: json['merchant'] as int? ?? 0,
      plan: SubscriptionPlan.fromJson(json['plan'] as Map<String, dynamic>),
      amountDzd: double.tryParse(json['amount_dzd']?.toString() ?? '') ?? 0.0,
      periodStart: DateTime.parse(json['period_start']?.toString() ?? ''),
      periodEnd: DateTime.parse(json['period_end']?.toString() ?? ''),
      status: json['status']?.toString() ?? 'pending',
      paymentMethod: json['payment_method']?.toString() ?? '',
      referenceNumber: json['reference_number']?.toString() ?? '',
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']?.toString() ?? '') : null,
      notes: json['notes']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at']?.toString() ?? ''),
    );
  }
}

class CommissionLedger {
  final String id;
  final String orderId;
  final int merchantId;
  final String merchantName;
  final String consumerName;
  final String listingTitle;
  final double orderAmountDzd;
  final double commissionRate;
  final double commissionAmountDzd;
  final String status;
  final String? settlementBatch;
  final DateTime createdAt;

  CommissionLedger({
    required this.id,
    required this.orderId,
    required this.merchantId,
    required this.merchantName,
    required this.consumerName,
    required this.listingTitle,
    required this.orderAmountDzd,
    required this.commissionRate,
    required this.commissionAmountDzd,
    required this.status,
    this.settlementBatch,
    required this.createdAt,
  });

  factory CommissionLedger.fromJson(Map<String, dynamic> json) {
    return CommissionLedger(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      merchantId: json['merchant'] as int? ?? 0,
      merchantName: json['merchant_name']?.toString() ?? '',
      consumerName: json['consumer_name']?.toString() ?? '',
      listingTitle: json['listing_title']?.toString() ?? '',
      orderAmountDzd: double.tryParse(json['order_amount_dzd']?.toString() ?? '') ?? 0.0,
      commissionRate: double.tryParse(json['commission_rate']?.toString() ?? '') ?? 0.0,
      commissionAmountDzd: double.tryParse(json['commission_amount_dzd']?.toString() ?? '') ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      settlementBatch: json['settlement_batch']?.toString(),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? ''),
    );
  }
}

class SponsoredSlot {
  final String id;
  final int merchantId;
  final int quantity;
  final double pricePerSlotDzd;
  final double totalAmountDzd;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String status;
  final int slotsUsed;
  final int slotsAvailable;

  SponsoredSlot({
    required this.id,
    required this.merchantId,
    required this.quantity,
    required this.pricePerSlotDzd,
    required this.totalAmountDzd,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    required this.slotsUsed,
    required this.slotsAvailable,
  });

  factory SponsoredSlot.fromJson(Map<String, dynamic> json) {
    return SponsoredSlot(
      id: json['id']?.toString() ?? '',
      merchantId: json['merchant'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 1,
      pricePerSlotDzd: double.tryParse(json['price_per_slot_dzd']?.toString() ?? '') ?? 0.0,
      totalAmountDzd: double.tryParse(json['total_amount_dzd']?.toString() ?? '') ?? 0.0,
      periodStart: DateTime.parse(json['period_start']?.toString() ?? ''),
      periodEnd: DateTime.parse(json['period_end']?.toString() ?? ''),
      status: json['status']?.toString() ?? 'active',
      slotsUsed: json['slots_used'] as int? ?? 0,
      slotsAvailable: json['slots_available'] as int? ?? 0,
    );
  }
}

class SponsoredListing {
  final String id;
  final String slotId;
  final String listingId;
  final String listingTitle;
  final int positionPriority;
  final DateTime startedAt;
  final DateTime expiresAt;
  final bool isActive;
  final bool isCurrentlyActive;

  SponsoredListing({
    required this.id,
    required this.slotId,
    required this.listingId,
    required this.listingTitle,
    required this.positionPriority,
    required this.startedAt,
    required this.expiresAt,
    required this.isActive,
    required this.isCurrentlyActive,
  });

  factory SponsoredListing.fromJson(Map<String, dynamic> json) {
    return SponsoredListing(
      id: json['id']?.toString() ?? '',
      slotId: json['slot']?.toString() ?? '',
      listingId: json['listing']?.toString() ?? '',
      listingTitle: json['listing_title']?.toString() ?? '',
      positionPriority: json['position_priority'] as int? ?? 10,
      startedAt: DateTime.parse(json['started_at']?.toString() ?? ''),
      expiresAt: DateTime.parse(json['expires_at']?.toString() ?? ''),
      isActive: json['is_active'] as bool? ?? true,
      isCurrentlyActive: json['is_currently_active'] as bool? ?? false,
    );
  }
}
