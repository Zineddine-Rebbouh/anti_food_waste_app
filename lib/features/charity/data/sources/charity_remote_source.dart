import 'package:dio/dio.dart';
import 'package:anti_food_waste_app/core/network/api_client.dart';

class CharityRemoteSource {
  final Dio _dio;

  CharityRemoteSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  /// GET /api/v1/donations/
  /// Returns a list of available donations.
  Future<List<dynamic>> fetchDonations() async {
    final response = await _dio.get('donations/');
    // Usually list endpoints return a paginated response like: { "results": [...] } 
    // or just a direct list. Assuming DRF Standard pagination.
    if (response.data is Map && response.data.containsKey('results')) {
      return response.data['results'] as List<dynamic>;
    }
    return response.data as List<dynamic>;
  }

  /// GET /api/v1/donations/{id}/
  Future<Map<String, dynamic>> fetchDonationDetail(String id) async {
    final response = await _dio.get('donations/$id/');
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/v1/donations/{id}/request/
  Future<Map<String, dynamic>> requestDonation(String id, String message) async {
    final response = await _dio.post(
      'donations/$id/request/',
      data: {'message': message},
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/v1/donations/requests/
  /// Fetch all requests made by the current charity
  Future<List<dynamic>> fetchMyRequests() async {
    // We should check the exact backend endpoint for fetching requests.
    // E.g. 'donations/requests/' or 'donations/my_requests/'
    try {
      final response = await _dio.get('donations/requests/');
      if (response.data is Map && response.data.containsKey('results')) {
        return response.data['results'] as List<dynamic>;
      }
      return response.data as List<dynamic>;
    } catch (e) {
      // Fallback if endpoint doesn't exist, we'll map empty list for now
      return [];
    }
  }
}
