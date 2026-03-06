import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          l10n.terms_service,
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

            // ── Section 1: Acceptance of Terms ──────────────────────────────
            const _LegalSection(
              title: '1. Acceptance of Terms',
              body:
                  'By accessing or using the SaveFood DZ application, you agree to be bound by these Terms of Service '
                  'and all applicable laws and regulations. If you do not agree to all the terms and conditions '
                  'stated herein, you must not access or use our services.\n\n'
                  'Your continued use of the application following the posting of any changes to these terms '
                  'constitutes your acceptance of those changes. We reserve the right to modify these terms at any '
                  'time, and such modifications shall be effective immediately upon posting to the platform.\n\n'
                  'These terms apply to all users of the application, including consumers, merchants, and charity '
                  'organizations. Please read them carefully before proceeding with any activity on the platform.',
            ),

            // ── Section 2: Use of the Service ───────────────────────────────
            const _LegalSection(
              title: '2. Use of the Service',
              body:
                  'SaveFood DZ grants you a limited, non-exclusive, non-transferable, and revocable license to use '
                  'our application for personal, non-commercial purposes in accordance with these terms. You may '
                  'not sublicense, sell, resell, or commercially exploit any portion of the service.\n\n'
                  'You agree not to use the service for any unlawful purpose or in any way that could damage, '
                  'disable, overburden, or impair the application or its servers. Prohibited activities include '
                  'attempting to gain unauthorized access to any part of the service, using automated tools to '
                  'scrape or harvest data, and impersonating other users or merchants.\n\n'
                  'We reserve the right to suspend or terminate your access to the service at any time and without '
                  'notice if we reasonably believe you have violated these terms, engaged in fraudulent activity, '
                  'or acted in a manner harmful to the interests of other users or merchants.',
            ),

            // ── Section 3: User Accounts ─────────────────────────────────────
            const _LegalSection(
              title: '3. User Accounts',
              body:
                  'To access certain features of the application, you must create an account by providing accurate, '
                  'current, and complete information as prompted by the registration form. You are solely '
                  'responsible for maintaining the confidentiality of your account credentials and for all '
                  'activities that occur under your account.\n\n'
                  'You agree to immediately notify SaveFood DZ of any unauthorized use of your account or any '
                  'other breach of security. We will not be liable for any loss or damage arising from your '
                  'failure to comply with this section or to adequately protect your login credentials.\n\n'
                  'You must be at least 16 years of age to create an account and use our services. By registering '
                  'an account, you represent and warrant that you meet this minimum age requirement and that all '
                  'information you provide is truthful and accurate.',
            ),

            // ── Section 4: Food Listings & Purchases ─────────────────────────
            const _LegalSection(
              title: '4. Food Listings & Purchases',
              body:
                  'Merchants are solely responsible for the accuracy, legality, and completeness of their food '
                  'listings on the platform, including descriptions, pricing, allergen information, and pickup '
                  'windows. SaveFood DZ acts as an intermediary and does not guarantee the availability, quality, '
                  'or safety of any listed items.\n\n'
                  'Purchases or reservations made through the application are subject to the merchant\'s own terms '
                  'of sale. SaveFood DZ does not guarantee that a specific item will be available at the time of '
                  'pickup, as quantities are dependent on actual surplus stock at the time of collection.\n\n'
                  'Consumers are advised to check for allergen information directly with the merchant before '
                  'collecting their order. SaveFood DZ expressly disclaims all liability for any allergic '
                  'reactions, foodborne illness, or other health issues arising from food purchased on the platform.',
            ),

            // ── Section 5: Payments & Refunds ────────────────────────────────
            const _LegalSection(
              title: '5. Payments & Refunds',
              body:
                  'Payments for orders on SaveFood DZ may be processed in-app or collected at the point of pickup, '
                  'depending on each merchant\'s configuration. All in-app payment data is encrypted using '
                  'industry-standard protocols and processed through secure, PCI-DSS compliant payment gateways.\n\n'
                  'Refunds are issued at the sole discretion of the merchant. If you believe you are entitled to '
                  'a refund due to a significant deviation from the listed description or confirmed non-availability '
                  'at the time of pickup, please contact our support team within 24 hours of the scheduled '
                  'pickup time with relevant evidence.\n\n'
                  'SaveFood DZ charges no additional fees to consumers beyond the price listed at the time of '
                  'reservation. Any service fees or commissions applicable to merchants are outlined separately '
                  'in the Merchant Agreement and do not affect the price shown to consumers.',
            ),

            // ── Section 6: Limitation of Liability ──────────────────────────
            const _LegalSection(
              title: '6. Limitation of Liability',
              body:
                  'To the fullest extent permitted by applicable law, SaveFood DZ and its affiliates, officers, '
                  'directors, employees, and agents shall not be liable for any indirect, incidental, special, '
                  'consequential, or punitive damages arising from your use of, or inability to use, the service '
                  'or any content obtained through the service.\n\n'
                  'Our total aggregate liability for any claim arising out of or relating to these terms or the '
                  'service shall not exceed the total amount you paid to SaveFood DZ in the twelve months '
                  'preceding the event giving rise to the claim. Some jurisdictions do not allow the exclusion '
                  'of certain warranties or limitations of liability, so the above may not fully apply to you.\n\n'
                  'SaveFood DZ is not responsible for any food safety incidents, health consequences, financial '
                  'losses, or disputes arising directly from transactions conducted between consumers and merchants '
                  'on our platform. Users engage with merchants at their own risk.',
              isLast: true,
            ),

            const SizedBox(height: 24),

            // Footer copyright
            Center(
              child: Text(
                '© 2025 SaveFood DZ. All rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
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

/// A legal document section with a green bold title, body text, and a divider
/// below (unless [isLast] is true).
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
