import 'package:anti_food_waste_app/features/consumer/data/sources/consumer_remote_source.dart';
import 'package:anti_food_waste_app/features/consumer/domain/models/consumer_order.dart';
import 'package:anti_food_waste_app/features/profile/domain/models/app_user.dart';
import 'package:anti_food_waste_app/features/profile/domain/models/user_address.dart';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';
import 'package:anti_food_waste_app/shared/models/listing_extra_details.dart';

/// Single point of contact between the presentation layer and the network
/// layer for all consumer-facing features.
class ConsumerRepository {
  final ConsumerRemoteSource _source;

  ConsumerRepository({ConsumerRemoteSource? source})
      : _source = source ?? ConsumerRemoteSource();

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<AppUser> fetchProfile() async {
    final json = await _source.fetchUserMe();
    return AppUser.fromJson(json);
  }

  /// Updates profile fields on the backend and returns the refreshed [AppUser].
  Future<AppUser> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? preferredLanguage,
  }) async {
    final json = await _source.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      avatarUrl: avatarUrl,
      preferredLanguage: preferredLanguage,
    );
    return AppUser.fromJson(json);
  }

  /// Sends a change-password request to the backend.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    await _source.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      newPasswordConfirm: newPasswordConfirm,
    );
  }

  /// Uploads an avatar image file and returns the public URL.
  Future<String> uploadAvatar(String filePath) async {
    return _source.uploadAvatar(filePath);
  }

  // ── Listings ──────────────────────────────────────────────────────────────

  /// Fetches the public listing feed, optionally sorted by [ordering].
  /// Pass [lat], [lng], [radius] for proximity ordering (returns distance_km).
  /// Pass [category] to filter by a single category (e.g. 'bakery').
  Future<List<FoodListing>> fetchListings({
    String? ordering,
    String? search,
    String? category, double? minRating,
    double? lat,
    double? lng,
    double? radius,
  }) async {
    final raw = await _source.fetchListings(
      ordering: ordering,
      search: search,
      category: category,
      lat: lat,
      lng: lng,
      radius: radius, minRating: minRating,
    );
    return raw.map(FoodListing.fromJson).toList();
  }

  /// Fetches active listings within a map bounding box.
  /// Returns raw response map with `count`, `bounds`, and `listings`.
  Future<Map<String, dynamic>> fetchListingsMap({
    required double neLat,
    required double neLng,
    required double swLat,
    required double swLng,
    String? category, double? minRating,
    String? freshnessGrade,
  }) async {
    return _source.fetchListingsMap(
      neLat: neLat,
      neLng: neLng,
      swLat: swLat,
      swLng: swLng,
      category: category,
      freshnessGrade: freshnessGrade, minRating: minRating,
    );
  }

  /// Fetches the full detail for a single listing (with photos + merchant info).
  Future<FoodListing> fetchListingDetail(String id) async {
    final json = await _source.fetchListingDetail(id);
    return FoodListing.fromJson(json);
  }

  /// Fetches the complete extra details for the listing detail screen.
  Future<ListingExtraDetails> fetchListingExtraDetails(String id) async {
    final json = await _source.fetchListingDetail(id);
    return ListingExtraDetails.fromDetailJson(json);
  }

  // ── Favorites ─────────────────────────────────────────────────────────────

  Future<List<String>> fetchFavoriteIds() {
    return _source.fetchFavoriteIds();
  }

  Future<List<FoodListing>> fetchFavoriteListings() async {
    final raw = await _source.fetchFavoriteListings();
    return raw.map(FoodListing.fromJson).toList();
  }

  Future<void> addFavorite(String listingId) {
    return _source.addFavorite(listingId);
  }

  Future<void> removeFavorite(String listingId) {
    return _source.removeFavorite(listingId);
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  /// Places a new order for [listingId].
  Future<ConsumerOrder> createOrder({
    required String listingId,
    required int quantity,
    String paymentMethod = 'cash',
  }) async {
    final json = await _source.createOrder(
      listingId: listingId,
      quantity: quantity,
      paymentMethod: paymentMethod,
    );
    return ConsumerOrder.fromJson(json);
  }

  /// Returns all orders for the authenticated consumer.
  Future<List<ConsumerOrder>> fetchOrders() async {
    final raw = await _source.fetchOrders();
    return raw.map(ConsumerOrder.fromJson).toList();
  }

  /// Returns QR hash + pickup code for an active order.
  Future<Map<String, dynamic>> fetchOrderQr(String id) async {
    return _source.fetchOrderQr(id);
  }

  /// Cancels an order by [id].
  Future<ConsumerOrder> cancelOrder(String id, {String reason = ''}) async {
    final json = await _source.cancelOrder(id, reason: reason);
    return ConsumerOrder.fromJson(json);
  }

  // ── Addresses ─────────────────────────────────────────────────────────────

  Future<List<UserAddress>> fetchAddresses() async {
    final raw = await _source.fetchAddresses();
    return raw.map(UserAddress.fromJson).toList();
  }

  Future<UserAddress> createAddress({
    required String label,
    required String street,
    required String city,
    required String wilaya,
    required String postalCode,
    String notes = '',
    bool isDefault = false,
  }) async {
    final json = await _source.createAddress({
      'label': label,
      'street': street,
      'city': city,
      'wilaya': wilaya,
      'postal_code': postalCode,
      'notes': notes,
      'is_default': isDefault,
    });
    return UserAddress.fromJson(json);
  }

  Future<UserAddress> updateAddress(
      String id, Map<String, dynamic> data) async {
    final json = await _source.updateAddress(id, data);
    return UserAddress.fromJson(json);
  }

  Future<void> deleteAddress(String id) async {
    await _source.deleteAddress(id);
  }
}

