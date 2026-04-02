import '../../../../core/network/api_client.dart';

class NotificationsRemoteSource {
  Future<Map<String, dynamic>> fetchNotifications({String? cursor, int limit = 20}) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (cursor != null) queryParams['cursor'] = cursor;

    // ApiClient.baseUrl already includes `/api/v1/`, so endpoints must be relative.
    final response = await ApiClient.dio.get('notifications/', queryParameters: queryParams);
    return response.data;
  }

  Future<Map<String, dynamic>> fetchUnreadCount() async {
    final response = await ApiClient.dio.get('notifications/unread-count/');
    return response.data;
  }

  Future<void> markAsRead(String id) async {
    // Backend expects a list of UUIDs.
    await ApiClient.dio.post(
      'notifications/mark-read/',
      data: {
        'notification_ids': [id],
      },
    );
  }

  Future<void> markAllAsRead() async {
    await ApiClient.dio.post('notifications/mark-all-read/');
  }
}
