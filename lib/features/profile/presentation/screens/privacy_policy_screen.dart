import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppTheme.foreground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.privacy_policy,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.foreground,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last updated notice
            Text(
              'Last updated: January 2025',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: 20),

            // ── Section 1: Information We Collect ───────────────────────────
            const _LegalSection(
              title: '1. Information We Collect',
              body:
                  'When you use Tawfir, we collect certain information to provide and improve our services. '
                  'Personal data such as your full name, email address, and phone number is collected when you '
                  'create an account. Payment information is handled exclusively by our secure payment processors '
                  'and is never stored on our own servers.\n\n'
                  'We also collect location data (with your explicit permission) to show you nearby food deals '
                  'and improve the relevance of our recommendations. Technical data such as device identifiers, '
                  'IP addresses, app usage logs, and crash reports are collected automatically to maintain '
                  'service quality, performance, and security.\n\n'
                  'Usage data — including the pages you visit, features you interact with, and actions you take '
                  'within the app — is collected in anonymized form. This data helps us understand how the '
                  'service is being used and where improvements can be made.',
            ),

            // ── Section 2: How We Use Your Data ─────────────────────────────
            const _LegalSection(
              title: '2. How We Use Your Data',
              body:
                  'The data we collect is used primarily to match you with relevant food deals and merchants in '
                  'your area, to personalize your in-app experience, and to facilitate transactions between '
                  'consumers and merchants. We do not use your data for any purpose beyond what is described '
                  'in this Privacy Policy.\n\n'
                  'We use your contact information to send you notifications about new deals, pickup reminders, '
                  'and important app updates, subject to your notification preferences. You can adjust or '
                  'disable these communications at any time through the app\'s Settings screen. Marketing '
                  'communications are sent only with your explicit prior consent.\n\n'
                  'Aggregated and anonymized usage data is used internally to improve service quality, diagnose '
                  'technical issues, and develop new features. This data is stripped of all identifiers and '
                  'cannot be used to identify or re-identify individual users.',
            ),

            // ── Section 3: Data Sharing ──────────────────────────────────────
            const _LegalSection(
              title: '3. Data Sharing',
              body:
                  'Tawfir does not sell, rent, or trade your personal information to any third parties for '
                  'their own marketing or commercial purposes. We treat your data with the highest level of '
                  'confidentiality and only share it under the limited circumstances described below.\n\n'
                  'We share only the minimum data required with merchants when you make a reservation. This '
                  'includes your name and contact details necessary for order fulfillment and coordination. '
                  'All merchants are bound by strict data protection agreements and are prohibited from using '
                  'your information for any purpose beyond completing your order.\n\n'
                  'We may disclose your data to law enforcement or governmental authorities if we are legally '
                  'required to do so, or if we reasonably believe such disclosure is necessary to protect '
                  'the rights, property, or safety of Tawfir, our users, or the general public.',
            ),

            // ── Section 4: Data Security ─────────────────────────────────────
            const _LegalSection(
              title: '4. Data Security',
              body:
                  'We take the security of your personal data seriously and implement industry-standard technical '
                  'and organizational measures to protect it from unauthorized access, disclosure, alteration, '
                  'or destruction. All data transmitted between your device and our servers is encrypted using '
                  'TLS/SSL protocols.\n\n'
                  'Our backend infrastructure is powered by Google Firebase, which provides enterprise-grade '
                  'security, automatic redundancy, and compliance with major international data protection '
                  'standards including GDPR and ISO 27001. Access to user data is strictly restricted to '
                  'authorized personnel on a strict need-to-know basis.\n\n'
                  'While we strive to use commercially acceptable means to protect your personal data, no '
                  'method of electronic transmission or storage is 100% secure. We encourage you to use a '
                  'strong, unique password and to contact us immediately if you suspect any unauthorized '
                  'access to your account.',
            ),

            // ── Section 5: Location Data ─────────────────────────────────────
            const _LegalSection(
              title: '5. Location Data',
              body:
                  'Tawfir uses your device\'s location to show you food deals from nearby merchants, '
                  'sorted and filtered by proximity to your current position. Location access is requested at '
                  'the time of first use and requires your explicit permission before any location data '
                  'is collected or transmitted.\n\n'
                  'Location data is processed on our servers solely to deliver location-relevant content. We '
                  'do not retain your precise location history beyond what is necessary for the current '
                  'session, and we do not share your precise location data with merchants, advertisers, or '
                  'any other third parties at any time.\n\n'
                  'You can disable location access at any time through your device\'s system settings or '
                  'within the Tawfir app under Settings > Privacy & Security > Share Location. '
                  'Disabling location access will limit the app\'s ability to surface nearby deals '
                  'automatically, but you can still browse all available listings manually.',
            ),

            // ── Section 6: Your Rights ───────────────────────────────────────
            const _LegalSection(
              title: '6. Your Rights',
              body:
                  'Under applicable data protection laws, you have several rights regarding your personal data. '
                  'You have the right to access the personal information we hold about you, to request '
                  'corrections to any inaccurate or incomplete data, and to request the permanent deletion '
                  'of your account and all associated personal data.\n\n'
                  'You may also request a copy of your data in a portable, machine-readable format, object '
                  'to certain types of data processing, restrict how we use your data in certain situations, '
                  'and withdraw any consent you have previously given. To exercise any of these rights, '
                  'please contact our privacy team at privacy@tawfir.dz.\n\n'
                  'We will respond to all verified and legitimate requests within 30 calendar days. In some '
                  'cases, we may need to verify your identity before processing your request in order to '
                  'protect the integrity and security of your account.',
              isLast: true,
            ),

            const SizedBox(height: 24),

            // Footer contact note
            Center(
              child: Text(
                'Questions? Email us at privacy@tawfir.dz',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private Helper Widget
// ─────────────────────────────────────────────────────────────────────────────

/// A privacy document section with a green bold title, body text, and a
/// divider below (unless [isLast] is true).
class _LegalSection extends StatelessWidget {
  final String title;
  final String body;

  /// Set to true for the final section to suppress the trailing divider.
  final bool isLast;

  const _LegalSection({
    required this.title,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
        if (!isLast) ...[
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}
