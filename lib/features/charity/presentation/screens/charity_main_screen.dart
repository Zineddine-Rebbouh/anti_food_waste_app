import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:anti_food_waste_app/core/navigation/app_router.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_home_screen.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_donations_screen.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_requests_screen.dart';
import 'package:anti_food_waste_app/features/chat/presentation/widgets/chat_floating_button.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:anti_food_waste_app/core/providers/locale_provider.dart';
import 'package:anti_food_waste_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:animate_do/animate_do.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CharityMainScreen — bottom-navigation shell for the Charity module
// ─────────────────────────────────────────────────────────────────────────────

class CharityMainScreen extends StatefulWidget {
  const CharityMainScreen({super.key});

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color accentBeige = Colors.white;

  @override
  State<CharityMainScreen> createState() => _CharityMainScreenState();
}

class _CharityMainScreenState extends State<CharityMainScreen> {
  int _currentIndex = 0;

  static final List<Widget> _screens = [
    const CharityHomeScreen(),
    const CharityDonationsScreen(),
    const CharityRequestsScreen(),
    const CharityOrgProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CharityMainScreen.accentBeige,
      floatingActionButton: const ChatFloatingButton(),
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

class _CharityBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CharityBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: CharityMainScreen.primaryGreen,
            unselectedItemColor: Colors.grey.shade400,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            items: [
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.dashboard_outlined)),
                activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.dashboard_rounded)),
                label: l10n.home.toUpperCase(),
              ),
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.volunteer_activism_outlined)),
                activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.volunteer_activism_rounded)),
                label: l10n.donations_tab.toUpperCase(),
              ),
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.local_shipping_outlined)),
                activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.local_shipping_rounded)),
                label: l10n.pickups_tab.toUpperCase(),
              ),
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.apartment_outlined)),
                activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.apartment_rounded)),
                label: l10n.profile.toUpperCase(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CharityOrgProfileScreen extends StatelessWidget {
  const CharityOrgProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: CharityMainScreen.accentBeige,
      body: SingleChildScrollView(
        child: Column(
          children: [
            FadeInDown(duration: const Duration(milliseconds: 600), child: _buildProfileHeader(context, l10n)),
            const SizedBox(height: 24),
            FadeInUp(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 600), child: _buildAboutCard(l10n)),
            const SizedBox(height: 16),
            FadeInUp(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 600), child: _buildActivityOverview(context, l10n)),
            const SizedBox(height: 16),
            FadeInUp(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 600), child: _buildSettingsShortcuts(context, l10n)),
            const SizedBox(height: 32),
            FadeIn(delay: const Duration(milliseconds: 500), child: _buildLogoutButton(context, l10n)),
            const SizedBox(height: 48),
            Text(
              'App version 1.0.0-charity-beta',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: CharityMainScreen.primaryGreen,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(56), bottomRight: Radius.circular(56)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 56),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.organisation_profile.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 22),
                      onPressed: () {
                        final state = context.read<ProfileCubit>().state;
                        if (state is ProfileLoaded) Navigator.pushNamed(context, AppRoutes.editProfile, arguments: state.user);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Hero(
                tag: 'profile_avatar',
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 15))],
                  ),
                  child: const Center(child: Icon(Icons.apartment_rounded, size: 56, color: CharityMainScreen.primaryGreen)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.charity_name_placeholder,
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(100)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF2D8659)),
                    const SizedBox(width: 8),
                    Text('${l10n.verified_charity} · ${l10n.location_algiers}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ProfileStat(value: '128', label: l10n.pickups_tab.toUpperCase()),
                  Container(width: 1.5, height: 24, color: Colors.white.withOpacity(0.1)),
                  _ProfileStat(value: '4.8k', label: l10n.meals_provided.toUpperCase()),
                  Container(width: 1.5, height: 24, color: Colors.white.withOpacity(0.1)),
                  _ProfileStat(value: '12', label: l10n.wilayas_stat.toUpperCase()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutCard(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: CharityMainScreen.primaryGreen.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.about_us.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
            const SizedBox(height: 20),
            Text(l10n.charity_about_us_msg, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.6, fontWeight: FontWeight.w600)),
            const SizedBox(height: 28),
            _ContactRow(icon: Icons.phone_rounded, text: l10n.charity_phone_placeholder),
            const SizedBox(height: 14),
            _ContactRow(icon: Icons.alternate_email_rounded, text: l10n.charity_email_placeholder),
            const SizedBox(height: 14),
            _ContactRow(icon: Icons.location_on_rounded, text: l10n.charity_address_placeholder),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityOverview(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: CharityMainScreen.primaryGreen.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.activity_overview.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _MiniStatTile(icon: Icons.task_alt_rounded, color: const Color(0xFF2D8659), title: '128', subtitle: l10n.completed_pickups)),
                const SizedBox(width: 14),
                Expanded(child: _MiniStatTile(icon: Icons.people_alt_rounded, color: const Color(0xFF6366F1), title: '3,240', subtitle: l10n.people_reached)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _MiniStatTile(icon: Icons.scale_rounded, color: const Color(0xFF3B82F6), title: '1.8t', subtitle: l10n.food_rescued)),
                const SizedBox(width: 14),
                Expanded(child: _MiniStatTile(icon: Icons.stars_rounded, color: const Color(0xFFF59E0B), title: '4.9', subtitle: l10n.avg_merchant_rating)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.impactDashboard),
                icon: const Icon(Icons.analytics_rounded, size: 18),
                label: Text(l10n.view_detailed_impact.toUpperCase()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CharityMainScreen.primaryGreen.withOpacity(0.05),
                  foregroundColor: CharityMainScreen.primaryGreen,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsShortcuts(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: CharityMainScreen.primaryGreen.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            _SettingsRow(icon: Icons.notifications_none_rounded, label: l10n.notifications, onTap: () => Navigator.pushNamed(context, AppRoutes.notifications)),
            _SettingsRow(icon: Icons.lock_open_rounded, label: l10n.change_password, onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword)),
            _SettingsRow(
              icon: Icons.translate_rounded,
              label: l10n.language,
              trailing: Text(_getLanguageName(context), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.grey.shade400)),
              onTap: () => _showLanguagePicker(context),
            ),
            _SettingsRow(icon: Icons.help_outline_rounded, label: l10n.help_support, onTap: () => Navigator.pushNamed(context, AppRoutes.help)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextButton(
        onPressed: () => _confirmLogout(context, l10n),
        style: TextButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16)),
        child: Text(l10n.sign_out.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('${l10n.sign_out}?', style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(l10n.logout_confirm_msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w900))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
              AppRouter.exitToLogin(context);
            },
            child: Text(l10n.sign_out, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context).locale.languageCode;
    switch (locale) {
      case 'ar': return '🇩🇿 العربية';
      case 'fr': return '🇫🇷 Français';
      default: return '🇬🇧 English';
    }
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final localeProvider = Provider.of<LocaleProvider>(context);
        final currentLocale = localeProvider.locale.languageCode;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.language, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),
              _LanguageOption(label: 'العربية', flag: '🇩🇿', isSelected: currentLocale == 'ar', onTap: () { localeProvider.setLocale(const Locale('ar')); Navigator.pop(context); }),
              const SizedBox(height: 12),
              _LanguageOption(label: 'Français', flag: '🇫🇷', isSelected: currentLocale == 'fr', onTap: () { localeProvider.setLocale(const Locale('fr')); Navigator.pop(context); }),
              const SizedBox(height: 12),
              _LanguageOption(label: 'English', flag: '🇬🇧', isSelected: currentLocale == 'en', onTap: () { localeProvider.setLocale(const Locale('en')); Navigator.pop(context); }),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;
  const _LanguageOption({required this.label, required this.flag, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D8659).withOpacity(0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF2D8659) : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, color: isSelected ? const Color(0xFF2D8659) : Colors.grey.shade700))),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF2D8659), size: 20),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1)),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
      ],
    );
  }
}

class _MiniStatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _MiniStatTile({required this.icon, required this.color, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 9, color: Colors.grey.shade500, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
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
  const _SettingsRow({required this.icon, required this.label, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: const Color(0xFF2D8659))),
      title: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
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
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2D8659)),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600))),
      ],
    );
  }
}



