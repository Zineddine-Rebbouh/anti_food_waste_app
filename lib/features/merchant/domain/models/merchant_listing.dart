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

  int get availableQuantity => totalQuantity - reservedQuantity;

  double get discountPercent =>
      ((1 - discountedPrice / originalPrice) * 100).roundToDouble();

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
