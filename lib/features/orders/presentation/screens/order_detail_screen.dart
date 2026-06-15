import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/orders/presentation/cubits/orders_cubit.dart';
import 'package:anti_food_waste_app/features/orders/presentation/screens/route_plan_screen.dart';
import 'package:anti_food_waste_app/features/orders/presentation/widgets/leave_review_sheet.dart';
import 'package:anti_food_waste_app/core/config/app_config.dart';

/// Full detail screen for a single order.
///
/// Displays order info, merchant details, pricing, pickup window, status,
/// QR code (for active orders), and a "Get Directions" button.
class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  static const Color primaryGreen = AppTheme.primary;
  static const Color secondaryGreen = AppTheme.primary;
  static const Color textDark = Color(0xFF081C15);
  static const Color accentBeige = Color(0xFFF7F9F7);
  static const Color surfaceWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: accentBeige,
      body: CustomScrollView(
        slivers: [
          // ── App Bar with image ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: primaryGreen,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.2),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              if (order.status == OrderStatus.accepted)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.2),
                    child: IconButton(
                      icon: const Icon(Icons.qr_code_2_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => _showQrBottomSheet(context, l10n),
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  () {
                    final displayImage = order.merchantCoverUrl.isNotEmpty
                        ? order.merchantCoverUrl
                        : order.merchantImage;

                    if (displayImage.isNotEmpty) {
                      return Image.network(
                        _getFullImageUrl(displayImage),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackHeader(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: primaryGreen.withOpacity(0.05),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: primaryGreen,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return _buildFallbackHeader();
                    }
                  }(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order title + merchant
                  FadeInUp(
                    duration: const Duration(milliseconds: 300),
                    child: _buildHeaderSection(l10n),
                  ),
                  const SizedBox(height: 20),

                  // Order details card
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: _buildOrderInfoCard(l10n),
                  ),
                  const SizedBox(height: 16),

                  // Merchant info card
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: _buildMerchantCard(context, l10n),
                  ),
                  const SizedBox(height: 16),

                  // Pickup info card
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: _buildPickupCard(l10n),
                  ),
                  const SizedBox(height: 16),

                  // Payment info card
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: _buildPaymentCard(l10n),
                  ),

                  // Cancellation reason (if cancelled)
                  if (order.status == OrderStatus.canceled &&
                      order.cancellationReason.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: _buildCancellationCard(l10n),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action buttons
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: _buildActionButtons(context, l10n),
                  ),

                  const SizedBox(height: 24),

                  // Help & Support card
                  FadeInUp(
                    duration: const Duration(milliseconds: 900),
                    child: _buildHelpCard(l10n, context),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeaderSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                order.items,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildStatusChip(order.status, l10n),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.storefront, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                order.merchantName,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          order.orderNumber,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Order Info Card ────────────────────────────────────────────────────

  Widget _buildOrderInfoCard(AppLocalizations l10n) {
    return _card(
      title: l10n.order_details,
      icon: Icons.receipt_long_outlined,
      children: [
        _infoRow(l10n.item_label, order.items),
        _infoRow(l10n.quantity, '${order.quantity}'),
        _infoRow(l10n.unit_price,
            '${order.unitPrice.toStringAsFixed(0)} ${order.currency}'),
        _divider(),
        _infoRow(
          l10n.total_label,
          '${order.price.toStringAsFixed(0)} ${order.currency}',
          isBold: true,
          valueColor: primaryGreen,
        ),
      ],
    );
  }

  // ── Merchant Card ────────────────────────────────────────────────────

  Widget _buildMerchantCard(BuildContext context, AppLocalizations l10n) {
    return _card(
      title: l10n.merchant,
      icon: Icons.store_outlined,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: order.merchantLogoUrl.isNotEmpty
                    ? Image.network(
                        _getFullImageUrl(order.merchantLogoUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.store_rounded,
                            color: primaryGreen,
                            size: 20),
                      )
                    : const Icon(Icons.store_rounded,
                        color: primaryGreen, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                order.merchantName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _divider(),
        if (order.address.isNotEmpty) _infoRow(l10n.address, order.address),
        if (order.merchantPhone.isNotEmpty)
          InkWell(
            onTap: () => _callMerchant(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.phone,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  Row(
                    children: [
                      Text(
                        order.merchantPhone,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.phone_rounded,
                          size: 14, color: primaryGreen),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── Pickup Card ──────────────────────────────────────────────────────

  Widget _buildPickupCard(AppLocalizations l10n) {
    return _card(
      title: l10n.pickup_window,
      icon: Icons.access_time_outlined,
      children: [
        if (order.pickupTime.isNotEmpty)
          _infoRow(l10n.time_label, order.pickupTime),
        _infoRow(l10n.date_label, order.pickupDate),
        if (order.status == OrderStatus.pending)
          _infoRow(l10n.status_label, l10n.awaiting_approval,
              valueColor: Colors.blue),
        if (order.status == OrderStatus.accepted)
          _infoRow(l10n.status_label, l10n.waiting_for_pickup,
              valueColor: Colors.orange),
        if (order.status == OrderStatus.collected)
          _infoRow(l10n.status_label, l10n.collected_check,
              valueColor: primaryGreen),
      ],
    );
  }

  // ── Payment Card ─────────────────────────────────────────────────────

  Widget _buildPaymentCard(AppLocalizations l10n) {
    final methodLabel = order.paymentMethod == 'cash'
        ? l10n.cash_on_pickup
        : l10n.online_payment;
    final isPaid = order.paymentStatus == 'completed' ||
        (order.paymentMethod == 'cash' &&
            order.status == OrderStatus.collected);

    final (statusLabel, statusColor) = isPaid
        ? (l10n.paid_status, primaryGreen)
        : switch (order.paymentStatus) {
            'refunded' => (l10n.refunded_status, Colors.blue),
            'failed' => (l10n.failed_status, Colors.red),
            _ => (l10n.pending_status, Colors.orange),
          };

    return _card(
      title: l10n.payment_label,
      icon: Icons.payment_outlined,
      children: [
        _infoRow(l10n.payment_method_label, methodLabel),
        _infoRow(l10n.status_label, statusLabel, valueColor: statusColor),
        _infoRow(
            l10n.amount, '${order.price.toStringAsFixed(0)} ${order.currency}',
            isBold: true),
      ],
    );
  }

  // ── Cancellation Card ──────────────────────────────────────────────

  Widget _buildCancellationCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cancel_outlined, size: 18, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text(
                l10n.cancellation_reason,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.cancellationReason,
            style: TextStyle(
              fontSize: 13,
              color: Colors.red.shade900,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ───────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    final isActiveOrder = order.status == OrderStatus.pending ||
        order.status == OrderStatus.accepted;

    return Column(
      children: [
        // Plan Route — only for active (pending / accepted) orders
        if (isActiveOrder) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoutePlanScreen(orderIds: [order.id]),
                  ),
                );
              },
              icon: const Icon(Icons.directions_rounded, size: 20),
              label: Text(l10n.plan_route),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Review Button for collected orders
        if (order.status == OrderStatus.collected) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => BlocProvider.value(
                    value: context.read<OrdersCubit>(),
                    child: LeaveReviewSheet(order: order),
                  ),
                );
              },
              icon: const Icon(Icons.star_rate_rounded, size: 20),
              label: Text(l10n.leave_review),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade500,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Open in Google Maps — fallback direct link
        if (order.hasLocation)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openDirectInGoogleMaps(),
              icon: const Icon(Icons.map_rounded, size: 18),
              label: Text(l10n.open_in_google_maps),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryGreen,
                side: BorderSide(color: primaryGreen.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        if (order.status == OrderStatus.pending ||
            order.status == OrderStatus.accepted) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showCancelBottomSheet(context, l10n),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: Text(l10n.cancel_reservation),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showCancelBottomSheet(BuildContext context, AppLocalizations l10n) {
    final createdAt =
        DateTime.tryParse(order.createdAt)?.toLocal() ?? DateTime.now();
    final diff = DateTime.now().difference(createdAt);
    final isFree = diff.inMinutes <= 15;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Icon header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isFree ? Colors.blue.shade50 : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFree ? Icons.info_outline : Icons.warning_amber_rounded,
                size: 32,
                color: isFree ? Colors.blue.shade600 : Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              l10n.cancel_reservation_title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              isFree
                  ? l10n.cancel_grace_period_message
                  : l10n.cancel_penalty_message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      l10n.keep_reservation,
                      style: const TextStyle(
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await context.read<OrdersCubit>().cancelOrder(order.id);
                        if (context.mounted) {
                          Navigator.pop(context); // Go back to list
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isFree ? Colors.grey[800] : Colors.red[600],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      l10n.confirm_cancel_reservation,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Status Chip ─────────────────────────────────────────────────────────

  Widget _buildStatusChip(OrderStatus status, AppLocalizations l10n) {
    final (color, label, icon) = switch (status) {
      OrderStatus.pending => (
          Colors.blue,
          l10n.status_pending,
          Icons.hourglass_empty
        ),
      OrderStatus.accepted => (
          Colors.orange,
          l10n.status_accepted,
          Icons.thumb_up_alt_outlined
        ),
      OrderStatus.collected => (
          const Color(0xFF6B7280),
          l10n.status_collected,
          Icons.check_circle
        ),
      OrderStatus.canceled => (
          Colors.red,
          l10n.status_canceled,
          Icons.cancel_outlined
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared card builder ─────────────────────────────────────────────────

  Widget _card({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: valueColor ?? const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Divider(color: Colors.grey.shade200, height: 1),
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  Widget _buildFallbackHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryGreen, secondaryGreen],
        ),
      ),
      child: Center(
        child: FadeIn(
          duration: const Duration(seconds: 1),
          child: Icon(
            Icons.restaurant_rounded,
            size: 140,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
    );
  }

  String _getFullImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;

    final uri = Uri.parse(AppConfig.baseUrl);
    final baseUrl =
        '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';

    final cleanPath = path.startsWith('/') ? path : '/$path';

    if (!cleanPath.contains('/media/') && !cleanPath.contains('/static/')) {
      return '$baseUrl/media$cleanPath';
    }

    return '$baseUrl$cleanPath';
  }

  Future<void> _callMerchant() async {
    final uri = Uri.parse('tel:${order.merchantPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openDirectInGoogleMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${order.merchantLatitude},${order.merchantLongitude}'
      '&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showQrBottomSheet(
      BuildContext context, AppLocalizations l10n) async {
    // Try to fetch fresh QR data
    Map<String, dynamic>? qrData;
    try {
      qrData = await context.read<OrdersCubit>().fetchOrderQr(order.id);
    } catch (_) {}

    if (!context.mounted) return;

    final qrContent = qrData != null
        ? jsonEncode({
            'order_id': qrData['order_id'] ?? order.id,
            'qr_hash': qrData['qr_hash'] ?? '',
            'pickup_code': qrData['pickup_code'] ?? '',
          })
        : jsonEncode({'order_id': order.id});

    final pickupCode = qrData?['pickup_code'] as String? ??
        (order.pickupCode.isNotEmpty ? order.pickupCode : '------');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.show_qr_at_pickup,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            Text(
              order.merchantName,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: qrContent,
              size: 220,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(l10n.pickup_code_label,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    pickupCode,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      color: textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              order.orderNumber,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard(AppLocalizations l10n, BuildContext context) {
    return _card(
      title: l10n.help_support,
      icon: Icons.help_outline,
      children: [
        Text(
          l10n.order_help_desc,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/chat'),
            icon: const Icon(Icons.chat_outlined, size: 18),
            label: Text(l10n.chat),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryGreen,
              side: BorderSide(color: primaryGreen.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
