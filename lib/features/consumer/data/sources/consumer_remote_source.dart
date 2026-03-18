import 'package:dio/dio.dart';
import 'package:anti_food_waste_app/core/network/api_client.dart';

/// Raw HTTP calls to the consumer-related Django endpoints.
///
/// Every method returns the decoded JSON body so the repository layer can
/// map it into domain models without coupling transport logic to business logic.
class ConsumerRemoteSource {
  final Dio _dio;

  ConsumerRemoteSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  // ── Profile ───────────────────────────────────────────────────────────────

  /// GET /users/me/ — returns the authenticated consumer with nested profile.
  Future<Map<String, dynamic>> fetchUserMe() async {
    final r = await _dio.get('users/me/');
    return r.data as Map<String, dynamic>;
  }

  /// PATCH /users/me/ — update writable user fields.
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? preferredLanguage,
  }) async {
    final data = <String, dynamic>{};
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (phone != null) data['phone'] = phone;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    if (preferredLanguage != null) data['preferred_language'] = preferredLanguage;
    final r = await _dio.patch('users/me/', data: data);
    return r.data as Map<String, dynamic>;
  }

  /// POST /users/me/change-password/
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    await _dio.post('users/me/change-password/', data: {
      'old_password': oldPassword,
      'new_password': newPassword,
      'new_password_confirm': newPasswordConfirm,
    });
  }

  /// POST /users/me/avatar/ — upload avatar image, returns {avatar_url}.
  Future<String> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    final r = await _dio.post('users/me/avatar/', data: formData);
    return (r.data as Map<String, dynamic>)['avatar_url'] as String;
  }

  // ── Addresses ─────────────────────────────────────────────────────────────

  /// GET /users/me/addresses/ — list all saved addresses.
  Future<List<Map<String, dynamic>>> fetchAddresses() async {
    final r = await _dio.get('users/me/addresses/');
    return (r.data as List).cast<Map<String, dynamic>>();
  }

  /// POST /users/me/addresses/ — create a new address.
  Future<Map<String, dynamic>> createAddress(Map<String, dynamic> data) async {
    final r = await _dio.post('users/me/addresses/', data: data);
    return r.data as Map<String, dynamic>;
  }

  /// PATCH /users/me/addresses/{id}/ — partial update.
  Future<Map<String, dynamic>> updateAddress(
      String id, Map<String, dynamic> data) async {
    final r = await _dio.patch('users/me/addresses/$id/', data: data);
    return r.data as Map<String, dynamic>;
  }

  /// DELETE /users/me/addresses/{id}/
  Future<void> deleteAddress(String id) async {
    await _dio.delete('users/me/addresses/$id/');
  }

  // ── Listings (public feed) ────────────────────────────────────────────────

  /// GET /listings/ — public active listing feed.
  ///
  /// Pass [ordering] to sort results (e.g. '-created_at', 'pickup_end').
  /// Pass [search] for full-text search.
  /// Pass [lat], [lng], [radius] for proximity-based ordering (returns distance_km).
  Future<List<Map<String, dynamic>>> fetchListings({
    String? ordering,
    String? search,
    String? category,
    double? lat,
    double? lng,
    double? radius,
    double? minRating,
  }) async {
    final params = <String, dynamic>{};
    if (ordering != null) params['ordering'] = ordering;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null) params['category'] = category;
    if (lat != null) params['lat'] = lat;
    if (lng != null) params['lng'] = lng;
    if (radius != null) params['radius'] = radius;
    if (minRating != null && minRating > 0) params['min_rating'] = minRating;

    final r = await _dio.get(
      'listings/',
      queryParameters: params.isEmpty ? null : params,
    );
    return _extractResults(r.data);
  }

  /// GET /listings/map/ — listings within a visible map bounding box.
  ///
  /// [neLat]/[neLng] is the northeast corner of the visible map region.
  /// [swLat]/[swLng] is the southwest corner.
  /// Returns a map with `count`, `bounds`, and `listings` list.
  Future<Map<String, dynamic>> fetchListingsMap({
    required double neLat,
    required double neLng,
    required double swLat,
    required double swLng,
    String? category,
    String? freshnessGrade,
    double? minRating,
  }) async {
    final params = <String, dynamic>{
      'ne_lat': neLat,
      'ne_lng': neLng,
      'sw_lat': swLat,
      'sw_lng': swLng,
    };
    if (category != null) params['category'] = category;
    if (freshnessGrade != null) params['freshness_grade'] = freshnessGrade;
    if (minRating != null && minRating > 0) params['min_rating'] = minRating;

    final r = await _dio.get(
      'listings/map/',
      queryParameters: params,
    );
    return r.data as Map<String, dynamic>;
  }

  /// GET /listings/{id}/ — full listing detail (photos + merchant_info).
  Future<Map<String, dynamic>> fetchListingDetail(String id) async {
    final encodedId = Uri.encodeComponent(id.trim());
    final r = await _dio.get('listings/$encodedId/');
    return r.data as Map<String, dynamic>;
  }

  // ── Favorites ─────────────────────────────────────────────────────────────

  /// GET /users/me/favorites/ids/ — quick favorite listing IDs.
  Future<List<String>> fetchFavoriteIds() async {
    final r = await _dio.get('users/me/favorites/ids/');
    final ids = (r.data as Map<String, dynamic>)['ids'] as List<dynamic>? ?? [];
    return ids.map((e) => e.toString()).toList();
  }

  /// GET /users/me/favorites/ — full listing cards for the Favorites tab.
  Future<List<Map<String, dynamic>>> fetchFavoriteListings() async {
    final r = await _dio.get('users/me/favorites/');
    return _extractResults(r.data);
  }

  /// POST /users/me/favorites/ — save one listing.
  Future<void> addFavorite(String listingId) async {
    await _dio.post('users/me/favorites/', data: {'listing_id': listingId});
  }

  /// DELETE /users/me/favorites/{id}/ — remove one listing.
  Future<void> removeFavorite(String listingId) async {
    final encodedId = Uri.encodeComponent(listingId.trim());
    await _dio.delete('users/me/favorites/$encodedId/');
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  /// POST /orders/ — consumer places an order.
  Future<Map<String, dynamic>> createOrder({
    required String listingId,
    required int quantity,
    String paymentMethod = 'cash',
  }) async {
    final r = await _dio.post('orders/', data: {
      'listing_id': listingId,
      'quantity': quantity,
      'payment_method': paymentMethod,
    });
    return r.data as Map<String, dynamic>;
  }

  /// GET /orders/ — consumer's own orders list.
  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final r = await _dio.get('orders/');
    return _extractResults(r.data);
  }

  /// GET /orders/{id}/ — full detail for one order (includes QR data).
  Future<Map<String, dynamic>> fetchOrderDetail(String id) async {
    final r = await _dio.get('orders/$id/');
    return r.data as Map<String, dynamic>;
  }

  /// GET /orders/{id}/qr/ — QR hash + pickup code for consumer.
  Future<Map<String, dynamic>> fetchOrderQr(String id) async {
    final r = await _dio.get('orders/$id/qr/');
    return r.data as Map<String, dynamic>;
  }

  /// POST /orders/{id}/cancel/
  Future<Map<String, dynamic>> cancelOrder(
    String id, {
    String reason = '',
  }) async {
    final r = await _dio.post(
      'orders/$id/cancel/',
      data: {'reason': reason},
    );
    return r.data as Map<String, dynamic>;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Normalises both a plain [List] and a cursor-paginated `{results: [...]}`.
  List<Map<String, dynamic>> _extractResults(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .map((e) {
            final nested = e['listing'];
            if (nested is Map<String, dynamic>) return nested;
            if (nested is Map) return nested.cast<String, dynamic>();
            return e;
          })
          .toList();
    }

    if (data is Map) {
      final payload = data['results'] ?? data['listings'] ?? data['favorites'] ?? data;
      if (payload is List) {
        return payload
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .map((e) {
              final nested = e['listing'];
              if (nested is Map<String, dynamic>) return nested;
              if (nested is Map) return nested.cast<String, dynamic>();
              return e;
            })
            .toList();
      }
    }

    return const <Map<String, dynamic>>[];
  }
}

