import 'package:flutter/foundation.dart';
import 'package:anti_food_waste_app/features/consumer/data/repositories/consumer_repository.dart';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';

class FavoritesProvider extends ChangeNotifier {
  final ConsumerRepository _repository;

  FavoritesProvider({ConsumerRepository? repository})
      : _repository = repository ?? ConsumerRepository();

  final Set<String> _favoriteIds = <String>{};
  bool _isLoaded = false;
  bool _isSyncing = false;

  bool get isLoaded => _isLoaded;
  bool get isSyncing => _isSyncing;
  Set<String> get favoriteIds => Set<String>.unmodifiable(_favoriteIds);
  String get favoriteIdsKey {
    final ids = _favoriteIds.toList()..sort();
    return ids.join('|');
  }

  bool isFavorite(String listingId) => _favoriteIds.contains(listingId.trim());

  Future<void> refreshFavoriteIds() async {
    _isSyncing = true;
    notifyListeners();
    try {
      final ids = await _repository.fetchFavoriteIds();
      _favoriteIds
        ..clear()
        ..addAll(ids.map((e) => e.trim()).where((e) => e.isNotEmpty));
      _isLoaded = true;
    } catch (_) {
      _favoriteIds.clear();
      _isLoaded = false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(String listingId, {bool? desiredState}) async {
    final normalizedId = listingId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError('listingId must not be empty');
    }

    final wasFavorite = isFavorite(normalizedId);
    final shouldBeFavorite = desiredState ?? !wasFavorite;

    if (shouldBeFavorite == wasFavorite) return wasFavorite;

    if (shouldBeFavorite) {
      _favoriteIds.add(normalizedId);
    } else {
      _favoriteIds.remove(normalizedId);
    }
    notifyListeners();

    try {
      if (shouldBeFavorite) {
        await _repository.addFavorite(normalizedId);
      } else {
        await _repository.removeFavorite(normalizedId);
      }
      return shouldBeFavorite;
    } catch (_) {
      if (wasFavorite) {
        _favoriteIds.add(normalizedId);
      } else {
        _favoriteIds.remove(normalizedId);
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<List<FoodListing>> fetchFavoriteListings() async {
    final listings = await _repository.fetchFavoriteListings();
    _favoriteIds
      ..clear()
      ..addAll(listings.map((e) => e.id.trim()).where((e) => e.isNotEmpty));
    _isLoaded = true;
    notifyListeners();
    return listings;
  }
}
