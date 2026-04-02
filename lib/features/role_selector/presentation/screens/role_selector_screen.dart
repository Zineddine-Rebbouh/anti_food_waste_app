import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/core/navigation/app_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RoleSelectorScreen
//
// Prototype entry point: lets testers jump directly into any of the three
// modules without going through the full auth flow.
// ─────────────────────────────────────────────────────────────────────────────

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Algerian flag accent bar ──────────────────────────────────
              Container(
                height: 4,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2D8659),
                      Colors.white,
                      Color(0xFFD32F2F),
                    ],
                  ),
                ),
              ),

              // ── Logo ─────────────────────────────────────────────────────
              Container(
                width: 86,
                height: 86,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2D8659), Color(0xFF1A5E3C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco, size: 46, color: Colors.white),
              ),
              const SizedBox(height: 16),

              const Text(
                'Tawfir',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select a role to explore the app',
                style: TextStyle(fontSize: 14.5, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // ── Consumer ─────────────────────────────────────────────────
              _RoleCard(
                icon: Icons.shopping_bag_outlined,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D8659), Color(0xFF1A5E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                role: 'Consumer',
                tag: 'For individuals',
                tagColor: const Color(0xFF6EE7B7),
                description:
                    'Discover discounted surplus food near you, reserve meals and track your eco-impact.',
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.consumer,
                  (_) => false,
                ),
              ),
              const SizedBox(height: 14),

              // ── Merchant ─────────────────────────────────────────────────
              _RoleCard(
                icon: Icons.storefront_outlined,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                role: 'Merchant',
                tag: 'For businesses',
                tagColor: const Color(0xFF93C5FD),
                description:
                    'List surplus food, manage orders and QR pickups, track earnings and analytics.',
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.merchant,
                  (_) => false,
                ),
              ),
              const SizedBox(height: 14),

              // ── Charity ──────────────────────────────────────────────────
              _RoleCard(
                icon: Icons.volunteer_activism_outlined,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                role: 'Charity',
                tag: 'For organisations',
                tagColor: const Color(0xFFC4B5FD),
                description:
                    'Request food donations, coordinate pickups and submit impact reports.',
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.charity,
                  (_) => false,
                ),
              ),

              const SizedBox(height: 36),

              // ── Sign in link ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?  ',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.login),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Footer ───────────────────────────────────────────────────
              Text(
                'Made in Algeria  \u{1F1E9}\u{1F1FF}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RoleCard
// ─────────────────────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final LinearGradient gradient;
  final String role;
  final String tag;
  final Color tagColor;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.gradient,
    required this.role,
    required this.tag,
    required this.tagColor,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.12),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(gradient: gradient),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon box
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 18),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Role name + tag pill
                      Row(
                        children: [
                          Text(
                            role,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: tagColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.82),
                          fontSize: 12.5,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
