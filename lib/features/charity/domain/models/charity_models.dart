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
