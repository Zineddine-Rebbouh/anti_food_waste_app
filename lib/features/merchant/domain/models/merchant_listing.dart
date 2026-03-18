enum ListingStatus { draft, active, soldOut, expired, paused }

enum MerchantFoodCategory { bakery, restaurant, supermarket, cafe, other }

enum FreshnessGrade { a, b, c, f }

enum DietaryTag { halal, vegan, vegetarian, glutenFree, nutFree, dairyFree }

class MerchantListing {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final MerchantFoodCategory category;
  final List<DietaryTag> dietaryTags;
  final double originalPrice;
  final double discountedPrice;
  final int totalQuantity;
  final int reservedQuantity;
  final DateTime pickupStart;
  final DateTime pickupEnd;
  final ListingStatus status;
  final FreshnessGrade grade;
  final int views;
  final DateTime createdAt;

  const MerchantListing({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.dietaryTags,
    required this.originalPrice,
    required this.discountedPrice,
    required this.totalQuantity,
    required this.reservedQuantity,
    required this.pickupStart,
    required this.pickupEnd,
    required this.status,
    required this.grade,
    required this.views,
    required this.createdAt,
  });

  // ── JSON deserialization ─────────────────────────────────────────────────

  factory MerchantListing.fromJson(Map<String, dynamic> json) {
    // -- status ---------------------------------------------------------------
    final statusStr = json['status'] as String? ?? 'active';
    final status = _statusFromString(statusStr);

    // -- category  ------------------------------------------------------------
    // Detail serializer: category = {id, name, slug, ...}
    // List serializer:   category_name = "Bakery"
    final categoryRaw = json['category'];
    final categorySlug = categoryRaw is Map
        ? (categoryRaw['slug'] as String? ?? '').toLowerCase()
        : (json['category_name'] as String? ?? '').toLowerCase();
    final category = _categoryFromSlug(categorySlug);

    // -- photo ----------------------------------------------------------------
    // Detail serializer: photos = [{photo_url, is_primary, ...}]
    // List serializer:   primary_photo_url = "https://..."
    String imageUrl = '';
    final photos = json['photos'];
    if (photos is List && photos.isNotEmpty) {
      final primary = photos.firstWhere(
        (p) => p['is_primary'] == true,
        orElse: () => photos.first,
      );
      imageUrl = primary['photo_url'] as String? ?? '';
    } else {
      imageUrl = json['primary_photo_url'] as String? ?? '';
    }

    // -- quantities -----------------------------------------------------------
    final quantityTotal = (json['quantity_total'] as num?)?.toInt() ?? 0;
    final quantityAvailable = (json['quantity_available'] as num?)?.toInt() ?? 0;
    // When the list serializer omits quantity_total, fall back to available.
    final total = quantityTotal > 0 ? quantityTotal : quantityAvailable;
    final reserved = (total - quantityAvailable).clamp(0, total);

    // -- dietary flags --------------------------------------------------------
    final dietaryFlags = json['dietary_flags'];
    final dietaryTags = _dietaryTagsFromFlags(dietaryFlags);

    return MerchantListing(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: imageUrl,
      category: category,
      dietaryTags: dietaryTags,
      originalPrice: double.tryParse(json['original_price'].toString()) ?? 0,
      discountedPrice: double.tryParse(json['discounted_price'].toString()) ?? 0,
      totalQuantity: total,
      reservedQuantity: reserved,
      pickupStart: DateTime.parse(json['pickup_start'] as String),
      pickupEnd: DateTime.parse(json['pickup_end'] as String),
      status: status,
      grade: _gradeFromString(json['freshness_grade'] as String? ?? 'a'),
      views: 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  /// Payload for POST /listings/  (create).
  /// [categoryId] is the backend Category PK looked up from /categories/.
  Map<String, dynamic> toCreateJson({required int categoryId}) {
    return {
      'category': categoryId,
      'title': title,
      'description': description,
      'original_price': originalPrice.toStringAsFixed(2),
      'discounted_price': discountedPrice.toStringAsFixed(2),
      'quantity_total': totalQuantity,
      'freshness_grade': grade.name,
      'pickup_start': pickupStart.toIso8601String(),
      'pickup_end': pickupEnd.toIso8601String(),
      'dietary_flags': _dietaryFlagsToJson(dietaryTags),
      'allergens': <String>[],
      'is_donation': false,
    };
  }

  /// Payload for PATCH /listings/{id}/  (update — only mutable fields).
  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'description': description,
      'discounted_price': discountedPrice.toStringAsFixed(2),
      'quantity_available': availableQuantity,
      'freshness_grade': grade.name,
      'status': _statusToString(status),
      'pickup_start': pickupStart.toIso8601String(),
      'pickup_end': pickupEnd.toIso8601String(),
      'dietary_flags': _dietaryFlagsToJson(dietaryTags),
      'allergens': <String>[],
    };
  }

  // ── Static helpers ────────────────────────────────────────────────────────

  static ListingStatus _statusFromString(String s) {
    switch (s) {
      case 'active':
        return ListingStatus.active;
      case 'sold_out':
        return ListingStatus.soldOut;
      case 'expired':
      case 'cancelled':
        return ListingStatus.expired;
      case 'draft':
      default:
        return ListingStatus.draft;
    }
  }

  static String _statusToString(ListingStatus s) {
    switch (s) {
      case ListingStatus.active:
        return 'active';
      case ListingStatus.soldOut:
      case ListingStatus.paused:
        return 'sold_out';
      case ListingStatus.expired:
        return 'expired';
      case ListingStatus.draft:
        return 'draft';
    }
  }

  static FreshnessGrade _gradeFromString(String s) {
    switch (s.toLowerCase()) {
      case 'a':
        return FreshnessGrade.a;
      case 'b':
        return FreshnessGrade.b;
      case 'c':
        return FreshnessGrade.c;
      default:
        return FreshnessGrade.f;
    }
  }

  static MerchantFoodCategory _categoryFromSlug(String slug) {
    if (slug.contains('bakery') || slug.contains('boulangerie')) {
      return MerchantFoodCategory.bakery;
    }
    if (slug.contains('restaurant') || slug.contains('resto')) {
      return MerchantFoodCategory.restaurant;
    }
    if (slug.contains('supermarket') || slug.contains('supermarche') ||
        slug.contains('grocery') || slug.contains('epicerie')) {
      return MerchantFoodCategory.supermarket;
    }
    if (slug.contains('cafe') || slug.contains('café') ||
        slug.contains('coffee')) {
      return MerchantFoodCategory.cafe;
    }
    return MerchantFoodCategory.other;
  }

  static List<DietaryTag> _dietaryTagsFromFlags(dynamic flags) {
    if (flags is! Map) return [];
    final tags = <DietaryTag>[];
    if (flags['halal'] == true) tags.add(DietaryTag.halal);
    if (flags['vegan'] == true) tags.add(DietaryTag.vegan);
    if (flags['vegetarian'] == true) tags.add(DietaryTag.vegetarian);
    if (flags['gluten_free'] == true) tags.add(DietaryTag.glutenFree);
    if (flags['nut_free'] == true) tags.add(DietaryTag.nutFree);
    if (flags['dairy_free'] == true) tags.add(DietaryTag.dairyFree);
    return tags;
  }

  static Map<String, bool> _dietaryFlagsToJson(List<DietaryTag> tags) {
    return {
      'halal': tags.contains(DietaryTag.halal),
      'vegan': tags.contains(DietaryTag.vegan),
      'vegetarian': tags.contains(DietaryTag.vegetarian),
      'gluten_free': tags.contains(DietaryTag.glutenFree),
      'nut_free': tags.contains(DietaryTag.nutFree),
      'dairy_free': tags.contains(DietaryTag.dairyFree),
    };
  }

  /// Public convenience wrapper so callers outside this file can build the
  /// dietary_flags JSON dict without accessing private methods.
  static Map<String, bool> buildDietaryFlags(List<DietaryTag> tags) =>
      _dietaryFlagsToJson(tags);

  // ── Computed properties ────────────────────────────────────────────────────

  double get discountPercent =>
      ((1 - discountedPrice / originalPrice) * 100).roundToDouble();

  int get availableQuantity => totalQuantity - reservedQuantity;

  double get netEarningsPerItem => discountedPrice * 0.88;

  double get platformFeePerItem => discountedPrice * 0.12;

  double get potentialRevenue => netEarningsPerItem * availableQuantity;

  bool get isActive => status == ListingStatus.active;

  String get categoryLabel {
    switch (category) {
      case MerchantFoodCategory.bakery:
        return 'Bakery';
      case MerchantFoodCategory.restaurant:
        return 'Restaurant';
      case MerchantFoodCategory.supermarket:
        return 'Supermarket';
      case MerchantFoodCategory.cafe:
        return 'Café';
      case MerchantFoodCategory.other:
        return 'Other';
    }
  }

  String get gradeLabel {
    switch (grade) {
      case FreshnessGrade.a:
        return 'Grade A';
      case FreshnessGrade.b:
        return 'Grade B';
      case FreshnessGrade.c:
        return 'Grade C';
      case FreshnessGrade.f:
        return 'Grade F';
    }
  }

  MerchantListing copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    MerchantFoodCategory? category,
    List<DietaryTag>? dietaryTags,
    double? originalPrice,
    double? discountedPrice,
    int? totalQuantity,
    int? reservedQuantity,
    DateTime? pickupStart,
    DateTime? pickupEnd,
    ListingStatus? status,
    FreshnessGrade? grade,
    int? views,
    DateTime? createdAt,
  }) {
    return MerchantListing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      pickupStart: pickupStart ?? this.pickupStart,
      pickupEnd: pickupEnd ?? this.pickupEnd,
      status: status ?? this.status,
      grade: grade ?? this.grade,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
