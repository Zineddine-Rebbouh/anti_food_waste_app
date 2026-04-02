import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:anti_food_waste_app/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:anti_food_waste_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:anti_food_waste_app/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:anti_food_waste_app/features/role_selector/presentation/screens/role_selector_screen.dart';
import 'package:anti_food_waste_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:anti_food_waste_app/features/auth/presentation/screens/email_verification.dart';
import 'package:anti_food_waste_app/features/auth/presentation/screens/login_screen.dart';
import 'package:anti_food_waste_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:anti_food_waste_app/features/verification/presentation/screens/merchant_pending.dart';
import 'package:anti_food_waste_app/features/verification/presentation/screens/charity_document_comfirmation.dart';
import 'package:anti_food_waste_app/features/home/presentation/screens/main_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_main_screen.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_main_screen.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_cubit.dart';
import 'package:anti_food_waste_app/features/charity/domain/repositories/charity_repository.dart';
import 'package:anti_food_waste_app/features/charity/data/sources/charity_remote_source.dart';
import 'package:anti_food_waste_app/shared/widgets/not_found_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route name constants – single source of truth for the whole app.
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AppRoutes {
  // Entry flow
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String roleSelector = '/role-selector';

  // Auth flow
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String emailVerification = '/email-verification';
  static const String forgotPassword = '/forgot-password';
  static const String merchantPending = '/merchant-pending';
  static const String charityDocuments = '/charity-documents';

  // Module roots
  static const String consumer = '/consumer';
  static const String merchant = '/merchant';
  static const String charity = '/charity';
}

// ─────────────────────────────────────────────────────────────────────────────
// Central router – wired into MaterialApp.onGenerateRoute.
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Entry flow ──────────────────────────────────────────────────────────
      case AppRoutes.splash:
        return _fade(const SplashScreen());

      case AppRoutes.onboarding:
        return _fade(const OnboardingScreen());

      case AppRoutes.welcome:
        return _fade(const WelcomeScreen());

      case AppRoutes.roleSelector:
        return _fade(const RoleSelectorScreen());

      // ── Auth screens ────────────────────────────────────────────────────────
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case AppRoutes.emailVerification:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(email: email));

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
            builder: (_) => const ForgotPasswordScreen());

      case AppRoutes.merchantPending:
        return MaterialPageRoute(builder: (_) => const MerchantPendingScreen());

      case AppRoutes.charityDocuments:
        return MaterialPageRoute(
            builder: (_) => const CharityDocumentsScreen());

      // ── Module roots ────────────────────────────────────────────────────────
      case AppRoutes.consumer:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case AppRoutes.merchant:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (ctx) => MerchantCubit()..load(),
            child: const MerchantMainScreen(),
          ),
        );

      case AppRoutes.charity:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (ctx) => CharityCubit(
              repository: CharityRepository(remoteSource: CharityRemoteSource()),
            )..fetchCharityData(),
            child: const CharityMainScreen(),
          ),
        );

      // ── Fallback ────────────────────────────────────────────────────────────
      default:
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());
    }
  }

  /// Navigates to the role selector and removes every previous route from the
  /// stack so pressing back cannot return to the previous module.
  static void exitToRoleSelector(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.roleSelector,
      (_) => false,
    );
  }

  // Fade transition helper used for top-level screen changes.
  static PageRouteBuilder<T> _fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
