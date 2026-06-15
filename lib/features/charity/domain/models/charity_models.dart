// ─── Charity Module: Domain Models ───────────────────────────────────────────
import 'package:anti_food_waste_app/core/config/app_config.dart';

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
    // ── Status ────────────────────────────────────────────────────────────────
    final statusStr = json['status'] as String? ?? 'available';
    var parsedStatus = DonationStatus.available;
    if (statusStr == 'assigned') parsedStatus = DonationStatus.claimed;
    if (statusStr == 'collected') parsedStatus = DonationStatus.collected;

    // ── Pickup window ─────────────────────────────────────────────────────────
    DateTime? winStart;
    DateTime? winEnd;
    final startStr = (json['listing_pickup_start'] ?? json['collection_start'])?.toString();
    final endStr   = (json['listing_pickup_end']   ?? json['collection_end'])?.toString();
    try { if (startStr != null) winStart = DateTime.parse(startStr).toLocal(); } catch (_) {}
    try { if (endStr   != null) winEnd   = DateTime.parse(endStr).toLocal();   } catch (_) {}
    final now = DateTime.now();
    winStart ??= now;
    winEnd   ??= now.add(const Duration(hours: 2));

    String fmtTime(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    // ── Category ──────────────────────────────────────────────────────────────
    DonationCategory parsedCategory = DonationCategory.grocery;
    final catSlug = (json['listing_category'] as String? ?? '').toLowerCase();
    if (catSlug.contains('boulang') || catSlug.contains('bak') || catSlug.contains('patiss')) {
      parsedCategory = DonationCategory.bakery;
    } else if (catSlug.contains('restaurant') || catSlug.contains('fast')) {
      parsedCategory = DonationCategory.restaurant;
    } else if (catSlug.contains('cafe') || catSlug.contains('caf') || catSlug.contains('coffee')) {
      parsedCategory = DonationCategory.cafe;
    } else if (catSlug.contains('hotel') || catSlug.contains('traiteur')) {
      parsedCategory = DonationCategory.hotel;
    }

    // ── Dietary tags ──────────────────────────────────────────────────────────
    final List<String> dietaryTags = [];
    final flagsRaw = json['listing_dietary_flags'];
    if (flagsRaw is List) dietaryTags.addAll(flagsRaw.map((e) => e.toString()));
    final allergensRaw = json['listing_allergens'];
    if (allergensRaw is List) {
      for (final a in allergensRaw) {
        final s = a.toString();
        if (!dietaryTags.contains(s)) dietaryTags.add(s);
      }
    }

    // ── Address ───────────────────────────────────────────────────────────────
    final addrParts = <String>[
      json['merchant_address']?.toString() ?? '',
      json['merchant_wilaya']?.toString() ?? '',
    ].where((s) => s.isNotEmpty).toList();
    final address = addrParts.join(', ');

    // ── Quantity & servings ───────────────────────────────────────────────────
    final qty = (json['listing_quantity'] as num?)?.toDouble() ?? 0.0;
    final servings = qty > 0 ? (qty * 3).round() : 0;

    // ── Urgency ───────────────────────────────────────────────────────────────
    final hoursLeft = winEnd.difference(now).inHours;
    final urgency = hoursLeft < 1
        ? UrgencyLevel.critical
        : hoursLeft < 3
            ? UrgencyLevel.urgent
            : UrgencyLevel.normal;

    return CharityDonation(
      id:               json['id']?.toString() ?? '',
      title:            json['listing_title']?.toString() ?? 'Donation',
      description:      json['listing_description']?.toString() ?? '',
      merchantName:     json['merchant_name']?.toString() ?? 'Unknown Merchant',
      merchantAddress:  address.isNotEmpty ? address : 'Address Not Provided',
      imageUrl:         CharityDonation.normalizeUrl(json['listing_photo']?.toString()),
      category:         parsedCategory,
      quantityKg:       qty,
      estimatedServings: servings,
      dietaryTags:      dietaryTags,
      expiresAt:        winEnd,
      pickupWindowStart: fmtTime(winStart),
      pickupWindowEnd:   fmtTime(winEnd),
      distanceKm:       0.0,
      status:           parsedStatus,
      urgency:          urgency,
      postedAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  factory CharityDonation.fromJsonDetail(Map<String, dynamic> json) {
    final parent  = CharityDonation.fromJson(json);
    final listing = json['listing'] as Map<String, dynamic>? ?? {};
    final info    = listing['merchant_info'] as Map<String, dynamic>? ?? {};

    final descDetail = listing['description']?.toString() ?? parent.description;
    final qty        = double.tryParse(listing['quantity_available']?.toString() ?? '') ??
                       double.tryParse(listing['quantity_total']?.toString() ?? '') ??
                       parent.quantityKg;
    final imgUrl     = CharityDonation.normalizeUrl(
        listing['primary_photo_url']?.toString() ?? parent.imageUrl ?? '');

    final List<String> tags = List<String>.from(parent.dietaryTags);
    if (listing['dietary_flags'] is List) {
      for (final t in listing['dietary_flags'] as List) {
        final s = t.toString();
        if (!tags.contains(s)) tags.add(s);
      }
    }

    final addrDet = <String>[
      info['address']?.toString() ?? '',
      info['wilaya']?.toString() ?? '',
    ].where((s) => s.isNotEmpty).join(', ');

    return CharityDonation(
      id:               parent.id,
      title:            listing['title']?.toString() ?? parent.title,
      description:      descDetail,
      merchantName:     parent.merchantName,
      merchantAddress:  addrDet.isNotEmpty ? addrDet : parent.merchantAddress,
      imageUrl:         imgUrl,
      category:         parent.category,
      quantityKg:       qty,
      estimatedServings: qty > 0 ? (qty * 3).round() : parent.estimatedServings,
      dietaryTags:      tags,
      expiresAt:        parent.expiresAt,
      pickupWindowStart: parent.pickupWindowStart,
      pickupWindowEnd:   parent.pickupWindowEnd,
      distanceKm:        double.tryParse(listing['distance_km']?.toString() ?? '') ?? parent.distanceKm,
      status:            parent.status,
      urgency:           parent.urgency,
      postedAt:          parent.postedAt,
    );
  }

  static String normalizeUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    
    // Check for known broken Unsplash URLs from mock data or backend
    if (url.contains('photo-1610832958506-aa56338406cd') || 
        url.contains('photo-1550583724-125581f77833')) {
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800';
    }

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
  final double? merchantLatitude;
  final double? merchantLongitude;
  final String merchantPhone;
  final String listingPhoto;
  final String? qrHash;
  final DateTime? expiresAt;

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
    this.merchantLatitude,
    this.merchantLongitude,
    required this.merchantPhone,
    this.listingPhoto = '',
    this.qrHash,
    this.expiresAt,
  });

  bool get hasLocation => merchantLatitude != null && merchantLongitude != null;

  factory CharityPickupRequest.fromJson(Map<String, dynamic> json) {
    final qrData = json['qr_data'] as Map<String, dynamic>?;

    return CharityPickupRequest(
      id: json['id']?.toString() ?? '',
      donationId: json['donation']?.toString() ?? '',
      donationTitle: json['listing_title']?.toString() ?? 'Requested Donation',
      merchantName: json['merchant_name']?.toString() ?? 'Merchant',
      merchantAddress: json['merchant_address']?.toString() ?? 'Address',
      charityName: json['charity_name']?.toString() ?? 'Charity',
      contactPerson: '',
      contactPhone: '',
      vehicleType: 'Car',
      requestedAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      scheduledPickupTime: json['pickup_start'] != null 
          ? DateTime.parse(json['pickup_start']) 
          : DateTime.now().add(const Duration(hours: 1)),
      status: _statusFromBackend(json['status'] as String?),
      quantityKg: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      estimatedServings: 0,
      notes: json['message']?.toString(),
      merchantLatitude: (json['merchant_latitude'] as num?)?.toDouble(),
      merchantLongitude: (json['merchant_longitude'] as num?)?.toDouble(),
      merchantPhone: json['merchant_phone']?.toString() ?? '',
      listingPhoto: CharityDonation.normalizeUrl((json['listing_photo'] ?? json['donation_photo'])?.toString() ?? ''),
      qrHash: qrData?['qr_hash']?.toString(),
      expiresAt: qrData?['expires_at'] != null 
          ? DateTime.parse(qrData!['expires_at']) 
          : null,
    );
  }

  static PickupRequestStatus _statusFromBackend(String? status) {
    switch (status) {
      case 'approved':
      case 'assigned':
        return PickupRequestStatus.approved;
      case 'en-route':
        return PickupRequestStatus.enRoute;
      case 'collected':
        return PickupRequestStatus.collected;
      case 'rejected':
      case 'expired':
        return PickupRequestStatus.cancelled;
      case 'pending':
      default:
        return PickupRequestStatus.pending;
    }
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





