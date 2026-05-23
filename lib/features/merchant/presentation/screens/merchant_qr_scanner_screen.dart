import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_order.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_order_verification_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MerchantQrScannerScreen extends StatefulWidget {
  final MerchantOrder? preloadedOrder;

  const MerchantQrScannerScreen({super.key, this.preloadedOrder});

  @override
  State<MerchantQrScannerScreen> createState() =>
      _MerchantQrScannerScreenState();
}

class _MerchantQrScannerScreenState extends State<MerchantQrScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _laserCtrl;
  late final Animation<double> _laserAnim;

  bool _isValidating = false;
  bool _isScanned = false;
  bool _torchOn = false;
  bool _showManualEntry = false;
  final _manualCtrl = TextEditingController();
  String? _errorMsg;
  late final MobileScannerController _controller;

  static const Color primaryGreen = Color(0xFF2D8659);

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _laserCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _laserAnim = CurvedAnimation(parent: _laserCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _laserCtrl.dispose();
    _manualCtrl.dispose();
    super.dispose();
  }

  Future<void> _onQrDetected(BarcodeCapture capture) async {
    if (_isScanned || _isValidating) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isScanned = true;
      _isValidating = true;
      _errorMsg = null;
    });
    _controller.stop();

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final orderId = data['order_id'] as String?;
      final qrHash = data['qr_hash'] as String?;

      if (orderId == null || qrHash == null) {
        setState(() {
          _isScanned = false;
          _isValidating = false;
          _errorMsg = l10n.invalid_qr_format;
        });
        _controller.start();
        return;
      }

      final cubitState = context.read<MerchantCubit>().state;
      if (cubitState is! MerchantLoaded) {
        setState(() { _isScanned = false; _isValidating = false; });
        _controller.start();
        return;
      }

      final match = cubitState.pendingOrders
          .where((o) => o.id == orderId)
          .firstOrNull;

      if (match == null) {
        setState(() {
          _isScanned = false;
          _isValidating = false;
          _errorMsg = l10n.order_not_found_completed;
        });
        _controller.start();
        return;
      }

      if (widget.preloadedOrder != null && match.id != widget.preloadedOrder!.id) {
        setState(() {
          _isScanned = false;
          _isValidating = false;
          _errorMsg = l10n.qr_mismatch;
        });
        _controller.start();
        return;
      }

      setState(() => _isValidating = false);
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<MerchantCubit>(),
            child: MerchantOrderVerificationScreen(
              order: match,
              qrHash: qrHash,
            ),
          ),
        ),
      );
    } on FormatException {
      setState(() {
        _isScanned = false;
        _isValidating = false;
        _errorMsg = l10n.cannot_read_qr;
      });
      _controller.start();
    } catch (e) {
      setState(() {
        _isScanned = false;
        _isValidating = false;
        _errorMsg = e.toString();
      });
      _controller.start();
    }
  }

  Future<void> _verifyManual(String input) async {
    final code = input.trim().toUpperCase();
    if (code.length < 4) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isValidating = true;
      _errorMsg = null;
    });
    try {
      await context.read<MerchantCubit>().fulfillByPickupCodeAsync(code);
      if (!mounted) return;
      setState(() => _isValidating = false);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isValidating = false;
        _errorMsg = l10n.invalid_pickup_code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onQrDetected,
          ),
          // Darker overlay outside frame
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.srcOut),
            child: Stack(
              children: [
                Container(decoration: const BoxDecoration(color: Colors.black, backgroundBlendMode: BlendMode.dstOut)),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleIconButton(
                        icon: Icons.close_rounded,
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        l10n.scan_qr.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                      _CircleIconButton(
                        icon: _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        onPressed: () {
                          _controller.toggleTorch();
                          setState(() => _torchOn = !_torchOn);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.align_qr_frame,
                  style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      if (!_isValidating)
                        AnimatedBuilder(
                          animation: _laserAnim,
                          builder: (_, __) {
                            return Positioned(
                              top: 20 + 220 * _laserAnim.value,
                              child: Container(
                                width: 220,
                                height: 3,
                                decoration: BoxDecoration(
                                  boxShadow: [BoxShadow(color: const Color(0xFF2D8659).withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
                                  gradient: const LinearGradient(colors: [Colors.transparent, Color(0xFF2D8659), Colors.transparent]),
                                ),
                              ),
                            );
                          },
                        ),
                      if (_isValidating)
                        const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    ],
                  ),
                ),
                const Spacer(),
                if (_errorMsg != null)
                  _ErrorPill(message: _errorMsg!),
                const SizedBox(height: 32),
                _EditorialAction(
                  label: l10n.cant_scan_enter_code,
                  onTap: () => setState(() => _showManualEntry = true),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _showManualEntry ? _buildManualEntry(l10n) : null,
    );
  }

  Widget _buildManualEntry(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 32),
          Text(
            l10n.enter_pickup_code,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.ask_customer_code,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _manualCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 4),
            decoration: InputDecoration(
              hintText: l10n.code_label.toUpperCase(),
              hintStyle: TextStyle(color: Colors.grey.shade200, letterSpacing: 4),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            ),
            onSubmitted: _verifyManual,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _isValidating ? null : () => _verifyManual(_manualCtrl.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isValidating
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Text(l10n.verify_order_action.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _CircleIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, color: Colors.white, size: 22), onPressed: onPressed),
    );
  }
}

class _ErrorPill extends StatelessWidget {
  final String message;
  const _ErrorPill({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.9), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _EditorialAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _EditorialAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, decoration: TextDecoration.underline),
      ),
    );
  }
}



