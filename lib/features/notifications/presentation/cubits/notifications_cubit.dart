import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;
  String? _nextCursor;
  bool _isFetching = false;

  NotificationsCubit(this._repository) : super(NotificationsInitial());

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (_isFetching) return;
    
    if (refresh) {
      _nextCursor = null;
    }

    if (!refresh && state is NotificationsLoaded) {
      if ((state as NotificationsLoaded).hasReachedMax) return;
    }

    _isFetching = true;

    if (state is! NotificationsLoaded) {
      emit(NotificationsLoading());
    }

    try {
      final notifications = await _repository.getNotifications(cursor: _nextCursor);
      final unreadCount = await _repository.getUnreadCount();

      // In a real app we would parse the 'next' URL to get the cursor
      // For now we'll mock that logic or leave it without cursor paginating further
      _nextCursor = null; // Update with actual cursor logic if needed

      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        emit(NotificationsLoaded(
          notifications: refresh ? notifications : [...currentState.notifications, ...notifications],
          unreadCount: unreadCount,
          hasReachedMax: notifications.length < 20,
        ));
      } else {
        emit(NotificationsLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
          hasReachedMax: notifications.length < 20,
        ));
      }
    } catch (e) {
      emit(NotificationsError(e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> markAsRead(String id) async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      
      try {
        await _repository.markAsRead(id);
        
        final updatedNotifications = currentState.notifications.map((n) {
          if (n.id == id && !n.isRead) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();

        final unreadCount = await _repository.getUnreadCount();
        
        emit(currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ));
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> markAllAsRead() async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      
      try {
        await _repository.markAllAsRead();
        
        final updatedNotifications = currentState.notifications.map((n) {
          return n.copyWith(isRead: true);
        }).toList();

        emit(currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        ));
      } catch (e) {
        // Handle error
      }
    }
  }
}
