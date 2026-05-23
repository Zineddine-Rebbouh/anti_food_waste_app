import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_order.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/shared/widgets/confetti_overlay.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MerchantOrderVerificationScreen extends StatefulWidget {
  final MerchantOrder order;
  final String? qrHash;

  const MerchantOrderVerificationScreen({
    super.key,
    required this.order,
    this.qrHash,
  });

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

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color accentBeige = Colors.white;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _checkScale = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
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
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isConfirming = true);
    try {
      if (widget.qrHash != null && widget.qrHash!.isNotEmpty) {
        if (widget.order.isDonation) {
          await context.read<MerchantCubit>().fulfillDonationAsync(widget.order.id, widget.qrHash!);
        } else {
          await context.read<MerchantCubit>().fulfillOrderAsync(widget.order.id, widget.qrHash!);
        }
      } else {
        context.read<MerchantCubit>().completedOrder(widget.order.id);
      }
      if (!mounted) return;
      setState(() {
        _isConfirming = false;
        _showCompleted = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isConfirming = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.handover_failed(e.toString())), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_showCompleted) {
      return _OrderCompletedScreen(
        order: widget.order,
        onDone: () => Navigator.of(context).popUntil((route) => route.isFirst),
      );
    }

    return Scaffold(
      backgroundColor: accentBeige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryGreen, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(l10n.verification.toUpperCase(), style: const TextStyle(color: primaryGreen, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildStatusHeader(l10n),
            const SizedBox(height: 24),
            _buildCustomerSection(l10n),
            const SizedBox(height: 24),
            _buildOrderSection(l10n),
            const SizedBox(height: 40),
            _buildConfirmButton(l10n),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        children: [
          ScaleTransition(
            scale: _checkScale,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: const Color(0xFF2D8659).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF2D8659), size: 36),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.qr_scanned_label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primaryGreen, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(l10n.order_number_label(widget.order.orderNumber), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildCustomerSection(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.grey.shade50)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.customer_label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: primaryGreen.withOpacity(0.05), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(widget.order.customerName.substring(0, 1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: primaryGreen)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.order.customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    Text(widget.order.maskedPhone, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
                  ],
                ),
              ),
              IconButton(onPressed: () => _call(widget.order.customerPhone), icon: const Icon(Icons.phone_rounded, color: primaryGreen, size: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSection(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.grey.shade50)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.order_details, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${widget.order.quantity}x ${widget.order.listingTitle}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              if (!widget.order.isDonation) Text('${widget.order.totalAmount.toInt()} DZD', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            ],
          ),
          if (widget.order.paymentMethod == PaymentMethod.cashOnPickup) ...[
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => setState(() => _cashReceived = !_cashReceived),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cashReceived ? const Color(0xFF2D8659).withOpacity(0.05) : accentBeige,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _cashReceived ? const Color(0xFF2D8659) : Colors.grey.shade100, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(_cashReceived ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: _cashReceived ? const Color(0xFF2D8659) : Colors.grey.shade300),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l10n.cash_received_msg(widget.order.totalAmount.toInt().toString()),
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _cashReceived ? const Color(0xFF2D8659) : Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _canConfirm && !_isConfirming ? _confirmHandover : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade100,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isConfirming
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Text(l10n.confirm_handover_action.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }

  void _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _OrderCompletedScreen extends StatelessWidget {
  final MerchantOrder order;
  final VoidCallback onDone;

  const _OrderCompletedScreen({required this.order, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ConfettiOverlay(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(color: const Color(0xFF2D8659).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2D8659), size: 60),
                ),
                const SizedBox(height: 32),
                Text(l10n.success, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2D8659), letterSpacing: -1)),
                const SizedBox(height: 8),
                Text(l10n.handover_complete_msg, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
                const SizedBox(height: 48),
                _buildImpactCard(context, l10n),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D8659),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(l10n.done.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImpactCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        children: [
          Text(l10n.your_impact_label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF2D8659), letterSpacing: 2)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ImpactStat(value: "0.5kg", label: l10n.food_saved_label.toUpperCase()),
              Container(width: 1, height: 40, color: Colors.grey.shade200),
              _ImpactStat(value: "2kg", label: l10n.co2_avoided.toUpperCase()),
            ],
          ),
        ],
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
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2D8659))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 0.5)),
      ],
    );
  }
}



