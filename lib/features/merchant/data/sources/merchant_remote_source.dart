import 'package:dio/dio.dart';
import 'package:anti_food_waste_app/core/network/api_client.dart';
import 'package:anti_food_waste_app/core/utils/app_logger.dart';
/// Raw HTTP calls to the merchant-related Django endpoints.
///
/// Every method returns the decoded JSON body so callers can map it into
/// domain models without coupling transport logic to business logic.
class MerchantRemoteSource {
  final Dio _dio;

  MerchantRemoteSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  // ── User / Profile ────────────────────────────────────────────────────────

  /// GET /users/me/ — returns the authenticated user with nested profile.
  Future<Map<String, dynamic>> fetchUserMe() async {
    final r = await _dio.get('users/me/');
    return r.data as Map<String, dynamic>;
  }

  /// PATCH /users/me/ — partial update of user & merchant profile fields.
  Future<Map<String, dynamic>> updateUserMe(Map<String, dynamic> data) async {
    final r = await _dio.patch('users/me/', data: data);
    return r.data as Map<String, dynamic>;
  }

  /// POST /merchants/me/logo/ — upload a local file as the merchant logo.
  Future<Map<String, dynamic>> uploadLogo(String filePath) async {
    AppLogger.info('MerchantRemoteSource: Uploading logo from $filePath');
    final fileName = filePath.contains('/')
        ? filePath.split('/').last
        : filePath.split('\\').last;

    // 1. Try merchants/me/logo/ with key 'logo'
    try {
      final formData = FormData.fromMap({
        'logo': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final r = await _dio.post(
        'merchants/me/logo/',
        data: formData,
        options: Options(contentType: null),
      );
      AppLogger.info('MerchantRemoteSource: Uploaded to merchants/me/logo/ (logo key)');
      return r.data as Map<String, dynamic>;
    } catch (e) {
      AppLogger.info('MerchantRemoteSource: Attempt 1 (logo key) failed');
    }

    // 2. Try merchants/me/logo/ with key 'avatar'
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final r = await _dio.post(
        'merchants/me/logo/',
        data: formData,
        options: Options(contentType: null),
      );
      AppLogger.info('MerchantRemoteSource: Uploaded to merchants/me/logo/ (avatar key)');
      return r.data as Map<String, dynamic>;
    } catch (e) {
      AppLogger.info('MerchantRemoteSource: Attempt 2 (avatar key) failed');
    }

    // 3. Try users/me/avatar/ with key 'avatar' (POST)
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final r = await _dio.post(
        'users/me/avatar/',
        data: formData,
        options: Options(contentType: null),
      );
      AppLogger.info('MerchantRemoteSource: Uploaded to users/me/avatar/ (POST)');
      return r.data as Map<String, dynamic>;
    } catch (e) {
      AppLogger.info('MerchantRemoteSource: Attempt 3 (POST users/me/avatar/) failed');
    }

    // 4. Try users/me/ with key 'avatar' (PATCH)
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final r = await _dio.patch(
        'users/me/',
        data: formData,
        options: Options(contentType: null),
      );
      AppLogger.info('MerchantRemoteSource: Uploaded to users/me/ (PATCH)');
      final data = r.data as Map<String, dynamic>;
      final profile = data['profile'] as Map<String, dynamic>?;
      return {
        'avatar_url': data['avatar_url'] ??
            profile?['logo_url'] ??
            profile?['avatar_url'],
      };
    } catch (e) {
      AppLogger.info('MerchantRemoteSource: Attempt 4 (PATCH users/me/) failed');
    }

    // 5. Try merchants/me/ with key 'logo' (PATCH)
    try {
      final formData = FormData.fromMap({
        'logo': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final r = await _dio.patch(
        'merchants/me/',
        data: formData,
        options: Options(contentType: null),
      );
      AppLogger.info('MerchantRemoteSource: Uploaded to merchants/me/ (PATCH)');
      final data = r.data as Map<String, dynamic>;
      return {
        'logo_url': data['logo_url'] ?? (data['profile'] as Map?)?['logo_url'],
      };
    } catch (e) {
      AppLogger.error('MerchantRemoteSource: All 5 upload attempts failed', e);
      rethrow;
    }
  }

  // ── Analytics ─────────────────────────────────────────────────────────────

  /// GET /analytics/merchant/?period=N
  /// [periodDays] is clamped to 1..365 by the server.
  Future<Map<String, dynamic>> fetchMerchantAnalytics({
    int periodDays = 30,
  }) async {
    final r = await _dio.get(
      'analytics/merchant/',
      queryParameters: {'period': periodDays},
    );
    return r.data as Map<String, dynamic>;
  }

  // ── Categories ────────────────────────────────────────────────────────────

  /// GET /categories/ — returns all active categories (no pagination).
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final r = await _dio.get('categories/');
    final data = r.data;
    // The categories endpoint has pagination disabled, so it's a plain list.
    if (data is List) return data.cast<Map<String, dynamic>>();
    // Guard against unexpected paginated wrapper.
    final results = (data as Map)['results'] ?? data;
    return (results as List).cast<Map<String, dynamic>>();
  }

  // ── Listings ──────────────────────────────────────────────────────────────

  /// GET /listings/my-listings/?status=<status>
  /// Returns ALL listings owned by the authenticated merchant (all statuses).
  /// Pass [status] to filter by a specific status (e.g. 'active', 'draft').
  Future<List<Map<String, dynamic>>> fetchMyListings({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    final r = await _dio.get(
      'listings/my-listings/',
      queryParameters: params.isEmpty ? null : params,
    );
    return _extractResults(r.data);
  }

  /// POST /listings/ — creates a new listing.
  Future<Map<String, dynamic>> createListing(
    Map<String, dynamic> data,
  ) async {
    final r = await _dio.post('listings/', data: data);
    return r.data as Map<String, dynamic>;
  }

  /// PATCH /listings/{id}/ — partial update of a listing.
  Future<Map<String, dynamic>> updateListing(
    String id,
    Map<String, dynamic> data,
  ) async {
    final r = await _dio.patch('listings/$id/', data: data);
    return r.data as Map<String, dynamic>;
  }

  /// DELETE /listings/{id}/
  Future<void> deleteListing(String id) async {
    await _dio.delete('listings/$id/');
  }

  /// POST /listings/{id}/photos/
  /// The backend expects a URL, not a raw file upload.
  /// Upload the image to cloud storage first, then pass the URL here.
  Future<Map<String, dynamic>> addListingPhotoUrl(
    String listingId,
    String photoUrl, {
    bool isPrimary = true,
  }) async {
    final r = await _dio.post(
      'listings/$listingId/photos/',
      data: {'photo_url': photoUrl, 'is_primary': isPrimary},
    );
    return r.data as Map<String, dynamic>;
  }

  /// POST /listings/{id}/photos/ — upload a local file as multipart form data.
  Future<Map<String, dynamic>> uploadListingPhoto(
    String listingId,
    String filePath, {
    bool isPrimary = true,
  }) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath),
      'is_primary': isPrimary,
    });
    final r = await _dio.post(
      'listings/$listingId/photos/',
      data: formData,
      options: Options(contentType: null), // Let Dio set the content-type with boundary
    );
    return r.data as Map<String, dynamic>;
  }

  /// POST /listings/{id}/mark-as-donation/
  Future<Map<String, dynamic>> markListingAsDonation(String id) async {
    final r = await _dio.post('listings/$id/mark-as-donation/');
    return r.data as Map<String, dynamic>;
  }

  /// POST /listings/{id}/unmark-as-donation/
  Future<Map<String, dynamic>> unmarkListingAsDonation(String id) async {
    final r = await _dio.post('listings/$id/unmark-as-donation/');
    return r.data as Map<String, dynamic>;
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final r = await _dio.get('orders/');
    return _extractResults(r.data);
  }

  /// GET /donations/requests/ — Returns donation requests for this merchant.
  Future<List<Map<String, dynamic>>> fetchDonationRequests() async {
    final r = await _dio.get('donations/requests/');
    return _extractResults(r.data);
  }

  /// POST /donations/{id}/approve/{request_id}/
  Future<Map<String, dynamic>> approveDonationRequest(String donationId, String requestId) async {
    final r = await _dio.post('donations/$donationId/approve/$requestId/');
    return r.data as Map<String, dynamic>;
  }

  /// POST /orders/{id}/fulfill/ — merchant confirms pickup using the QR hash.
  Future<Map<String, dynamic>> fulfillOrder(
    String orderId,
    String qrHash,
  ) async {
    final r = await _dio.post(
      'orders/$orderId/fulfill/',
      data: {'qr_hash': qrHash},
    );
    return r.data as Map<String, dynamic>;
  }

  /// POST /donations/{id}/fulfill/ — merchant confirms charity pickup using QR hash.
  Future<Map<String, dynamic>> fulfillDonation(
    String donationId,
    String qrHash,
  ) async {
    final r = await _dio.post(
      'donations/$donationId/fulfill/',
      data: {'qr_hash': qrHash},
    );
    return r.data as Map<String, dynamic>;
  }

  /// POST /orders/{id}/cancel/
  Future<Map<String, dynamic>> cancelOrder(
    String orderId, {
    String reason = '',
  }) async {
    final r = await _dio.post(
      'orders/$orderId/cancel/',
      data: {'reason': reason},
    );
    return r.data as Map<String, dynamic>;
  }

  /// POST /orders/{id}/mark-no-show/
  Future<Map<String, dynamic>> markOrderNoShow(String orderId) async {
    final r = await _dio.post('orders/$orderId/mark-no-show/');
    return r.data as Map<String, dynamic>;
  }

  /// POST /orders/fulfill-by-code/ — fulfil by entering the consumer's
  /// 6-character pickup code (fallback when camera QR scan is unavailable).
  Future<Map<String, dynamic>> fulfillOrderByPickupCode(
    String pickupCode,
  ) async {
    final r = await _dio.post(
      'orders/fulfill-by-code/',
      data: {'pickup_code': pickupCode.toUpperCase()},
    );
    return r.data as Map<String, dynamic>;
  }

  /// PATCH /merchants/me/location/ — update the merchant's map coordinates.
  ///
  /// [lat] and [lng] must be within Algeria's geographic bounds.
  /// [address] and [wilaya] are optional descriptive fields.
  Future<Map<String, dynamic>> updateLocation({
    required double lat,
    required double lng,
    String? address,
    String? wilaya,
  }) async {
    final data = <String, dynamic>{
      'latitude': lat,
      'longitude': lng,
    };
    if (address != null && address.isNotEmpty) data['address'] = address;
    if (wilaya != null && wilaya.isNotEmpty) data['wilaya'] = wilaya;
    final r = await _dio.patch('merchants/me/location/', data: data);
    return r.data as Map<String, dynamic>;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Normalises both a plain `List` and a cursor-paginated `{results: [...]}`.
  static List<Map<String, dynamic>> _extractResults(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    final results = (data as Map<String, dynamic>)['results'];
    if (results is List) return results.cast<Map<String, dynamic>>();
    return [];
  }
}



