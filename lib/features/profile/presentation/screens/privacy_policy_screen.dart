import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:animate_do/animate_do.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color forestGreen = AppTheme.primary;
  static const Color accentBeige = Colors.white;
  static const Color textNavy = Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: accentBeige,
      body: Column(
        children: [
          _buildHeader(context, l10n),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      'Last updated: January 2025'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: forestGreen.withOpacity(0.3),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: Column(
                      children: [
                        _LegalSection(
                          title: '1. Information We Collect',
                          body: 'When you use Tawfir, we collect certain information to provide and improve our services. Personal data such as your full name, email address, and phone number is collected when you create an account. Payment information is handled exclusively by our secure payment processors and is never stored on our own servers.\n\nWe also collect location data (with your explicit permission) to show you nearby food deals and improve the relevance of our recommendations.',
                        ),
                        _LegalSection(
                          title: '2. How We Use Your Data',
                          body: 'The data we collect is used primarily to match you with relevant food deals and merchants in your area, to personalize your in-app experience, and to facilitate transactions between consumers and merchants.\n\nWe use your contact information to send you notifications about new deals, pickup reminders, and important app updates, subject to your notification preferences.',
                        ),
                        _LegalSection(
                          title: '3. Data Sharing',
                          body: 'Tawfir does not sell, rent, or trade your personal information to any third parties for their own marketing or commercial purposes. We treat your data with the highest level of confidentiality and only share it under limited circumstances like reservation coordination with merchants.',
                        ),
                        _LegalSection(
                          title: '4. Data Security',
                          body: 'We take the security of your personal data seriously and implement industry-standard technical and organizational measures to protect it. All data transmitted between your device and our servers is encrypted using TLS/SSL protocols.',
                        ),
                        _LegalSection(
                          title: '5. Your Rights',
                          body: 'Under applicable data protection laws, you have several rights regarding your personal data. You have the right to access the personal information we hold about you, to request corrections, and to request the permanent deletion of your account.',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'Questions? Email us at privacy@tawfir.dz',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: forestGreen.withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: forestGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 24, 32),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.privacy_policy,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  final String title;
  final String body;
  final bool isLast;

  const _LegalSection({
    required this.title,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    const forestGreen = AppTheme.primary;
    const textNavy = Color(0xFF1A1A2E);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: forestGreen.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: forestGreen.withOpacity(0.5),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              color: textNavy.withOpacity(0.7),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
