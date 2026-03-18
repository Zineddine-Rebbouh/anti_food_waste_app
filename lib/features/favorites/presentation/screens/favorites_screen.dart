import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:anti_food_waste_app/core/providers/favorites_provider.dart';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';
import 'package:anti_food_waste_app/shared/widgets/listing_card.dart';
import 'package:anti_food_waste_app/features/home/presentation/screens/listing_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<FoodListing>> _favoritesFuture;
  String _favoriteIdsKey = '';
  bool _isReloading = false;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _fetchFavoriteListings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<FavoritesProvider>(context);
    final nextKey = provider.favoriteIdsKey;

    if (_isReloading || nextKey == _favoriteIdsKey) {
      return;
    }

    setState(() {
      _favoritesFuture = _fetchFavoriteListings();
    });
  }

  Future<List<FoodListing>> _fetchFavoriteListings() async {
    _isReloading = true;
    final provider = context.read<FavoritesProvider>();
    try {
      final listings = await provider.fetchFavoriteListings();
      _favoriteIdsKey = provider.favoriteIdsKey;
      return listings;
    } finally {
      _isReloading = false;
    }
  }

  Future<void> _reload() async {
    final future = _fetchFavoriteListings();
    setState(() => _favoritesFuture = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesProvider = context.watch<FavoritesProvider>();

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
      body: FutureBuilder<List<FoodListing>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Could not load favorites.'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _reload, child: const Text('Retry')),
                ],
              ),
            );
          }

          final favorites = snapshot.data ?? const <FoodListing>[];
          if (favorites.isEmpty) {
            return Center(
              child: const Text(
                'No favorites yet.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final listing = favorites[index];
                return FadeInUp(
                  duration: Duration(milliseconds: 300 + (index * 80)),
                  child: ListingCard(
                    listing: listing,
                    isFavorite: true,
                    onFavoriteToggle: (next) async {
                      try {
                        await favoritesProvider.toggleFavorite(
                          listing.id,
                          desiredState: next,
                        );
                        await _reload();
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not update favorites. Please try again.'),
                          ),
                        );
                      }
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListingDetailScreen(listing: listing),
                        ),
                      ).then((_) => _reload());
                    },
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
