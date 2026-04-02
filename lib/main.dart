import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:provider/provider.dart';

import 'package:anti_food_waste_app/firebase_options.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/core/providers/favorites_provider.dart';
import 'package:anti_food_waste_app/core/providers/locale_provider.dart';
import 'package:anti_food_waste_app/core/navigation/app_router.dart';
import 'package:anti_food_waste_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:anti_food_waste_app/features/notifications/presentation/cubits/notifications_cubit.dart';
import 'package:anti_food_waste_app/features/notifications/data/repositories/notifications_repository_impl.dart';

import 'package:anti_food_waste_app/shared/widgets/not_found_screen.dart';

// Note: run `flutter gen-l10n` once to generate the required translation files.
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fix: switch Google Maps from SurfaceView to TextureView to stop
  //      "updateAcquireFence: Did not find frame" spam on Android.
  final mapsImpl = GoogleMapsFlutterPlatform.instance;
  if (mapsImpl is GoogleMapsFlutterAndroid) {
    mapsImpl.useAndroidViewSurface = true;
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => NotificationsCubit(NotificationsRepositoryImpl())..fetchNotifications()),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(
            create: (_) {
              final provider = FavoritesProvider();
              provider.refreshFavoriteIds();
              return provider;
            },
          ),
        ],
        child: const TawfirApp(),
      ),
    ),
  );
}

class TawfirApp extends StatelessWidget {
  const TawfirApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Tawfir',
      debugShowCheckedModeBanner: false,

      // ── Theme ────────────────────────────────────────────────────────────────
      theme: AppTheme.getTheme(localeProvider.locale),

      // ── Localisation ─────────────────────────────────────────────────────────
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Navigation ───────────────────────────────────────────────────────────
      //
      // Entry point: SplashScreen (3 s) → OnboardingScreen → RoleSelectorScreen
      // From the role selector the user enters one of three modules:
      //   • /consumer  – Consumer module  (MainScreen)
      //   • /merchant  – Merchant module  (MerchantMainScreen)
      //   • /charity   – Charity module   (CharityMainScreen)
      //
      // See lib/core/navigation/app_router.dart for the full route table.
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const NotFoundScreen(),
      ),
    );
  }
}

