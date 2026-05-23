import 'package:anti_food_waste_app/core/utils/app_logger.dart';
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
    // fetchOrders() already merges standard orders and donation requests.
    final phase2 = await Future.wait<dynamic>([
      _safeList(_source.fetchMyListings()),
      fetchOrders(),
    ]);

    final listings = (phase2[0] as List<Map<String, dynamic>>)
        .map(MerchantListing.fromJson)
        .toList();
    final orders = phase2[1] as List<MerchantOrder>;

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
      userMeJson: results[0],
      dailyAnalytics: results[1],
      weeklyAnalytics: results[2],
      monthlyAnalytics: results[3],
    );
  }

  Future<String> uploadLogo(String filePath) async {
    final json = await _source.uploadLogo(filePath);
    return json['logo_url'] as String? ??
        json['logo'] as String? ??
        json['avatar_url'] as String? ??
        json['avatar'] as String? ??
        '';
  }

  Future<MerchantProfile> updateProfile(Map<String, dynamic> data) async {
    await _source.updateUserMe(data);
    return fetchProfile();
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? address,
    String? wilaya,
  }) async {
    await _source.updateLocation(
      lat: latitude,
      lng: longitude,
      address: address,
      wilaya: wilaya,
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
    // The individual photo endpoint returns the newly created photo object. 
    // Usually { id: ..., photo: "http://...", is_primary: ... }
    return json['photo'] as String? ?? json['photo_url'] as String? ?? '';
  }

  Future<MerchantListing> markAsDonation(String id) async {
    final json = await _source.markListingAsDonation(id);
    return MerchantListing.fromJson(json);
  }

  Future<MerchantListing> unmarkAsDonation(String id) async {
    final json = await _source.unmarkListingAsDonation(id);
    return MerchantListing.fromJson(json);
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<List<MerchantOrder>> fetchOrders() async {
    final orders = <MerchantOrder>[];

    // 1. Fetch standard consumer orders
    try {
      final raw = await _source.fetchOrders();
      orders.addAll(raw.map((json) {
        try {
          final order = MerchantOrder.fromJson(json);
          // Standard orders are active immediately as they are reservations
          if (order.status == OrderStatus.pending) {
            return order.copyWith(status: OrderStatus.active);
          }
          return order;
        } catch (e, st) {
          AppLogger.error('MerchantRepository: Error parsing standard order', e, st);
          rethrow;
        }
      }).toList());
    } catch (e, st) {
      AppLogger.error('MerchantRepository.fetchOrders (standard)', e, st);
      // We don't rethrow here so we can still try to fetch donations
    }

    // 2. Fetch donation requests from charities
    try {
      final rawRequests = await _source.fetchDonationRequests();
      final donationOrders = rawRequests.map((json) {
        try {
          return MerchantOrder(
            id: json['id'] as String,
            orderNumber: json['id'].toString().substring(0, 8).toUpperCase(),
            customerId: json['charity'] as String? ?? '',
            customerName: json['charity_name'] as String? ?? 'Charity',
            customerPhone: '',
            customerEcoScore: 100.0,
            listingId: json['donation'] as String? ?? '',
            listingTitle: json['listing_title'] as String? ?? 'Donation Request',
            quantity: (json['quantity'] as num?)?.toInt() ?? 1,
            totalAmount: 0,
            paymentMethod: PaymentMethod.cashOnPickup,
            status: _statusFromRequest(json['status'] as String?),
            orderedAt: json['created_at'] != null 
                ? DateTime.parse(json['created_at'] as String) 
                : DateTime.now(),
            pickupStart: json['pickup_start'] != null 
                ? DateTime.parse(json['pickup_start']) 
                : DateTime.now(),
            pickupEnd: json['pickup_end'] != null 
                ? DateTime.parse(json['pickup_end']) 
                : DateTime.now().add(const Duration(hours: 2)),
            specialInstructions: json['message'] as String?,
            isDonation: true,
            rawStatus: json['status'] as String?,
          );
        } catch (e, st) {
          AppLogger.error('MerchantRepository: Error parsing donation request', e, st);
          rethrow;
        }
      }).toList();
      orders.addAll(donationOrders);
    } catch (e, st) {
      AppLogger.error('MerchantRepository.fetchOrders (donations)', e, st);
    }

    // Sort by most recent first
    orders.sort((a, b) => b.orderedAt.compareTo(a.orderedAt));
    return orders;
  }

  OrderStatus _statusFromRequest(String? status) {
    if (status == 'approved' || status == 'assigned') return OrderStatus.active;
    if (status == 'rejected') return OrderStatus.cancelled;
    if (status == 'collected') return OrderStatus.completed;
    return OrderStatus.pending; // map "pending" to OrderStatus.pending so merchant can see it
  }

  Future<void> approveDonationRequest(String donationId, String requestId) async {
    await _source.approveDonationRequest(donationId, requestId);
  }

  /// Confirms a pickup by validating the consumer's QR code hash.
  Future<MerchantOrder> fulfillOrder(String orderId, String qrHash) async {
    final json = await _source.fulfillOrder(orderId, qrHash);
    return MerchantOrder.fromJson(json);
  }

  /// Confirms a charity donation pickup by validating the charity's QR code hash.
  Future<void> fulfillDonation(String donationId, String qrHash) async {
    await _source.fulfillDonation(donationId, qrHash);
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



