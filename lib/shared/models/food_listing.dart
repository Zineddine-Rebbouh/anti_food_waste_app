enum FreshnessGrade { A, B, C }

enum FoodCategory { bakery, restaurant, supermarket, cafe }

// Safely converts a value that may be String or num to double.
double _toDouble(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

List<String> _extractDietaryLabels(dynamic value) {
  if (value is List) {
    return value
        .map((entry) => entry.toString().trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }

  if (value is Map) {
    return value.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key.toString())
        .map((entry) => entry.replaceFirst(RegExp(r'^is_'), ''))
        .map((entry) => entry.replaceAll('_', ' ').trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }

  return const <String>[];
}

String _extractListingId(Map<String, dynamic> json) {
  final direct = json['id']?.toString().trim();
  if (direct != null && direct.isNotEmpty) return direct;

  final relation = json['listing_id']?.toString().trim();
  if (relation != null && relation.isNotEmpty) return relation;

  final nestedListing = json['listing'];
  if (nestedListing is Map<String, dynamic>) {
    final nestedId = nestedListing['id']?.toString().trim();
    if (nestedId != null && nestedId.isNotEmpty) return nestedId;
  }

  return '';
}

class FoodListing {
  final String id;
  final String title;
  final String merchantName;
  final String merchantId;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercent;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final double distance;
  final FreshnessGrade freshness;
  final FoodCategory category;
  final String pickupStart;
  final String pickupEnd;
  final int quantityLeft;
  final List<String> dietary;
  final double lat;
  final double lng;
  final int postedMinutesAgo;

  FoodListing({
    required this.id,
    required this.title,
    required this.merchantName,
    required this.merchantId,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercent,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.freshness,
    required this.category,
    required this.pickupStart,
    required this.pickupEnd,
    required this.quantityLeft,
    required this.dietary,
    required this.lat,
    required this.lng,
    required this.postedMinutesAgo,
  });

  double get savings => originalPrice - discountedPrice;

  /// Builds a [FoodListing] from a backend API response.
  /// Works for both [ListingListSerializer] and [ListingDetailSerializer] shapes.
  factory FoodListing.fromJson(Map<String, dynamic> json) {
    // ── Category ──────────────────────────────────────────────────────────
    // List response: category_name (string)
    // Detail response: category (object with 'name' field)
    String categoryName = '';
    final categoryField = json['category'];
    if (categoryField is Map) {
      categoryName = (categoryField['name'] as String? ?? '').toLowerCase();
    } else {
      categoryName = (json['category_name'] as String? ?? '').toLowerCase();
    }
    FoodCategory category;
    if (categoryName.contains('boulangerie') ||
        categoryName.contains('bakery') ||
        categoryName.contains('bread') ||
        categoryName.contains('patisserie')) {
      category = FoodCategory.bakery;
    } else if (categoryName.contains('café') ||
        categoryName.contains('cafe') ||
        categoryName.contains('coffee')) {
      category = FoodCategory.cafe;
    } else if (categoryName.contains('supermarket') ||
        categoryName.contains('supermarché') ||
        categoryName.contains('grocery') ||
        categoryName.contains('épicerie')) {
      category = FoodCategory.supermarket;
    } else {
      category = FoodCategory.restaurant;
    }

    // ── Freshness ─────────────────────────────────────────────────────────
    final fg = (json['freshness_grade'] as String? ?? 'A').toUpperCase();
    FreshnessGrade freshness;
    if (fg == 'B') {
      freshness = FreshnessGrade.B;
    } else if (fg == 'C') {
      freshness = FreshnessGrade.C;
    } else {
      freshness = FreshnessGrade.A;
    }

    // ── Pickup times (TimeField → "HH:MM:SS", keep "HH:MM") ─────────────
    String trimTime(String? raw) {
      if (raw == null || raw.isEmpty) return '';
      return raw.length >= 5 ? raw.substring(0, 5) : raw;
    }

    // ── Primary image ─────────────────────────────────────────────────────
    // List: primary_photo_url  |  Detail: first photo in photos[]
    String imageUrl = json['primary_photo_url'] as String? ?? '';
    if (imageUrl.isEmpty) {
      final photos = json['photos'] as List<dynamic>?;
      if (photos != null && photos.isNotEmpty) {
        imageUrl = (photos.first as Map<String, dynamic>)['photo_url'] as String? ?? '';
      }
    }

    // ── Merchant info (detail response only) ─────────────────────────────
    final merchantInfo = json['merchant_info'] as Map<String, dynamic>?;
    final locationMap = merchantInfo?['location'] as Map<String, dynamic>?;
    // Fallback: map endpoint returns latitude/longitude at root level
    final lat = _toDouble(locationMap?['latitude'] ?? json['latitude']);
    final lng = _toDouble(locationMap?['longitude'] ?? json['longitude']);
    final merchantId = merchantInfo?['id']?.toString() ?? json['merchant_id']?.toString() ?? '';
    // Detail has average_rating inside merchant_info; list has merchant_rating at top level
    final rating = merchantInfo != null
        ? _toDouble(merchantInfo['average_rating'])
        : _toDouble(json['merchant_rating']);
    final reviewCount = merchantInfo != null
        ? (merchantInfo['total_reviews'] as num? ?? 0).toInt()
        : 0;

    // ── Posted minutes ago ────────────────────────────────────────────────
    int postedMinutesAgo = 0;
    final createdAtStr = json['created_at'] as String?;
    if (createdAtStr != null) {
      try {
        final dt = DateTime.parse(createdAtStr);
        postedMinutesAgo = DateTime.now().difference(dt).inMinutes.abs();
      } catch (_) {}
    }

    // ── Dietary flags (only present in detail response) ───────────────────
    final dietary = _extractDietaryLabels(json['dietary_flags']);

    return FoodListing(
      id: _extractListingId(json),
      title: json['title'] as String? ?? '',
      merchantName: json['merchant_name'] as String? ?? merchantInfo?['business_name']?.toString() ?? '',
      merchantId: merchantId,
      originalPrice: _toDouble(json['original_price']),
      discountedPrice: _toDouble(json['discounted_price']),
      discountPercent: _toDouble(json['discount_percentage']).toInt(),
      imageUrl: imageUrl,
      rating: rating,
      reviewCount: reviewCount,
      distance: _toDouble(json['distance_km']),
      freshness: freshness,
      category: category,
      pickupStart: trimTime(json['pickup_start'] as String?),
      pickupEnd: trimTime(json['pickup_end'] as String?),
      quantityLeft: (json['quantity_available'] as num? ?? 0).toInt(),
      dietary: dietary,
      lat: lat == 0 ? _toDouble(json['lat']) : lat,
      lng: lng == 0 ? _toDouble(json['lng']) : lng,
      postedMinutesAgo: postedMinutesAgo,
    );
  }
}
