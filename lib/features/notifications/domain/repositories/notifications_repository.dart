import '../models/app_notification.dart';

abstract class NotificationsRepository {
  Future<List<AppNotification>> getNotifications({String? cursor, int limit = 20});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}
