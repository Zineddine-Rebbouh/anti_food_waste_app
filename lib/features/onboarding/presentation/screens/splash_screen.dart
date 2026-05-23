import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/navigation/app_router.dart';
import 'package:anti_food_waste_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:anti_food_waste_app/features/auth/presentation/cubits/auth_state.dart';
import 'package:anti_food_waste_app/features/verification/presentation/screens/merchant_pending.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/core/services/preferences_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();

    // Check for a stored session while the splash animation plays.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().checkAuthStatus();
    });

    // 3.5 seconds for animation display, then start fade out transition
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _isTransitioning = true;
        });
      }
    });

    // 4 seconds total duration before navigating
    Timer(const Duration(seconds: 4), () async {
      if (!mounted) return;
      
      final state = context.read<AuthCubit>().state;
      
      if (state is AuthAuthenticated) {
        if (!state.isApproved &&
            (state.userType == 'merchant' || state.userType == 'charity')) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const MerchantPendingScreen(),
              transitionsBuilder: (_, animation, __, child) => 
                FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 500),
            ),
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
        // If not authenticated, check if they've seen onboarding
        if (!PreferencesService.hasSeenOnboarding()) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.onboarding, (_) => false);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fallback if app_localizations somehow misses
    final l10n = AppLocalizations.of(context);
    const primaryColor = AppTheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Clean, minimalist background (adapts to light/dark)
    final backgroundColor = isDark ? const Color(0xFF111412) : const Color(0xFFFDFDFD);
    final gradientCenter = isDark ? const Color(0xFF1E2822) : const Color(0xFFEDF5F0);

    return Scaffold(
      body: AnimatedOpacity(
        opacity: _isTransitioning ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
            // A very subtle radial glow behind the logo
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8,
              colors: [
                gradientCenter,
                backgroundColor,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo - Pure, clean, no background box
              Hero(
                tag: 'app_logo',
                child: Image.asset(
                  'assets/images/logo_transparent.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.4, 0.4),
                end: const Offset(1.0, 1.0),
                duration: 1000.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 800.ms)
              .then() // After entrance, add a very subtle continuous float
              .moveY(
                begin: 0,
                end: -8,
                duration: 2.seconds,
                curve: Curves.easeInOutSine,
              )
              .then()
              .moveY(
                begin: -8,
                end: 0,
                duration: 2.seconds,
                curve: Curves.easeInOutSine,
              ),

              const SizedBox(height: 36),

              // Brand Name
              Text(
                'Tawfir',
                style: GoogleFonts.montserrat(
                  color: isDark ? Colors.white : primaryColor,
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              )
              .animate()
              .slideY(
                begin: 0.5,
                end: 0,
                delay: 400.ms,
                duration: 800.ms,
                curve: Curves.easeOutQuart,
              )
              .fadeIn(delay: 400.ms, duration: 800.ms),

              const SizedBox(height: 8),

              // Tagline
              Text(
                l10n?.tagline ?? "Smart Solutions for Zero Waste",
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              )
              .animate()
              .slideY(
                begin: 0.5,
                end: 0,
                delay: 600.ms,
                duration: 800.ms,
                curve: Curves.easeOutQuart,
              )
              .fadeIn(delay: 600.ms, duration: 800.ms),

              const SizedBox(height: 60),

              // Simple, elegant loading dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(isDark ? 0.8 : 0.6),
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate(
                    onPlay: (c) => c.repeat(),
                    delay: (index * 150).ms,
                  )
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.5, 1.5),
                    duration: 600.ms,
                    curve: Curves.easeInOut,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.5, 1.5),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.easeInOut,
                  );
                }),
              )
              .animate()
              .fadeIn(delay: 800.ms, duration: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
