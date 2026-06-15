import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:animate_do/animate_do.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

import 'package:anti_food_waste_app/features/notifications/presentation/cubits/notifications_cubit.dart';
import 'package:anti_food_waste_app/features/notifications/presentation/cubits/notifications_state.dart';
import 'package:anti_food_waste_app/features/notifications/domain/models/app_notification.dart';

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  static const Color forestGreen = AppTheme.primary;
  static const Color accentBeige = Colors.white;
  static const Color textNavy = Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: accentBeige,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
          mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              var unreadCount = 0;
              var notifications = <AppNotification>[];

              if (state is NotificationsLoaded) {
                unreadCount = state.unreadCount;
                notifications = state.notifications;
              }

              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.notifications,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: textNavy,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (unreadCount > 0) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: forestGreen,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (unreadCount > 0)
                          TextButton(
                            onPressed: () => context.read<NotificationsCubit>().markAllAsRead(),
                            style: TextButton.styleFrom(
                              foregroundColor: forestGreen,
                              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                            child: Text(l10n.mark_all_read),
                          ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: state is NotificationsLoading
                        ? const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(child: CircularProgressIndicator(color: forestGreen)),
                          )
                        : notifications.isEmpty
                            ? _buildEmptyState(l10n)
                            : ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                                itemCount: notifications.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final notification = notifications[index];
                                  return FadeInUp(
                                    duration: const Duration(milliseconds: 300),
                                    delay: Duration(milliseconds: index * 50),
                                    child: _buildNotificationItem(context, notification),
                                  );
                                },
                              ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: forestGreen.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(CupertinoIcons.bell_slash, size: 48, color: forestGreen.withOpacity(0.2)),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.no_notifications,
            style: const TextStyle(color: textNavy, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll notify you when something important happens.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, AppNotification notification) {
    return InkWell(
      onTap: () => context.read<NotificationsCubit>().markAsRead(notification.id),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: notification.isRead ? null : Border.all(color: forestGreen.withOpacity(0.1), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: forestGreen.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.bell_fill, color: forestGreen, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.isRead ? FontWeight.w700 : FontWeight.w900,
                            color: textNavy,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: forestGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
