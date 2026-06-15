import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_order.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MerchantOrderCard extends StatelessWidget {
  final MerchantOrder order;
  final VoidCallback? onTap;
  final VoidCallback? onScanTap;
  final VoidCallback? onCallTap;

  const MerchantOrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onScanTap,
    this.onCallTap,
  });

  static const Color primaryGreen = Color(0xFF2D8659);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeLeft = order.pickupEnd.difference(DateTime.now());
    final isUrgent = timeLeft.inMinutes < 60 && timeLeft.inMinutes > 0;
    final isCritical = timeLeft.inMinutes < 10 && timeLeft.inMinutes > 0;

    final statusColor = isCritical
        ? const Color(0xFFEF4444)
        : isUrgent
            ? const Color(0xFFF97316)
            : primaryGreen;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
                        child: Text(
                          _statusLabel(order.status, l10n).toUpperCase(),
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ),
                      Text(
                        '#${order.orderNumber}',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    order.customerName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        l10n.item_quantity(order.quantity, order.listingTitle),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                      ),
                      if (order.isDonation) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.volunteer_activism_rounded, size: 14, color: Color(0xFF2D8659)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _InfoPill(icon: Icons.payments_rounded, label: order.isDonation ? l10n.donation_free : '${order.totalAmount.toInt()} DZD'),
                      const SizedBox(width: 12),
                      _InfoPill(icon: Icons.access_time_filled_rounded, label: _pickupTimeLabel(order), color: statusColor),
                    ],
                  ),
                ],
              ),
            ),
            if (onScanTap != null)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onScanTap,
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                        label: Text(l10n.scan_qr_code.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    if (onCallTap != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
                        child: IconButton(
                          icon: const Icon(Icons.phone_rounded, color: primaryGreen),
                          onPressed: onCallTap,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _pickupTimeLabel(MerchantOrder order) {
    final start = '${order.pickupStart.hour.toString().padLeft(2, '0')}:${order.pickupStart.minute.toString().padLeft(2, '0')}';
    final end = '${order.pickupEnd.hour.toString().padLeft(2, '0')}:${order.pickupEnd.minute.toString().padLeft(2, '0')}';
    return '$start-$end';
  }

  String _statusLabel(OrderStatus status, AppLocalizations l10n) {
    switch (status) {
      case OrderStatus.pending: return l10n.status_pending;
      case OrderStatus.accepted: return l10n.status_accepted;
      case OrderStatus.active: return l10n.status_active;
      case OrderStatus.completed: return l10n.status_completed;
      case OrderStatus.cancelled: return l10n.status_cancelled;
      case OrderStatus.noShow: return l10n.status_no_show;
    }
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _InfoPill({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey.shade400),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color ?? const Color(0xFF374151)),
        ),
      ],
    );
  }
}



