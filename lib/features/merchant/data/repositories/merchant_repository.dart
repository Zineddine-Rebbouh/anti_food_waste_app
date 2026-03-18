import 'package:anti_food_waste_app/features/merchant/data/sources/merchant_remote_source.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_listing.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_order.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_stats.dart';

/// Aggregates data from [MerchantRemoteSource] and maps raw API responses to
/// domain model objects.  This is the single point of contact between the
/// presentation layer (cubits) and the network layer.
class MerchantRepository {
  final MerchantRemoteSource _source;

  MerchantRepository({MerchantRemoteSource? source})
      : _source = source ?? MerchantRemoteSource();

  // ── Dashboard load ────────────────────────────────────────────────────────

  /// Loads all data required for the merchant dashboard in one call.
  ///
  /// User profile fetch is mandatory and will propagate on failure.
  /// Analytics, categories, listings and orders are best-effort: a failure in
  /// any of them results in empty data for that section instead of crashing
  /// the whole dashboard (e.g. 403 for a pending-approval merchant).
  Future<MerchantDashboardData> loadDashboard() async {
    // User profile is required — any exception propagates to the cubit.
    final userMeJson = await _source.fetchUserMe();

    // Analytics (same type) and categories (different type) run in parallel,
    // but kept in separate typed futures to avoid List<Object> inference.
    final analyticsResults = await Future.wait<Map<String, dynamic>>([
      _safeAnalytics(1),
      _safeAnalytics(7),
      _safeAnalytics(30),
    ]);
    final categories = await _safeCategories();

    final profile = MerchantProfile.fromApiJson(
      userMeJson: userMeJson,
      dailyAnalytics: analyticsResults[0],
      weeklyAnalytics: analyticsResults[1],
      monthlyAnalytics: analyticsResults[2],
    );

    // Listings and orders — failures yield empty lists.
    final phase2 = await Future.wait([
      _safeList(_source.fetchMyListings()),
      _safeList(_source.fetchOrders()),
    ]);

    final listings = phase2[0].map(MerchantListing.fromJson).toList();
    final orders = phase2[1].map(MerchantOrder.fromJson).toList();

    return MerchantDashboardData(
      profile: profile,
      listings: listings,
      orders: orders,
      categories: categories,
    );
  }

  // ── Best-effort helpers ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _safeAnalytics(int days) async {
    try {
      return await _source.fetchMerchantAnalytics(periodDays: days);
    } catch (_) {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> _safeCategories() async {
    try {
      return await _source.fetchCategories();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _safeList(
    Future<List<Map<String, dynamic>>> future,
  ) async {
    try {
      return await future;
    } catch (_) {
      return [];
    }
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<MerchantProfile> fetchProfile() async {
    final results = await Future.wait([
      _source.fetchUserMe(),
      _source.fetchMerchantAnalytics(periodDays: 1),
      _source.fetchMerchantAnalytics(periodDays: 7),
      _source.fetchMerchantAnalytics(periodDays: 30),
    ]);
    return MerchantProfile.fromApiJson(
      userMeJson: results[0] as Map<String, dynamic>,
      dailyAnalytics: results[1] as Map<String, dynamic>,
      weeklyAnalytics: results[2] as Map<String, dynamic>,
      monthlyAnalytics: results[3] as Map<String, dynamic>,
    );
  }

  // ── Listings ──────────────────────────────────────────────────────────────

  Future<List<MerchantListing>> fetchListings({String? status}) async {
    final raw = await _source.fetchMyListings(status: status);
    return raw.map(MerchantListing.fromJson).toList();
  }

  /// Creates a new listing.
  ///
  /// [categoryId] is the backend Category PK. Use [fetchCategories] and
  /// [resolveCategoryId] to look it up from the enum value.
  Future<MerchantListing> createListing(Map<String, dynamic> payload) async {
    final json = await _source.createListing(payload);
    return MerchantListing.fromJson(json);
  }

  Future<MerchantListing> updateListing(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final json = await _source.updateListing(id, payload);
    return MerchantListing.fromJson(json);
  }

  Future<void> deleteListing(String id) => _source.deleteListing(id);

  /// Uploads a local file as the primary photo for a listing.
  /// Returns the photo URL stored on the server, or empty string on failure.
  Future<String> uploadListingPhoto(String listingId, String filePath) async {
    final json = await _source.uploadListingPhoto(listingId, filePath);
    return json['photo_url'] as String? ?? '';
  }

  Future<MerchantListing> markAsDonation(String id) async {
    final json = await _source.markListingAsDonation(id);
    return MerchantListing.fromJson(json);
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<List<MerchantOrder>> fetchOrders() async {
    final raw = await _source.fetchOrders();
    return raw.map(MerchantOrder.fromJson).toList();
  }

  /// Confirms a pickup by validating the consumer's QR code hash.
  Future<MerchantOrder> fulfillOrder(String orderId, String qrHash) async {
    final json = await _source.fulfillOrder(orderId, qrHash);
    return MerchantOrder.fromJson(json);
  }

  /// Cancels a pending order as merchant, with an optional reason.
  Future<MerchantOrder> cancelOrder(String orderId, {String reason = ''}) async {
    final json = await _source.cancelOrder(orderId, reason: reason);
    return MerchantOrder.fromJson(json);
  }

  /// Marks a pending order as no-show.
  Future<MerchantOrder> markNoShow(String orderId) async {
    final json = await _source.markOrderNoShow(orderId);
    return MerchantOrder.fromJson(json);
  }

  /// Fulfils an order by entering the consumer's 6-character pickup code.
  Future<MerchantOrder> fulfillByPickupCode(String code) async {
    final json = await _source.fulfillOrderByPickupCode(code);
    return MerchantOrder.fromJson(json);
  }

  // ── Categories ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchCategories() =>
      _source.fetchCategories();

  /// Maps a Flutter [MerchantFoodCategory] enum value to a backend Category ID
  /// by matching the category slug.  Falls back to the first category if none
  /// match.
  int resolveCategoryId(
    MerchantFoodCategory category,
    List<Map<String, dynamic>> categories,
  ) {
    if (categories.isEmpty) return 1;

    final targetSlug = category.name.toLowerCase();
    final match = categories.firstWhere(
      (c) {
        final slug = (c['slug'] as String? ?? '').toLowerCase();
        return slug.contains(targetSlug) || targetSlug.contains(slug);
      },
      orElse: () => categories.first,
    );
    return (match['id'] as num).toInt();
  }
}

/// Value object carrying everything the merchant dashboard needs after a full
/// [MerchantRepository.loadDashboard] call.
class MerchantDashboardData {
  final MerchantProfile profile;
  final List<MerchantListing> listings;
  final List<MerchantOrder> orders;
  final List<Map<String, dynamic>> categories;

  const MerchantDashboardData({
    required this.profile,
    required this.listings,
    required this.orders,
    required this.categories,
  });
}
