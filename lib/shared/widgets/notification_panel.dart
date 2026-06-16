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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;
    final handleColor = colorScheme.onSurface.withOpacity(0.2);

    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
          mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: handleColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: BlocBuilder<NotificationsCubit, NotificationsState>(
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
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
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
                              ? _buildEmptyState(context, l10n)
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final textColor = Theme.of(context).colorScheme.onSurface;
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
            child: Icon(CupertinoIcons.bell_slash, size: 48, color: forestGreen.withOpacity(0.4)),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.no_notifications,
            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll notify you when something important happens.",
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, AppNotification notification) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = colorScheme.surfaceContainerHighest;
    final titleColor = colorScheme.onSurface;
    final bodyColor = colorScheme.onSurface.withOpacity(0.55);
    return InkWell(
      onTap: () => context.read<NotificationsCubit>().markAsRead(notification.id),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: notification.isRead ? null : Border.all(color: forestGreen.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: forestGreen.withOpacity(0.12),
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
                            color: titleColor,
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
                      color: bodyColor,
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
