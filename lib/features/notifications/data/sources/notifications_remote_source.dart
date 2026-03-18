import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class NotificationsRemoteSource {
  Future<Map<String, dynamic>> fetchNotifications({String? cursor, int limit = 20}) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (cursor != null) queryParams['cursor'] = cursor;

    final response = await ApiClient.dio.get('/api/v1/notifications/', queryParameters: queryParams);
    return response.data;
  }

  Future<Map<String, dynamic>> fetchUnreadCount() async {
    final response = await ApiClient.dio.get('/api/v1/notifications/unread-count/');
    return response.data;
  }

  Future<void> markAsRead(String id) async {
    await ApiClient.dio.post('/api/v1/notifications/$id/mark-read/');
  }

  Future<void> markAllAsRead() async {
    await ApiClient.dio.post('/api/v1/notifications/mark-all-read/');
  }
}
