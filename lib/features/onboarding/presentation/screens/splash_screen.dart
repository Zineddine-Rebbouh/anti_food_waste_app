import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/navigation/app_router.dart';
import 'package:anti_food_waste_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:anti_food_waste_app/features/auth/presentation/cubits/auth_state.dart';
import 'package:anti_food_waste_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:anti_food_waste_app/features/verification/presentation/screens/merchant_pending.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _rotateController;
  late AnimationController _contentController;
  late AnimationController _dotController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotate;
  late Animation<double> _contentOpacity;
  late Animation<double> _contentTranslate;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _dotController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _logoRotate = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    _contentOpacity = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    _contentTranslate = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _contentController,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    _logoController.forward();
    _contentController.forward();

    // Check for a stored session while the splash animation plays.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().checkAuthStatus();
    });

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      final state = context.read<AuthCubit>().state;
      if (state is AuthAuthenticated) {
        // Pending merchant/charity should not enter their module yet.
        if (!state.isApproved &&
            (state.userType == 'merchant' || state.userType == 'charity')) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MerchantPendingScreen()),
            (_) => false,
          );
          return;
        }
        final route = switch (state.userType) {
          'merchant' => AppRoutes.merchant,
          'charity' => AppRoutes.charity,
          _ => AppRoutes.consumer,
        };
        Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _rotateController.dispose();
    _contentController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D8659),
              Color(0xFF1e5a3a),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles (simplified)
            Positioned(
              top: -50,
              left: -50,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  ScaleTransition(
                    scale: _logoScale,
                    child: RotationTransition(
                      turns: _logoRotate,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 8,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.eco,
                              size: 70,
                              color: Colors.white,
                            ),
                            RotationTransition(
                              turns: _rotateController,
                              child: Container(
                                width: 140,
                                height: 140,
                                alignment: Alignment.topCenter,
                                child: const Icon(
                                  Icons.sync,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Brand Name and Tagline
                  AnimatedBuilder(
                    animation: _contentController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _contentOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _contentTranslate.value),
                          child: Column(
                            children: [
                              const Text(
                                'SaveFood DZ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  l10n.tagline,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Loading dots
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _dotController,
                      builder: (context, child) {
                        final delay = index * 0.2;
                        final val =
                            (_dotController.value - delay).clamp(0.0, 1.0);
                        final opacity = 0.5 + (0.5 * val);

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(opacity),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),

            // Algerian color accents
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 4,
              child: Row(
                children: [
                  Expanded(child: Container(color: const Color(0xFF2D8659))),
                  Expanded(child: Container(color: Colors.white)),
                  Expanded(child: Container(color: const Color(0xFFD32F2F))),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 4,
              child: Row(
                children: [
                  Expanded(child: Container(color: const Color(0xFF2D8659))),
                  Expanded(child: Container(color: Colors.white)),
                  Expanded(child: Container(color: const Color(0xFFD32F2F))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
