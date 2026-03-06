import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_order.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/shared/widgets/confetti_overlay.dart';

class MerchantOrderVerificationScreen extends StatefulWidget {
  final MerchantOrder order;

  const MerchantOrderVerificationScreen({super.key, required this.order});

  @override
  State<MerchantOrderVerificationScreen> createState() =>
      _MerchantOrderVerificationScreenState();
}

class _MerchantOrderVerificationScreenState
    extends State<MerchantOrderVerificationScreen>
    with SingleTickerProviderStateMixin {
  bool _cashReceived = false;
  bool _isConfirming = false;
  bool _showCompleted = false;

  late final AnimationController _checkCtrl;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _checkScale =
        CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  bool get _canConfirm {
    if (widget.order.paymentMethod == PaymentMethod.cashOnPickup) {
      return _cashReceived;
    }
    return true;
  }

  Future<void> _confirmHandover() async {
    setState(() => _isConfirming = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    context.read<MerchantCubit>().completedOrder(widget.order.id);
    setState(() {
      _isConfirming = false;
      _showCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showCompleted) {
      return _OrderCompletedScreen(
        order: widget.order,
        onDone: () => Navigator.of(context)
            .popUntil((route) => route.isFirst || route.settings.name != null),
        onNextOrder: () => Navigator.pop(context),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verify Order',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // QR scanned header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _checkScale,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D8659).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.qr_code_scanner,
                          color: Color(0xFF2D8659), size: 36),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'QR Code Scanned!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D8659),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${widget.order.orderNumber}',
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Customer info
            Container(
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
                  const Text(
                    'Customer',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D8659).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _initials(widget.order.customerName),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D8659),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.order.customerName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _callCustomer(
                                  widget.order.customerPhone),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone,
                                      size: 12,
                                      color: Color(0xFF6B7280)),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.order.maskedPhone,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _callCustomer(
                            widget.order.customerPhone),
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Call',
                            style: TextStyle(fontSize: 13)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2D8659),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Order details
            Container(
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
                  const Text(
                    'Order Details',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.order.quantity}x ${widget.order.listingTitle}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      if (!widget.order.isDonation)
                        Text(
                          '${widget.order.totalAmount.toStringAsFixed(0)} DZD',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF374151),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Payment method
                  if (widget.order.isDonation)
                    _PaymentBadge(
                      icon: Icons.volunteer_activism_outlined,
                      label: 'Donation (Free)',
                      color: const Color(0xFF2D8659),
                      bgColor: const Color(0xFFD1FAE5),
                    )
                  else if (widget.order.paymentMethod ==
                      PaymentMethod.paidOnline)
                    _PaymentBadge(
                      icon: Icons.check_circle_outline,
                      label:
                          'Paid Online (${widget.order.totalAmount.toStringAsFixed(0)} DZD)',
                      color: const Color(0xFF10B981),
                      bgColor: const Color(0xFFD1FAE5),
                    )
                  else ...[
                    _PaymentBadge(
                      icon: Icons.payments_outlined,
                      label:
                          'Cash on Pickup (${widget.order.totalAmount.toStringAsFixed(0)} DZD)',
                      color: const Color(0xFFF97316),
                      bgColor: const Color(0xFFFFEDD5),
                    ),
                    const SizedBox(height: 14),
                    // Cash confirmation checkbox
                    GestureDetector(
                      onTap: () => setState(
                          () => _cashReceived = !_cashReceived),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _cashReceived
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _cashReceived
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF97316),
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _cashReceived
                                    ? const Color(0xFF10B981)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _cashReceived
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFD1D5DB),
                                  width: 2,
                                ),
                              ),
                              child: _cashReceived
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'I received ${widget.order.totalAmount.toStringAsFixed(0)} DZD cash',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: _cashReceived
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (!_cashReceived)
                      const Text(
                        'Please confirm you received cash before completing the order',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF)),
                      ),
                  ],
                ],
              ),
            ),

            // Special instructions
            if (widget.order.specialInstructions != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: Color(0xFFD97706)),
                        SizedBox(width: 6),
                        Text(
                          'Special Instructions',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.order.specialInstructions!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed:
                      _canConfirm && !_isConfirming ? _confirmHandover : null,
                  icon: _isConfirming
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check, size: 20),
                  label: const Text(
                    'Confirm Handover',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D8659),
                    minimumSize: const Size(double.infinity, 56),
                    disabledBackgroundColor: const Color(0xFFD1D5DB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280)),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  void _callCustomer(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

// ── Payment Badge ─────────────────────────────────────────────────────────────

class _PaymentBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _PaymentBadge(
      {required this.icon,
      required this.label,
      required this.color,
      required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order Completed Screen ────────────────────────────────────────────────────

class _OrderCompletedScreen extends StatefulWidget {
  final MerchantOrder order;
  final VoidCallback onDone;
  final VoidCallback onNextOrder;

  const _OrderCompletedScreen(
      {required this.order,
      required this.onDone,
      required this.onNextOrder});

  @override
  State<_OrderCompletedScreen> createState() => _OrderCompletedScreenState();
}

class _OrderCompletedScreenState extends State<_OrderCompletedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDonation = widget.order.isDonation;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ConfettiOverlay(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Checkmark
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D8659).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDonation ? Icons.volunteer_activism : Icons.check_circle,
                      color: const Color(0xFF2D8659),
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  isDonation ? 'Donation Complete!' : 'Order Completed!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D8659),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isDonation
                      ? 'Thank you for reducing food waste!'
                      : 'Thank you for using SaveFood DZ',
                  style: const TextStyle(
                      fontSize: 15, color: Color(0xFF6B7280)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Earnings card
                if (!isDonation) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '💰 Your Earnings',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${widget.order.totalAmount.toStringAsFixed(2)} DZD',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your commission (88%)',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                            Text(
                              '${widget.order.netEarnings.toStringAsFixed(2)} DZD',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Platform fee (12%)',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF9CA3AF)),
                            ),
                            Text(
                              '${widget.order.platformFee.toStringAsFixed(2)} DZD',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                        const Divider(height: 12),
                        const Text(
                          'Paid out tomorrow via bank transfer',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Impact card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3)),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '🌍 Impact',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ImpactStat(value: '0.5 kg', label: 'Food Saved'),
                          _ImpactStat(value: '2 kg', label: 'CO₂ Avoided'),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Actions
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: widget.onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D8659),
                    ),
                    child: const Text('Done',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: widget.onNextOrder,
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('Scan Next Order'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2D8659),
                      side: const BorderSide(color: Color(0xFF2D8659)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  final String value;
  final String label;

  const _ImpactStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF10B981),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}
