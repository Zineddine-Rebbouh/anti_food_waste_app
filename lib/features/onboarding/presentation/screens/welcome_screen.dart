import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/core/navigation/app_router.dart';
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
              Colors.white,
              Color(0xFFFFF8E1),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Algerian colors accent
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 4,
              child: Row(
                children: [
                  Expanded(child: Container(color: AppTheme.primary)),
                  Expanded(child: Container(color: Colors.white)),
                  Expanded(child: Container(color: AppTheme.accent)),
                ],
              ),
            ),
            
            SafeArea(
              child: Column(
                children: [
                  // Language Switcher
                  const Padding(
                    padding: EdgeInsets.only(top: 16, right: 16),
                    child: Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: LanguageSwitcher(),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Header
                          Text(
                            l10n.welcome,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.welcomeSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF757575),
                              height: 1.5,
                            ),
                          ),
                          
                          const SizedBox(height: 48),
                          
                          // Logo Illustration
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 90,
                                height: 90,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Auth Buttons
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SocialAuthButton(
                          type: SocialAuthType.google,
                          text: l10n.continueWithGoogle,
                          onPressed: () {
                            // Link social auth logic if needed
                          },
                        ),
                        const SizedBox(height: 16),
                        SocialAuthButton(
                          type: SocialAuthType.facebook,
                          text: l10n.continueWithFacebook,
                          onPressed: () {
                            // Link social auth logic if needed
                          },
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  l10n.orText,
                                  style: const TextStyle(
                                    color: Color(0xFF9E9E9E),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                            ],
                          ),
                        ),
                        
                        SocialAuthButton(
                          type: SocialAuthType.email,
                          text: l10n.continueWithEmail,
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRoutes.signUp);
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          l10n.termsText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Already have an account? Log in
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.login),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Color(0xFF757575),
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(text: l10n.already_have_account + " "),
                                  TextSpan(
                                    text: l10n.login,
                                    style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
