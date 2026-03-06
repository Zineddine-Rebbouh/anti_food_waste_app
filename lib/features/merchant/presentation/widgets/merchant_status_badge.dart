import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_listing.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_order.dart';

class MerchantStatusBadge extends StatelessWidget {
  final ListingStatus status;
  const MerchantStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    String label;

    switch (status) {
      case ListingStatus.active:
        bg = const Color(0xFF10B981);
        label = 'Active';
        break;
      case ListingStatus.draft:
        bg = const Color(0xFFF59E0B);
        label = 'Draft';
        break;
      case ListingStatus.soldOut:
        bg = const Color(0xFF6B7280);
        label = 'Sold Out';
        break;
      case ListingStatus.expired:
        bg = const Color(0xFFEF4444);
        label = 'Expired';
        break;
      case ListingStatus.paused:
        bg = const Color(0xFFF97316);
        label = 'Paused';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class GradeBadge extends StatelessWidget {
  final FreshnessGrade grade;
  const GradeBadge({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    Color bg;
    String label;

    switch (grade) {
      case FreshnessGrade.a:
        bg = const Color(0xFF10B981);
        label = 'Grade A';
        break;
      case FreshnessGrade.b:
        bg = const Color(0xFFF59E0B);
        label = 'Grade B';
        break;
      case FreshnessGrade.c:
        bg = const Color(0xFFF97316);
        label = 'Grade C';
        break;
      case FreshnessGrade.f:
        bg = const Color(0xFFEF4444);
        label = 'Grade F';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    String label;

    switch (status) {
      case OrderStatus.pending:
        bg = const Color(0xFF3B82F6);
        label = 'Pending';
        break;
      case OrderStatus.completed:
        bg = const Color(0xFF10B981);
        label = 'Completed';
        break;
      case OrderStatus.cancelled:
        bg = const Color(0xFFEF4444);
        label = 'Cancelled';
        break;
      case OrderStatus.noShow:
        bg = const Color(0xFF6B7280);
        label = 'No-Show';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
