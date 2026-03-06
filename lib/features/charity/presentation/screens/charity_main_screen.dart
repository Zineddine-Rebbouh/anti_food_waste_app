import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/core/navigation/app_router.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_home_screen.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_donations_screen.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_requests_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CharityMainScreen — bottom-navigation shell for the Charity module
// ─────────────────────────────────────────────────────────────────────────────

class CharityMainScreen extends StatefulWidget {
  const CharityMainScreen({super.key});

  @override
  State<CharityMainScreen> createState() => _CharityMainScreenState();
}

class _CharityMainScreenState extends State<CharityMainScreen> {
  int _currentIndex = 0;

  // Screens are kept alive via IndexedStack; use const constructors where
  // possible to avoid unnecessary rebuilds.
  static final List<Widget> _screens = [
    const CharityHomeScreen(),
    const CharityDonationsScreen(),
    const CharityRequestsScreen(),
    const CharityOrgProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _CharityBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Navigation Bar
// ─────────────────────────────────────────────────────────────────────────────

class _CharityBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CharityBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.volunteer_activism_outlined),
            activeIcon: const Icon(Icons.volunteer_activism),
            label: 'Donations',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_shipping_outlined),
            activeIcon: const Icon(Icons.local_shipping),
            label: 'Pickups',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.apartment_outlined),
            activeIcon: const Icon(Icons.apartment),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CharityOrgProfileScreen — inline static charity organisation profile
// ─────────────────────────────────────────────────────────────────────────────

class CharityOrgProfileScreen extends StatelessWidget {
  const CharityOrgProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Organisation Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Green gradient header ─────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2D8659), Color(0xFF1B5E38)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.apartment,
                      size: 40,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Org name
                  const Text(
                    'Secours Alimentaire Algérie',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  // Subtitle
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Verified Charity · Algiers',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProfileStat(value: '128', label: 'Pickups'),
                      _VerticalDivider(),
                      _ProfileStat(value: '4,820', label: 'Meals'),
                      _VerticalDivider(),
                      _ProfileStat(value: '12', label: 'Wilayas'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Info card ────────────────────────────────────────────────────
            _SectionCard(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardSectionTitle('About Us'),
                  const SizedBox(height: 8),
                  const Text(
                    'Secours Alimentaire Algérie is a non-profit organisation '
                    'dedicated to recovering surplus food from restaurants, hotels, '
                    'bakeries, and grocery stores and redistributing it to vulnerable '
                    'families and individuals across Algeria. Our mission is to '
                    'eliminate food waste and fight food insecurity simultaneously.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF444455),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _CardSectionTitle('Contact'),
                  const SizedBox(height: 10),
                  _ContactRow(
                    icon: Icons.phone_outlined,
                    text: '+213 21 63 44 00',
                  ),
                  const SizedBox(height: 8),
                  _ContactRow(
                    icon: Icons.email_outlined,
                    text: 'contact@saa-algerie.dz',
                  ),
                  const SizedBox(height: 8),
                  _ContactRow(
                    icon: Icons.location_on_outlined,
                    text: '12 Rue Hassiba Ben Bouali, Hussein Dey, Alger',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Activity stats card ──────────────────────────────────────────
            _SectionCard(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardSectionTitle('Activity Overview'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStatTile(
                          icon: Icons.task_alt_rounded,
                          color: AppTheme.primary,
                          title: '128',
                          subtitle: 'Completed pickups',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniStatTile(
                          icon: Icons.people_alt_outlined,
                          color: Colors.purple.shade600,
                          title: '3,240',
                          subtitle: 'Beneficiaries reached',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStatTile(
                          icon: Icons.scale_outlined,
                          color: Colors.blue.shade600,
                          title: '1.8 t',
                          subtitle: 'Food rescued',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniStatTile(
                          icon: Icons.star_outline_rounded,
                          color: Colors.amber.shade700,
                          title: '4.9',
                          subtitle: 'Avg. merchant rating',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Settings shortcuts ───────────────────────────────────────────
            _SectionCard(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () {},
                  ),
                  _Separator(),
                  _SettingsRow(
                    icon: Icons.lock_outline_rounded,
                    label: 'Change Password',
                    onTap: () {},
                  ),
                  _Separator(),
                  _SettingsRow(
                    icon: Icons.language_outlined,
                    label: 'Language',
                    trailing: Text(
                      'English',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500),
                    ),
                    onTap: () {},
                  ),
                  _Separator(),
                  _SettingsRow(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Logout button ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () => AppRouter.exitToRoleSelector(context),
                icon: const Icon(Icons.logout_rounded,
                    size: 18, color: AppTheme.accent),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: BorderSide(
                      color: AppTheme.accent.withOpacity(0.4), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Footer ───────────────────────────────────────────────────────
            Text(
              'App version 1.0.0-charity-beta',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small reusable widgets for CharityOrgProfileScreen
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white24,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;

  const _SectionCard({required this.child, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100, width: 1.2),
      ),
      child: child,
    );
  }
}

class _CardSectionTitle extends StatelessWidget {
  final String text;

  const _CardSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A2E),
        letterSpacing: 0.2,
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF444455)),
          ),
        ),
      ],
    );
  }
}

class _MiniStatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _MiniStatTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style:
                    TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 17, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
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
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
          ],
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: Colors.grey.shade100);
  }
}
