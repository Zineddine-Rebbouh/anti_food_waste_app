import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:animate_do/animate_do.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                      l10n.tos_last_updated.toUpperCase(),
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
                          title: l10n.tos_section1_title,
                          body: l10n.tos_section1_body,
                        ),
                        _LegalSection(
                          title: l10n.tos_section2_title,
                          body: l10n.tos_section2_body,
                        ),
                        _LegalSection(
                          title: l10n.tos_section3_title,
                          body: l10n.tos_section3_body,
                        ),
                        _LegalSection(
                          title: l10n.tos_section4_title,
                          body: l10n.tos_section4_body,
                        ),
                        _LegalSection(
                          title: l10n.tos_section5_title,
                          body: l10n.tos_section5_body,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      l10n.tos_footer,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: forestGreen.withOpacity(0.3),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
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
                l10n.terms_service,
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
