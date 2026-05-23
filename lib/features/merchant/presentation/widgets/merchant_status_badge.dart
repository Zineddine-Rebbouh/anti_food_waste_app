import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_listing.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_order.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MerchantStatusBadge extends StatelessWidget {
  final ListingStatus status;
  const MerchantStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String label;

    switch (status) {
      case ListingStatus.active:
        color = const Color(0xFF2D8659);
        label = l10n.status_active;
        break;
      case ListingStatus.draft:
        color = const Color(0xFFF59E0B);
        label = l10n.status_draft;
        break;
      case ListingStatus.soldOut:
        color = const Color(0xFF6B7280);
        label = l10n.status_sold_out;
        break;
      case ListingStatus.expired:
        color = const Color(0xFFEF4444);
        label = l10n.status_expired;
        break;
      case ListingStatus.paused:
        color = const Color(0xFFF97316);
        label = l10n.status_paused;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
      ),
    );
  }
}

class GradeBadge extends StatelessWidget {
  final FreshnessGrade grade;
  const GradeBadge({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String label;

    switch (grade) {
      case FreshnessGrade.a:
        color = const Color(0xFF2D8659);
        label = 'A';
        break;
      case FreshnessGrade.b:
        color = const Color(0xFFF59E0B);
        label = 'B';
        break;
      case FreshnessGrade.c:
        color = const Color(0xFFF97316);
        label = 'C';
        break;
      case FreshnessGrade.f:
        color = const Color(0xFFEF4444);
        label = 'F';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String label;

    switch (status) {
      case OrderStatus.pending:
        color = const Color(0xFFF59E0B);
        label = l10n.status_pending;
        break;
      case OrderStatus.accepted:
        color = const Color(0xFF3B82F6);
        label = l10n.status_accepted;
        break;
      case OrderStatus.active:
        color = const Color(0xFF3B82F6);
        label = l10n.status_active;
        break;
      case OrderStatus.completed:
        color = const Color(0xFF2D8659);
        label = l10n.status_completed;
        break;
      case OrderStatus.cancelled:
        color = const Color(0xFFEF4444);
        label = l10n.status_cancelled;
        break;
      case OrderStatus.noShow:
        color = const Color(0xFF6B7280);
        label = l10n.status_no_show;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
      ),
    );
  }
}



