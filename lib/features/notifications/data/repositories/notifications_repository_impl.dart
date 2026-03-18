import '../../domain/models/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../sources/notifications_remote_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteSource _remoteSource;

  NotificationsRepositoryImpl({NotificationsRemoteSource? remoteSource}) 
    : _remoteSource = remoteSource ?? NotificationsRemoteSource();

  @override
  Future<List<AppNotification>> getNotifications({String? cursor, int limit = 20}) async {
    final response = await _remoteSource.fetchNotifications(cursor: cursor, limit: limit);
    final results = response['results'] as List;
    return results.map((v) => AppNotification.fromJson(v as Map<String, dynamic>)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _remoteSource.fetchUnreadCount();
    return response['unread_count'] as int;
  }

  @override
  Future<void> markAsRead(String id) async {
    await _remoteSource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() async {
    await _remoteSource.markAllAsRead();
  }
}
