import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/features/notifications/presentation/cubits/notifications_cubit.dart';
import 'package:anti_food_waste_app/features/notifications/presentation/cubits/notifications_state.dart';
import 'package:animate_do/animate_do.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color primaryGreen = AppTheme.primary;
  static const Color accentBeige = Colors.white;
  static const Color textNavy = Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: accentBeige,
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(context, l10n),
              Expanded(
                child: state is NotificationsLoading
                    ? const Center(child: CircularProgressIndicator(color: primaryGreen))
                    : state is NotificationsLoaded
                        ? state.notifications.isEmpty
                            ? _buildEmptyState(l10n)
                            : ListView.builder(
                                padding: const EdgeInsets.all(24),
                                itemCount: state.notifications.length,
                                itemBuilder: (context, index) {
                                  final notification = state.notifications[index];
                                  return FadeInUp(
                                    duration: const Duration(milliseconds: 400),
                                    delay: Duration(milliseconds: index * 50),
                                    child: _buildNotificationTile(notification, context),
                                  );
                                },
                              )
                        : state is NotificationsError
                            ? Center(child: Text(state.message))
                            : _buildEmptyState(l10n),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 24, 32),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.notifications,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.read<NotificationsCubit>().markAllAsRead(),
                child: Text(
                  l10n.mark_all_read.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.05), blurRadius: 30)]),
            child: Icon(CupertinoIcons.bell_slash, size: 64, color: primaryGreen.withOpacity(0.1)),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.no_notifications,
            style: TextStyle(color: textNavy.withOpacity(0.3), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(dynamic notification, BuildContext context) {
    final isUnread = !notification.isRead;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(isUnread ? 0.08 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: () {
            context.read<NotificationsCubit>().markAsRead(notification.id);
          },
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnread ? primaryGreen.withOpacity(0.08) : Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: isUnread ? primaryGreen : Colors.grey[400],
              size: 20,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isUnread ? FontWeight.w900 : FontWeight.w700,
              color: textNavy,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                notification.body,
                style: TextStyle(
                  fontSize: 13,
                  color: textNavy.withOpacity(0.6),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Just now', // Ideally formatted time
                style: TextStyle(
                  fontSize: 10,
                  color: textNavy.withOpacity(0.3),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.all(20),
          trailing: isUnread
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                )
              : null,
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'order':
        return CupertinoIcons.bag;
      case 'pickup':
        return Icons.local_shipping_rounded;
      case 'social':
        return CupertinoIcons.heart;
      default:
        return CupertinoIcons.bell;
    }
  }
}
