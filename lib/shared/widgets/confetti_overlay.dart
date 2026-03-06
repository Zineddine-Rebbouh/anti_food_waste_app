import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final Widget? child;
  const ConfettiOverlay({super.key, this.child});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiPiece> _pieces = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    final colors = [
      const Color(0xFF2D8659),
      Colors.red,
      Colors.amber,
      Colors.green,
      Colors.orange
    ];

    for (int i = 0; i < 50; i++) {
      _pieces.add(ConfettiPiece(
        x: _random.nextDouble(),
        color: colors[_random.nextInt(colors.length)],
        delay: _random.nextDouble() * 0.5,
        duration: 1.5 + _random.nextDouble(),
      ));
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildParticles(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: _pieces.map((piece) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress =
                  (_controller.value - piece.delay).clamp(0.0, 1.0);
              if (progress == 0) return const SizedBox.shrink();

              return Positioned(
                top: MediaQuery.of(context).size.height * progress - 20,
                left: MediaQuery.of(context).size.width * piece.x,
                child: Opacity(
                  opacity: 1.0 - progress,
                  child: Transform.rotate(
                    angle: progress * 2 * pi,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: piece.color, shape: BoxShape.circle),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return Stack(
        children: [
          widget.child!,
          _buildParticles(context),
        ],
      );
    }
    return _buildParticles(context);
  }
}

class ConfettiPiece {
  final double x;
  final Color color;
  final double delay;
  final double duration;

  ConfettiPiece(
      {required this.x,
      required this.color,
      required this.delay,
      required this.duration});
}
