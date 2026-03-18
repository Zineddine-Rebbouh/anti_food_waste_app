import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_order.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_order_verification_screen.dart';

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

    // If a preloaded order is passed (e.g., from Scan button in order card),
    // jump directly to verification after a short delay
    if (widget.preloadedOrder != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _simulateScan(widget.preloadedOrder!);
      });
    }
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
          _errorMsg = 'Invalid QR code format';
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
          _errorMsg = 'Order not found or already completed';
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
        _errorMsg = 'Cannot read QR code';
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

  Future<void> _simulateScan(MerchantOrder order) async {
    setState(() {
      _isValidating = true;
      _errorMsg = null;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isValidating = false);
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MerchantCubit>(),
      child: MerchantOrderVerificationScreen(order: order),
        ),
      ),
    );
  }

  Future<void> _verifyManual(String input) async {
    final code = input.trim().toUpperCase();
    if (code.length < 4) return;

    setState(() {
      _isValidating = true;
      _errorMsg = null;
    });
    try {
      await context.read<MerchantCubit>().fulfillByPickupCodeAsync(code);
      if (!mounted) return;
      setState(() => _isValidating = false);
      Navigator.pop(context); // order fulfilled — return to orders list.
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isValidating = false;
        _errorMsg = 'Invalid or already used pickup code';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.preloadedOrder != null) {
      // Show loading while jumping to verification screen
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(
                'Loading order #${widget.preloadedOrder!.orderNumber}...',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Real camera feed via mobile_scanner
          MobileScanner(
            controller: _controller,
            onDetect: _onQrDetected,
          ),

          // Subtle dark overlay to improve frame readability
          Container(
            color: Colors.black26,
          ),

          // UI Overlay
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Scan QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _torchOn
                              ? Icons.flash_off_outlined
                              : Icons.flash_on_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          _controller.toggleTorch();
                          setState(() => _torchOn = !_torchOn);
                        },
                      ),
                    ],
                  ),
                ),

                // Instructions
                const Text(
                  'Position QR code in the frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                // Scanning frame
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Frame
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CustomPaint(
                          painter: _FramePainter(),
                        ),
                      ),
                      // Laser line
                      if (!_isValidating)
                        AnimatedBuilder(
                          animation: _laserAnim,
                          builder: (_, __) {
                            return Positioned(
                              top: 120 * _laserAnim.value,
                              child: Container(
                                width: 220,
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFF2D8659),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      // Validating
                      if (_isValidating) ...[
                        Container(
                          width: 240,
                          height: 240,
                          color: Colors.black54,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                              SizedBox(height: 12),
                              Text(
                                'Validating...',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(),

                // Error banner
                if (_errorMsg != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_outlined,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMsg!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                const SizedBox(height: 12),

                // Manual entry (pickup code fallback)
                GestureDetector(
                  onTap: () => setState(
                      () => _showManualEntry = !_showManualEntry),
                  child: const Text(
                    "Can't scan? Enter pickup code manually",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _showManualEntry ? _buildManualEntry() : null,
    );
  }

  Widget _buildManualEntry() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter Pickup Code',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _manualCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'e.g. AB12CD',
              prefixText: '',
              filled: true,
              fillColor: const Color(0xFFF3F3F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFF2D8659), width: 2),
              ),
              errorText: _errorMsg,
            ),
            onSubmitted: _verifyManual,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isValidating
                  ? null
                  : () => _verifyManual(_manualCtrl.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D8659),
              ),
              child: _isValidating
                  ? const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                  : const Text('Verify Order',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Frame Painter ──────────────────────────────────────────────────────────────

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cornerLen = 24.0;
    const r = 6.0;

    // Top-left
    canvas.drawLine(const Offset(0, cornerLen), const Offset(0, r), paint);
    canvas.drawArc(const Rect.fromLTWH(0, 0, r * 2, r * 2), 3.14, 1.57, false, paint);
    canvas.drawLine(Offset(r, 0), Offset(cornerLen, 0), paint);

    // Top-right
    canvas.drawLine(
        Offset(size.width - cornerLen, 0), Offset(size.width - r, 0), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2), -1.57,
        1.57, false, paint);
    canvas.drawLine(Offset(size.width, r),
        Offset(size.width, cornerLen), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height - cornerLen),
        Offset(0, size.height - r), paint);
    canvas.drawArc(Rect.fromLTWH(0, size.height - r * 2, r * 2, r * 2), 3.14,
        -1.57, false, paint);
    canvas.drawLine(Offset(r, size.height),
        Offset(cornerLen, size.height), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - cornerLen, size.height),
        Offset(size.width - r, size.height), paint);
    canvas.drawArc(
        Rect.fromLTWH(
            size.width - r * 2, size.height - r * 2, r * 2, r * 2),
        0,
        1.57,
        false,
        paint);
    canvas.drawLine(Offset(size.width, size.height - r),
        Offset(size.width, size.height - cornerLen), paint);
  }

  @override
  bool shouldRepaint(_FramePainter oldDelegate) => false;
}
