import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_order.dart';

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

  @override
  Widget build(BuildContext context) {
    final timeLeft = order.pickupEnd.difference(DateTime.now());
    final isUrgent = timeLeft.inMinutes < 60 && timeLeft.inMinutes > 0;
    final isCritical = timeLeft.inMinutes < 10 && timeLeft.inMinutes > 0;

    final countdownColor = isCritical
        ? const Color(0xFFEF4444)
        : isUrgent
            ? const Color(0xFFF97316)
            : const Color(0xFF374151);

    final leftBorderColor = isCritical
        ? const Color(0xFFEF4444)
        : isUrgent
            ? const Color(0xFFF97316)
            : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: leftBorderColor, width: 4),
            right: const BorderSide(color: Color(0xFFE5E7EB)),
            top: const BorderSide(color: Color(0xFFE5E7EB)),
            bottom: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTime(order.orderedAt),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  Row(
                    children: [
                      if (order.isDonation)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Text(
                            'DONATION',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Text(
                        '#${order.orderNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Customer
              Text(
                order.customerName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: onCallTap,
                child: Row(
                  children: [
                    const Icon(Icons.phone,
                        size: 12, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      order.maskedPhone,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Items
              Text(
                '${order.quantity}x ${order.listingTitle}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 6),
              // Payment
              Row(
                children: [
                  Icon(
                    order.paymentMethod == PaymentMethod.paidOnline
                        ? Icons.credit_card
                        : Icons.payments_outlined,
                    size: 14,
                    color: order.paymentMethod == PaymentMethod.paidOnline
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF97316),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.isDonation
                        ? 'Donation (Free)'
                        : order.paymentMethod == PaymentMethod.paidOnline
                            ? 'Paid Online (${order.totalAmount.toStringAsFixed(0)} DZD)'
                            : 'Cash on Pickup (${order.totalAmount.toStringAsFixed(0)} DZD)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: order.paymentMethod == PaymentMethod.paidOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF97316),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Pickup window
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 4),
                  Text(
                    _pickupLabel(order, timeLeft),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: countdownColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Actions
              SizedBox(
                height: 44,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onScanTap,
                  icon:
                      const Icon(Icons.qr_code_scanner, size: 18),
                  label: const Text(
                    'Scan QR Code',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              if (onCallTap != null) ...[
                const SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onCallTap,
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Call Customer',
                        style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _pickupLabel(MerchantOrder order, Duration timeLeft) {
    final startStr =
        '${order.pickupStart.hour.toString().padLeft(2, '0')}:${order.pickupStart.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${order.pickupEnd.hour.toString().padLeft(2, '0')}:${order.pickupEnd.minute.toString().padLeft(2, '0')}';

    String base = 'Pickup: $startStr-$endStr';

    if (timeLeft.isNegative) return '$base (Expired)';

    if (timeLeft.inHours >= 1) {
      return '$base (In ${timeLeft.inHours}h ${timeLeft.inMinutes % 60}min)';
    } else if (timeLeft.inMinutes > 0) {
      return '$base (In ${timeLeft.inMinutes} minutes)';
    }
    return base;
  }
}
