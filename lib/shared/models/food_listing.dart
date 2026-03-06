enum FreshnessGrade { A, B, C }

enum FoodCategory { bakery, restaurant, supermarket, cafe }

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
}
