import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          l10n.about_app,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.foreground,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header Gradient Card ──────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2D8659), Color(0xFF1B5E38)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tawfir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // ─── Mission Card ────────────────────────────────────────
                  _AboutCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AboutSectionTitle(l10n.our_mission),
                        const SizedBox(height: 12),
                        Text(
                          l10n.app_about_desc,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const _BulletPoint(
                            text: 'Reduce food waste across Algeria'),
                        const SizedBox(height: 8),
                        const _BulletPoint(
                            text: 'Support local merchants and businesses'),
                        const SizedBox(height: 8),
                        const _BulletPoint(
                            text:
                                'Build greener, more sustainable communities'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── Stats Row Card ───────────────────────────────────────
                  _AboutCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const _StatItem(value: '500+', label: 'Merchants'),
                          Container(
                            width: 1,
                            height: 40,
                            color: Color(0xFFE5E7EB),
                          ),
                          const _StatItem(
                              value: '10k+', label: 'Meals Saved'),
                          Container(
                            width: 1,
                            height: 40,
                            color: Color(0xFFE5E7EB),
                          ),
                          const _StatItem(value: '50+', label: 'Wilayas'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── Team Card ────────────────────────────────────────────
                  _AboutCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AboutSectionTitle(l10n.meet_the_team),
                        const SizedBox(height: 16),
                        const _TeamMember(
                          initials: 'ZR',
                          name: 'Zineddine Rahim',
                          role: 'Founder & Developer',
                          avatarColor: AppTheme.primary,
                        ),
                        const SizedBox(height: 12),
                        const _TeamMember(
                          initials: 'AI',
                          name: 'Amir Ibrahimi',
                          role: 'UI/UX Designer',
                          avatarColor: Color(0xFF1B6B42),
                        ),
                        const SizedBox(height: 12),
                        const _TeamMember(
                          initials: 'SK',
                          name: 'Sara Kaouani',
                          role: 'Marketing & Partnerships',
                          avatarColor: Color(0xFF4CAF50),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── Contact Card ─────────────────────────────────────────
                  _AboutCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AboutSectionTitle(l10n.contact_us_label),
                        const SizedBox(height: 12),
                        _ContactTile(
                          icon: Icons.email_outlined,
                          label: 'contact@tawfir.dz',
                          onTap: () {},
                        ),
                        Divider(height: 1, color: Colors.grey.shade100),
                        _ContactTile(
                          icon: Icons.camera_alt_outlined,
                          label: '@tawfir.dz',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── Follow Us Card ───────────────────────────────────────
                  _AboutCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AboutSectionTitle(l10n.follow_us),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialButton(
                              icon: Icons.camera_alt_outlined,
                              onTap: () {},
                            ),
                            const SizedBox(width: 16),
                            _SocialButton(
                              icon: Icons.work_outline,
                              onTap: () {},
                            ),
                            const SizedBox(width: 16),
                            _SocialButton(
                              icon: Icons.facebook,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ─── Footer ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      l10n.made_in_algeria,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Card container with white background, rounded-20 corners, thin grey border.
class _AboutCard extends StatelessWidget {
  final Widget child;

  const _AboutCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.2),
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}

/// Bold dark section title used inside cards.
class _AboutSectionTitle extends StatelessWidget {
  final String text;

  const _AboutSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A2E),
      ),
    );
  }
}

/// A green-bullet point row for mission list items.
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
          margin: const EdgeInsets.only(top: 5, right: 10),
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// A statistic item: large bold green value + small grey label below.
class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

/// A team member row with a coloured circular avatar (initials), name, role.
class _TeamMember extends StatelessWidget {
  final String initials;
  final String name;
  final String role;
  final Color avatarColor;

  const _TeamMember({
    required this.initials,
    required this.name,
    required this.role,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: avatarColor,
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                role,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A tappable contact row with a green icon circle, label, and chevron.
class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
                  fontWeight: FontWeight.w500,
                ),
              ),
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
