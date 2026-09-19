import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_order.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_qr_scanner_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MerchantOrderDetailScreen extends StatelessWidget {
  final MerchantOrder order;

  const MerchantOrderDetailScreen({super.key, required this.order});

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color accentBeige = Colors.white;
  static const Color ink = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeLeft = order.pickupEnd.difference(DateTime.now());
    final isExpired = timeLeft.isNegative;

    return Scaffold(
      backgroundColor: accentBeige,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryGreen, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.order_with_number(order.orderNumber),
          style: const TextStyle(color: primaryGreen, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCustomerCard(order),
                const SizedBox(height: 18),
                _buildDetailsSection(order, l10n, isExpired),
                const SizedBox(height: 18),
                _buildTimelineSection(order, l10n),
                const SizedBox(height: 18),
                if (order.isPending) _buildActionButtons(context, order, l10n, isExpired),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(MerchantOrder order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryGreen.withOpacity(0.18), primaryGreen.withOpacity(0.06)]),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(order.customerName),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: primaryGreen),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              order.customerName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: ink, letterSpacing: -0.7),
            ),
          ),
          const SizedBox(height: 6),
          Text(order.maskedPhone, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(MerchantOrder order, AppLocalizations l10n, bool isExpired) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORDER DETAILS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF475569), letterSpacing: 1.8),
          ),
          const SizedBox(height: 22),
          _DetailItem(label: l10n.item_label, value: '${order.quantity}x ${order.listingTitle}'),
          const SizedBox(height: 14),
          const _StrongDivider(),
          const SizedBox(height: 14),
          _DetailItem(
            label: l10n.total,
            value: order.isDonation ? l10n.donation_label.toUpperCase() : '${order.totalAmount.toInt()} DZD',
            isMain: true,
          ),
          const SizedBox(height: 14),
          const _StrongDivider(),
          const SizedBox(height: 14),
          _DetailItem(
            label: l10n.payment_label,
            value: order.isDonation
                ? l10n.free_label.toUpperCase()
                : (order.paymentMethod == PaymentMethod.paidOnline
                    ? l10n.paid_online_label.toUpperCase()
                    : l10n.cash_on_pickup_label.toUpperCase()),
            valueColor: order.paymentMethod == PaymentMethod.paidOnline ? const Color(0xFF2D8659) : const Color(0xFFF97316),
          ),
          const SizedBox(height: 14),
          const _StrongDivider(),
          const SizedBox(height: 14),
          _DetailItem(
            label: l10n.pickup_window_label,
            value: '${_fmtTime(order.pickupStart)} - ${_fmtTime(order.pickupEnd)}',
            valueColor: isExpired ? Colors.red : primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(MerchantOrder order, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TIMELINE',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF475569), letterSpacing: 1.8),
          ),
          const SizedBox(height: 22),
          _TimelineRow(label: l10n.order_placed_label, time: _fmtTime(order.orderedAt), isDone: true),
          _TimelineRow(
            label: order.paymentMethod == PaymentMethod.paidOnline ? l10n.payment_confirmed_label : l10n.cash_on_pickup_label,
            time: order.paymentMethod == PaymentMethod.paidOnline ? _fmtTime(order.orderedAt.add(const Duration(minutes: 1))) : l10n.pending_label,
            isDone: order.paymentMethod == PaymentMethod.paidOnline || order.status == OrderStatus.completed,
          ),
          _TimelineRow(
            label: l10n.pickup_label,
            time: order.status == OrderStatus.completed ? _fmtTime(order.collectedAt ?? DateTime.now()) : l10n.scheduled_label,
            isDone: order.status == OrderStatus.completed,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, MerchantOrder order, AppLocalizations l10n, bool isExpired) {
    final canCancel = order.status == OrderStatus.pending || order.status == OrderStatus.accepted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        children: [
          if (order.status == OrderStatus.pending) ...[
            if (order.isDonation) ...[
              if (order.rawStatus == 'pending')
                _EditorialButton(
                  label: l10n.approve_donation_action,
                  icon: Icons.check_circle_rounded,
                  onPressed: () async {
                    await context.read<MerchantCubit>().approveDonationRequestAsync(order.listingId, order.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  color: const Color(0xFF2D8659),
                )
            ] else ...[
              _EditorialButton(
                label: "APPROVE ORDER",
                icon: Icons.check_circle_rounded,
                onPressed: () async {
                  await context.read<MerchantCubit>().acceptOrderAsync(order.id);
                  if (context.mounted) Navigator.pop(context);
                },
                color: const Color(0xFF2D8659),
              ),
            ],
          ] else if (order.status == OrderStatus.active || order.status == OrderStatus.accepted) ...[
            _EditorialButton(
              label: l10n.scan_qr_action,
              icon: Icons.qr_code_scanner_rounded,
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => BlocProvider.value(
                      value: context.read<MerchantCubit>(),
                      child: MerchantQrScannerScreen(preloadedOrder: order),
                    ),
                  ),
                );
              },
              color: primaryGreen,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _EditorialButton(
                  label: l10n.call_label.toUpperCase(),
                  icon: Icons.phone_rounded,
                  onPressed: () => _call(context, order.customerPhone),
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EditorialButton(
                  label: l10n.cancel.toUpperCase(),
                  icon: Icons.close_rounded,
                  onPressed: canCancel ? () => _showCancelDialog(context, order, l10n) : null,
                  isOutlined: true,
                  color: canCancel ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
          if (isExpired) ...[
            const SizedBox(height: 12),
            Text(
              'This order window has already passed.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.red.shade400),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _call(BuildContext context, String phone) async {
    if (phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is not available.')),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    if (!await canLaunchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone dialer.')),
        );
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 1).toUpperCase();
  }

  String _fmtTime(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Future<void> _showCancelDialog(BuildContext context, MerchantOrder order, AppLocalizations l10n) async {
    final merchantCubit = context.read<MerchantCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.cancel_order_confirm_title, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(l10n.cancel_order_confirm_msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.no_label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w900)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.cancel_order_action, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await merchantCubit.cancelOrderAsync(order.id);
        await merchantCubit.load();
        if (context.mounted) Navigator.pop(context);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not cancel this order. ${e.toString()}')),
          );
        }
      }
    }
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isMain;
  const _DetailItem({required this.label, required this.value, this.valueColor, this.isMain = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF334155), letterSpacing: 1.1),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isMain ? 20 : 15,
              fontWeight: FontWeight.w900,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}

class _StrongDivider extends StatelessWidget {
  const _StrongDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1.2, color: Color(0xFFE2E8F0));
  }
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final String time;
  final bool isDone;
  final bool isLast;
  const _TimelineRow({required this.label, required this.time, required this.isDone, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2D8659);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isDone ? primaryGreen : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isDone ? primaryGreen : Colors.grey.shade300, width: 2),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isDone ? primaryGreen.withOpacity(0.2) : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isDone ? const Color(0xFF0F172A) : Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditorialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isOutlined;

  const _EditorialButton({required this.label, required this.icon, required this.onPressed, this.color, this.isOutlined = false});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFF2D8659);
    if (isOutlined) {
      final disabled = onPressed == null;
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
        style: OutlinedButton.styleFrom(
          foregroundColor: disabled ? Colors.grey.shade400 : effectiveColor,
          side: BorderSide(color: (disabled ? Colors.grey.shade300 : effectiveColor.withOpacity(0.24)), width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size(double.infinity, 56),
      ),
    );
  }
}
