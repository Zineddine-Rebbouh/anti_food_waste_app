import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/shared/widgets/social_auth_button.dart';
import 'package:anti_food_waste_app/shared/widgets/language_switcher.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.secondary,
              AppTheme.background,
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Language Switcher
                const Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: LanguageSwitcher(),
                ),

                const Spacer(),

                // Header
                Column(
                  children: [
                    // Logo
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🍃',
                          style: TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.welcome,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: AppTheme.fontWeightMedium,
                        color: AppTheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.welcomeSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: AppTheme.baseFontSize,
                        color: AppTheme.mutedForeground,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Auth Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SocialAuthButton(
                      type: SocialAuthType.google,
                      text: l10n.continueWithGoogle,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 16),
                    SocialAuthButton(
                      type: SocialAuthType.facebook,
                      text: l10n.continueWithFacebook,
                      onPressed: () {},
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              l10n.orText,
                              style: const TextStyle(
                                color: AppTheme.mutedForeground,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    SocialAuthButton(
                      type: SocialAuthType.email,
                      text: l10n.continueWithEmail,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.termsText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
