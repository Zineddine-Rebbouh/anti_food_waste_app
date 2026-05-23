import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import 'package:anti_food_waste_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:anti_food_waste_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:anti_food_waste_app/features/chat/services/chat_service.dart';
import 'package:anti_food_waste_app/features/orders/presentation/screens/route_plan_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/change_password_screen.dart';
import 'package:anti_food_waste_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:anti_food_waste_app/features/help/presentation/screens/help_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/impact_dashboard_screen.dart';
import 'package:anti_food_waste_app/shared/widgets/not_found_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route name constants – single source of truth for the whole app.
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AppRoutes {
  // Entry flow
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

  // Chat
  static const String chat = '/chat';

  // Route Planning
  static const String routePlan = '/route-plan';

  // Profile & Settings
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String notifications = '/notifications';
  static const String help = '/help';
  static const String impactDashboard = '/impact-dashboard';
}

// ─────────────────────────────────────────────────────────────────────────────
// Central router – wired into MaterialApp.onGenerateRoute.
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Entry flow ──────────────────────────────────────────────────────────
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
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (ctx) => CharityCubit(
                  repository: CharityRepository(remoteSource: CharityRemoteSource()),
                )..fetchCharityData(),
              ),
              BlocProvider(
                create: (ctx) => ProfileCubit()..loadProfile(),
              ),
            ],
            child: const CharityMainScreen(),
          ),
        );

      // ── Chat ──────────────────────────────────────────────────────────────
      case AppRoutes.chat:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (ctx) => ChatCubit(ChatService()),
            child: const ChatScreen(),
          ),
        );

      // ── Route Planning ────────────────────────────────────────────────────
      case AppRoutes.routePlan:
        final orderIds = settings.arguments as List<String>? ?? [];
        return MaterialPageRoute(
          builder: (_) => RoutePlanScreen(orderIds: orderIds),
        );

      // ── Profile & Settings ────────────────────────────────────────────────
      case AppRoutes.editProfile:
        final user = settings.arguments as dynamic;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ProfileCubit()..loadProfile(),
            child: EditProfileScreen(user: user),
          ),
        );

      case AppRoutes.changePassword:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordScreen(),
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );

      case AppRoutes.help:
        return MaterialPageRoute(
          builder: (_) => const HelpScreen(),
        );
      
      case AppRoutes.impactDashboard:
        return MaterialPageRoute(
          builder: (_) => const ImpactDashboardScreen(),
        );

      // ── Fallback ────────────────────────────────────────────────────────
      default:
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());
    }
  }

  /// Navigates to the login screen and removes every previous route from the
  /// stack.
  static void exitToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
    );
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
