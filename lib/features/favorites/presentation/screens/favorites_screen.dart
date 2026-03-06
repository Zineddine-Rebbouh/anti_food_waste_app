import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:animate_do/animate_do.dart';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';
import 'package:anti_food_waste_app/shared/widgets/listing_card.dart';
import 'package:anti_food_waste_app/features/home/presentation/screens/listing_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<FoodListing> _mockFavorites = [
      FoodListing(
        id: '1',
        title: 'Surplus Bakery Box',
        merchantName: 'Boulangerie El Khobz',
        merchantId: 'm1',
        originalPrice: 500,
        discountedPrice: 200,
        discountPercent: 60,
        imageUrl:
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=300&fit=crop',
        rating: 4.8,
        reviewCount: 124,
        distance: 1.2,
        freshness: FreshnessGrade.A,
        category: FoodCategory.bakery,
        pickupStart: '18:00',
        pickupEnd: '20:00',
        quantityLeft: 3,
        dietary: ['Vegetarian'],
        lat: 36.7525,
        lng: 3.04197,
        postedMinutesAgo: 15,
      ),
      FoodListing(
        id: '2',
        title: 'Market Fruit Basket',
        merchantName: 'Superéette Benali',
        merchantId: 'm2',
        originalPrice: 1200,
        discountedPrice: 500,
        discountPercent: 58,
        imageUrl:
            'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=400&h=300&fit=crop',
        rating: 4.7,
        reviewCount: 89,
        distance: 2.5,
        freshness: FreshnessGrade.B,
        category: FoodCategory.supermarket,
        pickupStart: '20:00',
        pickupEnd: '21:00',
        quantityLeft: 5,
        dietary: ['Vegan', 'Gluten-Free'],
        lat: 36.7525,
        lng: 3.04197,
        postedMinutesAgo: 120,
      ),
      FoodListing(
        id: '3',
        title: 'Margherita Pizza Pack',
        merchantName: 'Pizzeria Napoli',
        merchantId: 'm3',
        originalPrice: 800,
        discountedPrice: 350,
        discountPercent: 56,
        imageUrl:
            'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&h=300&fit=crop',
        rating: 4.9,
        reviewCount: 302,
        distance: 0.8,
        freshness: FreshnessGrade.A,
        category: FoodCategory.restaurant,
        pickupStart: '21:30',
        pickupEnd: '22:30',
        quantityLeft: 1,
        dietary: ['Vegetarian'],
        lat: 36.7525,
        lng: 3.04197,
        postedMinutesAgo: 5,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          l10n.favorites,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: _mockFavorites.length,
        itemBuilder: (context, index) {
          return FadeInUp(
            duration: Duration(milliseconds: 300 + (index * 100)),
            child: ListingCard(
              listing: _mockFavorites[index],
              isFavorite: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ListingDetailScreen(listing: _mockFavorites[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
