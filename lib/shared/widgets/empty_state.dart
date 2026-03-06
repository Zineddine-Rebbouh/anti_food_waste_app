import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

enum EmptyStateType { location, noListings, noResults, networkError, favorites }

class EmptyState extends StatelessWidget {
  final EmptyStateType type;
  final VoidCallback? onAction;
  final VoidCallback? onSecondaryAction;

  const EmptyState({
    super.key,
    required this.type,
    this.onAction,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (type) {
      case EmptyStateType.location:
        return _buildState(
          context,
          icon: Icons.location_on_outlined,
          title: l10n.enable_location_title,
          description: l10n.location_permission_desc,
          secondaryDescription: l10n.location_privacy,
          actionLabel: l10n.enable_location_btn,
          secondaryActionLabel: l10n.enter_address_manually,
        );
      case EmptyStateType.noListings:
        return _buildState(
          context,
          icon: Icons.restaurant_outlined,
          title: l10n.no_deals_nearby,
          description: l10n.try_expanding,
          actionLabel: l10n.expand_radius,
          isEmoji: true,
          emoji: '🍽️',
        );
      case EmptyStateType.noResults:
        return _buildState(
          context,
          icon: Icons.search_off_outlined,
          title: l10n.no_results_filters,
          description: l10n.active_filters,
          actionLabel: l10n.adjust_filters,
          secondaryActionLabel: l10n.clear_filters,
        );
      case EmptyStateType.networkError:
        return _buildState(
          context,
          icon: Icons.wifi_off_outlined,
          title: l10n.network_error,
          description: l10n.check_connection,
          actionLabel: l10n.retry,
          secondaryActionLabel: l10n.contact_support,
        );
      case EmptyStateType.favorites:
        return _buildState(
          context,
          icon: Icons.favorite_border,
          title: l10n.no_favorites_yet,
          description: l10n.favorites_description,
          actionLabel: l10n.browse_deals,
        );
    }
  }

  Widget _buildState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    String? secondaryDescription,
    required String actionLabel,
    String? secondaryActionLabel,
    bool isEmoji = false,
    String? emoji,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isEmoji
                  ? Text(
                      emoji!,
                      style: const TextStyle(fontSize: 48),
                    )
                  : Icon(
                      icon,
                      size: 64,
                      color: AppTheme.primary,
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (secondaryDescription != null) ...[
            const SizedBox(height: 8),
            Text(
              secondaryDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ),
          if (secondaryActionLabel != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onSecondaryAction,
              child: Text(
                secondaryActionLabel,
                style: const TextStyle(color: AppTheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
