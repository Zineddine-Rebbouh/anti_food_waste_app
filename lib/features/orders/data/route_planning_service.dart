import 'package:dio/dio.dart';
import 'package:anti_food_waste_app/core/network/api_client.dart';
import 'package:anti_food_waste_app/features/orders/domain/models/route_plan.dart';

/// API service for route planning.
///
/// Calls POST /orders/route-plan/ and returns a structured [RoutePlan].
class RoutePlanningService {
  final Dio _dio;

  RoutePlanningService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  /// Compute an optimized pickup route.
  ///
  /// [userLat] / [userLng] — consumer's current GPS coordinates.
  /// [orderIds] — list of active order UUID strings to include.
  /// [prefix] — 'orders' or 'donations' depending on the module.
  Future<RoutePlan> planRoute({
    required double userLat,
    required double userLng,
    required List<String> orderIds,
    String prefix = 'orders',
  }) async {
    final response = await _dio.post(
      '$prefix/route-plan/',
      data: {
        'user_latitude': userLat,
        'user_longitude': userLng,
        'order_ids': orderIds,
      },
    );
    return RoutePlan.fromJson(response.data as Map<String, dynamic>);
  }
}
