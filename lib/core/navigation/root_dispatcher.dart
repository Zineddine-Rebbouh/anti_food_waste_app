import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:anti_food_waste_app/features/auth/presentation/cubits/auth_state.dart';
import 'package:anti_food_waste_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:anti_food_waste_app/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:anti_food_waste_app/features/verification/presentation/screens/merchant_pending.dart';
import 'package:anti_food_waste_app/core/navigation/app_router.dart';
import 'package:anti_food_waste_app/core/services/preferences_service.dart';

import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_main_screen.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_main_screen.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_cubit.dart';
import 'package:anti_food_waste_app/features/charity/domain/repositories/charity_repository.dart';
import 'package:anti_food_waste_app/features/charity/data/sources/charity_remote_source.dart';
import 'package:anti_food_waste_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:anti_food_waste_app/features/home/presentation/screens/main_screen.dart';

import 'package:anti_food_waste_app/shared/widgets/tawfir_loading_indicator.dart';

class RootDispatcher extends StatelessWidget {
  const RootDispatcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: TawfirLoadingIndicator(message: 'Initializing...'),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          // If authenticated but not approved (merchants/charities)
          if (!state.isApproved &&
              (state.userType == 'merchant' || state.userType == 'charity')) {
            return const MerchantPendingScreen();
          }

          // Navigate to respective main screens
          return switch (state.userType) {
            'merchant' => BlocProvider(
                create: (ctx) => MerchantCubit()..load(),
                child: const MerchantMainScreen(),
              ),
            'charity' => MultiBlocProvider(
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
            _ => const MainScreen(),
          };
        }

        // Unauthenticated or Error: determine if we show onboarding or welcome
        if (!PreferencesService.hasSeenOnboarding()) {
          return const OnboardingScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}
