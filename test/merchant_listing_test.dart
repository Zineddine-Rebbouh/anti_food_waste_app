import 'package:flutter_test/flutter_test.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_listing.dart';
import 'package:anti_food_waste_app/core/config/app_config.dart';

void main() {
  group('MerchantListing Creation & Normalization Tests', () {
    test('Should build correct Create Listing JSON', () {
      final now = DateTime.now();
      final pickupStart = now.add(const Duration(hours: 1));
      final pickupEnd = now.add(const Duration(hours: 3));

      final listing = MerchantListing(
        id: '',
        title: 'Test Bread',
        description: 'Warm and crispy',
        imageUrl: '',
        category: MerchantFoodCategory.bakery,
        dietaryTags: [DietaryTag.halal, DietaryTag.vegan],
        originalPrice: 150.0,
        discountedPrice: 50.0,
        totalQuantity: 10,
        reservedQuantity: 0,
        pickupStart: pickupStart,
        pickupEnd: pickupEnd,
        status: ListingStatus.active,
        grade: FreshnessGrade.a,
        views: 0,
        createdAt: now,
      );

      final json = listing.toCreateJson(categoryId: 6);

      expect(json['title'], 'Test Bread');
      expect(json['category'], 6);
      expect(json['original_price'], '150.00');
      expect(json['discounted_price'], '50.00');
      expect(json['quantity_total'], 10);
      expect(json['freshness_grade'], 'a');
      expect(json['dietary_flags']['halal'], true);
      expect(json['dietary_flags']['vegan'], true);
      expect(json['dietary_flags']['nut_free'], false);
    });

    test('Should normalize different URL types correctly', () {
      final baseUrl = AppConfig.baseUrl.split('/api/').first; // e.g., http://192.168.3.136:8080
      
      // Case 1: Localhost replacement
      expect(
        MerchantListing.fromJson({'pickup_start': '2026-04-05T18:00:00Z', 'pickup_end': '2026-04-05T20:00:00Z', 'primary_photo_url': 'http://127.0.0.1:8080/media/test.jpg'}).imageUrl,
        '$baseUrl/media/test.jpg'
      );

      // Case 2: Relative path
      expect(
        MerchantListing.fromJson({'pickup_start': '2026-04-05T18:00:00Z', 'pickup_end': '2026-04-05T20:00:00Z', 'primary_photo_url': '/media/photos/listing_1.png'}).imageUrl,
        '$baseUrl/media/photos/listing_1.png'
      );

      // Case 3: Proper remote URL (should NOT be changed)
      const remoteUrl = 'https://images.unsplash.com/photo-123';
      expect(
        MerchantListing.fromJson({'pickup_start': '2026-04-05T18:00:00Z', 'pickup_end': '2026-04-05T20:00:00Z', 'primary_photo_url': remoteUrl}).imageUrl,
        remoteUrl
      );
    });
    
    test('Should parse nested Category object from Detail API', () {
      final json = {
        'id': 'test-id',
        'title': 'Nested Category Test',
        'pickup_start': '2026-04-05T18:00:00Z',
        'pickup_end': '2026-04-05T20:00:00Z',
        'category': {
          'id': 6,
          'slug': 'boulangerie',
          'name': 'Bakery'
        },
        'freshness_grade': 'A'
      };
      
      final listing = MerchantListing.fromJson(json);
      expect(listing.category, MerchantFoodCategory.bakery);
    });
  });
}
