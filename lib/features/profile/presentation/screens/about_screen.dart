import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:animate_do/animate_do.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    child: _buildHeroSection(),
                  ),
                  const SizedBox(height: 32),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: _AboutCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AboutSectionTitle(l10n.our_mission),
                          const SizedBox(height: 16),
                          Text(
                            l10n.app_about_desc,
                            style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 20),
                          _BulletPoint(text: l10n.reduce_food_waste),
                          const SizedBox(height: 10),
                          _BulletPoint(text: l10n.support_local_merchants),
                          const SizedBox(height: 10),
                          _BulletPoint(text: l10n.build_greener_communities),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _AboutCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(value: '500+', label: l10n.about_stat_merchants),
                            Container(width: 1, height: 40, color: Colors.grey[100]),
                            _StatItem(value: '10k+', label: l10n.about_stat_meals),
                            Container(width: 1, height: 40, color: Colors.grey[100]),
                            _StatItem(value: '50+', label: l10n.about_stat_wilayas),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _AboutCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AboutSectionTitle(l10n.contact_us_label),
                          const SizedBox(height: 16),
                          const _ContactTile(icon: Icons.mail_rounded, label: 'contact@tawfir.dz', onTap: null),
                          Divider(height: 1, color: Colors.grey[50]),
                          const _ContactTile(icon: Icons.camera_alt_rounded, label: '@tawfir.dz', onTap: null),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    l10n.made_in_algeria.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: forestGreen.withOpacity(0.3), fontWeight: FontWeight.w900, letterSpacing: 2),
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
                l10n.about_app,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: forestGreen,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: forestGreen.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 24),
          const Text(
            'TAWFIR',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4),
          ),
          const SizedBox(height: 8),
          Text(
            'v1.0.0',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final Widget child;
  const _AboutCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }
}

class _AboutSectionTitle extends StatelessWidget {
  final String text;
  const _AboutSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.primary.withOpacity(0.5), letterSpacing: 1.2),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6, right: 12),
          decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primary)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _TeamMember extends StatelessWidget {
  final String initials;
  final String name;
  final String role;
  final Color avatarColor;

  const _TeamMember({required this.initials, required this.name, required this.role, required this.avatarColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: avatarColor.withOpacity(0.1),
          child: Text(initials, style: TextStyle(color: avatarColor, fontWeight: FontWeight.w900, fontSize: 16)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 4),
              Text(role, style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ContactTile({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w700)),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// A circular grey social media icon button.
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.grey.shade50,
        ),
        child: Icon(icon, color: Colors.grey.shade600, size: 22),
      ),
    );
  }
}
