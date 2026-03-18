import 'package:equatable/equatable.dart';
import '../../domain/models/app_notification.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();
  
  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final bool hasReachedMax;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    this.hasReachedMax = false,
  });

  NotificationsLoaded copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? hasReachedMax,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [notifications, unreadCount, hasReachedMax];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}
