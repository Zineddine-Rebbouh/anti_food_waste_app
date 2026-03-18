// ─── Charity Module: Domain Models ───────────────────────────────────────────

enum DonationStatus { available, claimed, collected, expired }

enum DonationCategory { bakery, restaurant, grocery, cafe, hotel }

enum UrgencyLevel { normal, urgent, critical }

enum PickupRequestStatus { pending, approved, enRoute, collected, cancelled }

// ─────────────────────────────────────────────────────────────────────────────
// CharityDonation
// ─────────────────────────────────────────────────────────────────────────────
class CharityDonation {
  final String id;
  final String title;
  final String description;
  final String merchantName;
  final String merchantAddress;
  final String? imageUrl;
  final DonationCategory category;
  final double quantityKg;
  final int estimatedServings;
  final List<String> dietaryTags;
  final DateTime expiresAt;
  final String pickupWindowStart; // e.g. "18:00"
  final String pickupWindowEnd;   // e.g. "20:00"
  final double distanceKm;
  final DonationStatus status;
  final UrgencyLevel urgency;
  final DateTime postedAt;

  const CharityDonation({
    required this.id,
    required this.title,
    required this.description,
    required this.merchantName,
    required this.merchantAddress,
    this.imageUrl,
    required this.category,
    required this.quantityKg,
    required this.estimatedServings,
    required this.dietaryTags,
    required this.expiresAt,
    required this.pickupWindowStart,
    required this.pickupWindowEnd,
    required this.distanceKm,
    required this.status,
    required this.urgency,
    required this.postedAt,
  });

  factory CharityDonation.fromJson(Map<String, dynamic> json) {
    // Basic mapping from backend DonationListSerializer
    final statusStr = json['status'] as String? ?? 'available';
    DonationStatus parsedStatus = DonationStatus.available;
    if (statusStr == 'assigned') parsedStatus = DonationStatus.claimed;
    if (statusStr == 'collected') parsedStatus = DonationStatus.collected;
    DateTime? colStart;
    DateTime? colEnd;
    try {
      if (json['collection_start'] != null) colStart = DateTime.parse(json['collection_start']);
      if (json['collection_end'] != null) colEnd = DateTime.parse(json['collection_end']);
    } catch (_) {}
    final now = DateTime.now();
    colStart ??= now;
    colEnd ??= now.add(const Duration(hours: 2));
    return CharityDonation(
      id: json['id']?.toString() ?? '',
      title: json['listing_title']?.toString() ?? 'Donation',
      description: '', 
      merchantName: json['merchant_name']?.toString() ?? 'Unknown Merchant',
      merchantAddress: 'Address Not Provided',
      imageUrl: json['listing_photo']?.toString(),
      category: DonationCategory.grocery,
      quantityKg: 0.0,
      estimatedServings: 0,
      dietaryTags: const [],
      expiresAt: colEnd,
      pickupWindowStart: '00:00',
      pickupWindowEnd: '00:00',
      distanceKm: 0.0,
      status: parsedStatus,
      urgency: UrgencyLevel.normal,
      postedAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
  factory CharityDonation.fromJsonDetail(Map<String, dynamic> json) {
    final parent = CharityDonation.fromJson(json); // Get basics
    final listing = json['listing'] as Map<String, dynamic>? ?? {};
    return CharityDonation(
      id: parent.id,
      title: listing['title']?.toString() ?? parent.title,
      description: listing['description']?.toString() ?? parent.description,
      merchantName: parent.merchantName,
      merchantAddress: listing['merchant_address']?.toString() ?? parent.merchantAddress, 
      imageUrl: listing['primary_photo_url']?.toString() ?? parent.imageUrl,
      category: parent.category, 
      quantityKg: double.tryParse(listing['quantity']?.toString() ?? '0') ?? 0.0,
      estimatedServings: parent.estimatedServings,
      dietaryTags: const [],
      expiresAt: parent.expiresAt,
      pickupWindowStart: parent.pickupWindowStart,
      pickupWindowEnd: parent.pickupWindowEnd,
      distanceKm: double.tryParse(listing['distance_km']?.toString() ?? '0') ?? parent.distanceKm,
      status: parent.status,
      urgency: parent.urgency,
      postedAt: parent.postedAt,
    );
  }
  bool get isExpiringSoon =>
      expiresAt.difference(DateTime.now()).inHours < 3 &&
      status == DonationStatus.available;

  String get categoryLabel {
    switch (category) {
      case DonationCategory.bakery:
        return 'Bakery';
      case DonationCategory.restaurant:
        return 'Restaurant';
      case DonationCategory.grocery:
        return 'Grocery';
      case DonationCategory.cafe:
        return 'Café';
      case DonationCategory.hotel:
        return 'Hotel';
    }
  }

  String get urgencyLabel {
    switch (urgency) {
      case UrgencyLevel.critical:
        return 'Critical';
      case UrgencyLevel.urgent:
        return 'Urgent';
      case UrgencyLevel.normal:
        return 'Normal';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CharityPickupRequest
// ─────────────────────────────────────────────────────────────────────────────
class CharityPickupRequest {
  final String id;
  final String donationId;
  final String donationTitle;
  final String merchantName;
  final String merchantAddress;
  final String charityName;
  final String contactPerson;
  final String contactPhone;
  final String vehicleType;
  final DateTime requestedAt;
  final DateTime scheduledPickupTime;
  final PickupRequestStatus status;
  final double quantityKg;
  final int estimatedServings;
  final String? notes;
  final String? merchantNote;

  const CharityPickupRequest({
    required this.id,
    required this.donationId,
    required this.donationTitle,
    required this.merchantName,
    required this.merchantAddress,
    required this.charityName,
    required this.contactPerson,
    required this.contactPhone,
    required this.vehicleType,
    required this.requestedAt,
    required this.scheduledPickupTime,
    required this.status,
    required this.quantityKg,
    required this.estimatedServings,
    this.notes,
    this.merchantNote,
  });

  factory CharityPickupRequest.fromJson(Map<String, dynamic> json) {
    return CharityPickupRequest(
      id: json['id']?.toString() ?? '',
      donationId: json['donation']?.toString() ?? '',
      donationTitle: 'Requested Donation', 
      merchantName: 'Merchant',
      merchantAddress: 'Address',
      charityName: json['charity_name']?.toString() ?? 'Charity',
      contactPerson: '',
      contactPhone: '',
      vehicleType: 'Car',
      requestedAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      scheduledPickupTime: DateTime.now().add(const Duration(hours: 1)),
      status: PickupRequestStatus.pending,
      quantityKg: 0.0,
      estimatedServings: 0,
      notes: json['message']?.toString(),
    );
  }
  String get statusLabel {
    switch (status) {
      case PickupRequestStatus.pending:
        return 'Pending';
      case PickupRequestStatus.approved:
        return 'Approved';
      case PickupRequestStatus.enRoute:
        return 'En Route';
      case PickupRequestStatus.collected:
        return 'Collected';
      case PickupRequestStatus.cancelled:
        return 'Cancelled';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CharityImpactReport
// ─────────────────────────────────────────────────────────────────────────────
class CharityImpactReport {
  final String id;
  final String pickupRequestId;
  final String donationTitle;
  final int mealsServed;
  final int beneficiaries;
  final double actualWeightKg;
  final String? notes;
  final DateTime reportedAt;

  const CharityImpactReport({
    required this.id,
    required this.pickupRequestId,
    required this.donationTitle,
    required this.mealsServed,
    required this.beneficiaries,
    required this.actualWeightKg,
    this.notes,
    required this.reportedAt,
  });
}


