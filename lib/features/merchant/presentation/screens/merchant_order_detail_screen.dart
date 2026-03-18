import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_order.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_qr_scanner_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/widgets/merchant_status_badge.dart';

class MerchantOrderDetailScreen extends StatelessWidget {
  final MerchantOrder order;

  const MerchantOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final timeLeft = order.pickupEnd.difference(DateTime.now());
    final isExpired = timeLeft.isNegative;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '#${order.orderNumber}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Customer Section
            _Section(
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D8659).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(order.customerName),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D8659),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    order.customerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _callCustomer(order.customerPhone),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone, size: 14, color: Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Text(
                          order.maskedPhone,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!order.isDonation) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.eco_outlined,
                            size: 14, color: Color(0xFF10B981)),
                        const SizedBox(width: 4),
                        Text(
                          'Eco-Score: ${order.customerEcoScore.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Order Details
            _Section(
              title: 'Order Details',
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Items',
                    value: '${order.quantity}x ${order.listingTitle}',
                  ),
                  const Divider(height: 20, color: Color(0xFFF3F4F6)),
                  _DetailRow(
                    label: 'Total',
                    value: order.isDonation
                        ? 'Free (Donation)'
                        : '${order.totalAmount.toStringAsFixed(0)} DZD',
                    valueColor: order.isDonation
                        ? const Color(0xFF2D8659)
                        : const Color(0xFF111827),
                    bold: true,
                  ),
                  const Divider(height: 20, color: Color(0xFFF3F4F6)),
                  _DetailRow(
                    label: 'Payment',
                    valueWidget: Row(
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
                              ? 'Donation'
                              : order.paymentMethod == PaymentMethod.paidOnline
                                  ? 'Paid Online ✓'
                                  : 'Cash on Pickup',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: order.isDonation
                                ? const Color(0xFF2D8659)
                                : order.paymentMethod ==
                                        PaymentMethod.paidOnline
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF97316),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 20, color: Color(0xFFF3F4F6)),
                  _DetailRow(
                    label: 'Status',
                    valueWidget: OrderStatusBadge(status: order.status),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Pickup Info
            _Section(
              title: 'Pickup Window',
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Time',
                    value:
                        '${_fmtTime(order.pickupStart)} – ${_fmtTime(order.pickupEnd)}',
                  ),
                  const Divider(height: 20, color: Color(0xFFF3F4F6)),
                  _DetailRow(
                    label: isExpired ? 'Status' : 'Closes in',
                    value: isExpired
                        ? 'Expired'
                        : _formatCountdown(timeLeft),
                    valueColor: isExpired
                        ? const Color(0xFFEF4444)
                        : order.isCritical
                            ? const Color(0xFFEF4444)
                            : order.isUrgent
                                ? const Color(0xFFF97316)
                                : const Color(0xFF374151),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Special Instructions
            if (order.specialInstructions != null) ...[
              _Section(
                title: 'Special Instructions',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.specialInstructions!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Timeline
            _Section(
              title: 'Timeline',
              child: Column(
                children: [
                  _TimelineItem(
                    label: 'Order Placed',
                    time: _fmtDateTime(order.orderedAt),
                    done: true,
                  ),
                  _TimelineItem(
                    label: order.paymentMethod == PaymentMethod.paidOnline
                        ? 'Payment Confirmed'
                        : 'Cash on Pickup',
                    time: order.paymentMethod == PaymentMethod.paidOnline
                        ? _fmtDateTime(order.orderedAt
                            .add(const Duration(minutes: 1)))
                        : 'To be collected',
                    done:
                        order.paymentMethod == PaymentMethod.paidOnline,
                  ),
                  _TimelineItem(
                    label: 'Pickup Window',
                    time:
                        '${_fmtTime(order.pickupStart)}–${_fmtTime(order.pickupEnd)}',
                    done: order.status == OrderStatus.completed,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: order.isPending
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (_) => BlocProvider.value(
                                value: context.read<MerchantCubit>(),
                                child: MerchantQrScannerScreen(
                                    preloadedOrder: order),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code_scanner, size: 20),
                        label: const Text('Scan QR Code',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D8659),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _callCustomer(order.customerPhone),
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Call Customer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2D8659),
                          side: const BorderSide(color: Color(0xFF2D8659)),
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    if (isExpired) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showNoShowDialog(context, order),
                          icon: const Icon(Icons.person_off_outlined,
                              size: 18),
                          label: const Text('Mark No-Show'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF97316),
                            side: const BorderSide(
                                color: Color(0xFFF97316)),
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showCancelDialog(context, order),
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Cancel Order'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(
                              color: Color(0xFFEF4444)),
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  String _fmtTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _fmtDateTime(DateTime dt) {
    return '${_fmtTime(dt)} • ${dt.day}/${dt.month}';
  }

  String _formatCountdown(Duration d) {
    if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes % 60}min';
    return '${d.inMinutes} minutes';
  }

  void _callCustomer(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _showCancelDialog(
      BuildContext context, MerchantOrder order) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Order'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
              hintText: 'Reason (optional)'),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_, false),
            child: const Text('Keep Order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444)),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await context
          .read<MerchantCubit>()
          .cancelOrderAsync(order.id, reason: reasonCtrl.text.trim());
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _showNoShowDialog(
      BuildContext context, MerchantOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mark No-Show'),
        content: const Text(
            'Mark this customer as a no-show? The order will be closed and the listing slot released.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF97316)),
            child: const Text('Mark No-Show'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await context.read<MerchantCubit>().markNoShowAsync(order.id);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }
}

// ── Supporting Widgets ────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String? title;
  final Widget child;

  const _Section({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final Color? valueColor;
  final bool bold;

  const _DetailRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        if (valueWidget != null)
          valueWidget!
        else
          Text(
            value ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? const Color(0xFF111827),
            ),
          ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String label;
  final String time;
  final bool done;
  final bool isLast;

  const _TimelineItem({
    required this.label,
    required this.time,
    required this.done,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? const Color(0xFF2D8659) : Colors.white,
                border: Border.all(
                  color: done ? const Color(0xFF2D8659) : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: done
                    ? const Color(0xFF2D8659).withOpacity(0.3)
                    : const Color(0xFFE5E7EB),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: done
                        ? const Color(0xFF374151)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
