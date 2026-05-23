import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';

/// A coloured pill badge displaying a [PickupRequestStatus]. 
/// Used in the charity requests screen. 
class CharityStatusBadge extends StatelessWidget {
  final PickupRequestStatus status;

  const CharityStatusBadge({super.key, required this.status});

  Color get _bg {
    switch (status) {
      case PickupRequestStatus.pending:
        return Colors.amber.shade50;
      case PickupRequestStatus.approved:
        return Colors.blue.shade50;
      case PickupRequestStatus.enRoute:
        return Colors.purple.shade50;
      case PickupRequestStatus.collected:
        return AppTheme.primary.withOpacity(0.08);
      case PickupRequestStatus.cancelled:
        return Colors.red.shade50;
    }
  }

  Color get _fg {
    switch (status) {
      case PickupRequestStatus.pending:
        return Colors.amber.shade800;
      case PickupRequestStatus.approved:
        return Colors.blue.shade700;
      case PickupRequestStatus.enRoute:
        return Colors.purple.shade700;
      case PickupRequestStatus.collected:
        return AppTheme.primary;
      case PickupRequestStatus.cancelled:
        return Colors.red.shade700;
    }
  }

  IconData get _icon {
    switch (status) {
      case PickupRequestStatus.pending:
        return Icons.hourglass_top_rounded;
      case PickupRequestStatus.approved:
        return Icons.check_circle_outline_rounded;
      case PickupRequestStatus.enRoute:
        return Icons.local_shipping_outlined;
      case PickupRequestStatus.collected:
        return Icons.task_alt_rounded;
      case PickupRequestStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case PickupRequestStatus.pending:
        return l10n.status_pending;
      case PickupRequestStatus.approved:
        return l10n.status_approved;
      case PickupRequestStatus.enRoute:
        return l10n.en_route;
      case PickupRequestStatus.collected:
        return l10n.status_completed;
      case PickupRequestStatus.cancelled:
        return l10n.status_cancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _fg.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13, color: _fg),
          const SizedBox(width: 5),
          Text(
            _label(context),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _fg,
            ),
          ),
        ],
      ),
    );
  }
}



