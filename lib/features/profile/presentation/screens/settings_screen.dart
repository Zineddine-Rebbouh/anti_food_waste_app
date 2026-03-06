import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/core/providers/locale_provider.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/about_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/terms_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/privacy_policy_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _newDeals = true,
      _reminders = true,
      _promotions = false,
      _sounds = true,
      _vibration = true;
  bool _shareLocation = false, _analytics = true, _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final String currentLocale = localeProvider.locale.languageCode;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ─── Sliver App Bar ────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            foregroundColor: AppTheme.foreground,
            expandedHeight: 140,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              l10n.settings,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.foreground,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2D8659), Color(0xFF1B5E38)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settings,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Customize your experience',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Settings Sections ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Section 1: Notifications ──────────────────────────────
                _SettingsSection(
                  icon: Icons.notifications_outlined,
                  title: l10n.notifications,
                  children: [
                    _SettingToggle(
                      label: l10n.new_deal,
                      subtitle: 'Get notified about deals near you',
                      value: _newDeals,
                      onChanged: (v) => setState(() => _newDeals = v),
                    ),
                    _SettingToggle(
                      label: l10n.pickup_reminder,
                      subtitle: 'Remind me before my pickup time',
                      value: _reminders,
                      onChanged: (v) => setState(() => _reminders = v),
                    ),
                    _SettingToggle(
                      label: 'Promotional offers',
                      subtitle: 'Receive special promotions and discounts',
                      value: _promotions,
                      onChanged: (v) => setState(() => _promotions = v),
                    ),
                    _SettingToggle(
                      label: 'Sound',
                      subtitle: 'Play sounds for notifications',
                      value: _sounds,
                      onChanged: (v) => setState(() => _sounds = v),
                    ),
                    _SettingToggle(
                      label: 'Vibration',
                      subtitle: 'Vibrate on incoming notifications',
                      value: _vibration,
                      onChanged: (v) => setState(() => _vibration = v),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Section 2: Language ────────────────────────────────────
                _SettingsSection(
                  icon: Icons.language_outlined,
                  title: l10n.language,
                  addDividers: false,
                  children: [
                    _LanguageTile(
                      flag: '🇬🇧',
                      label: 'English',
                      langCode: 'en',
                      currentCode: currentLocale,
                      onTap: () =>
                          localeProvider.setLocale(const Locale('en')),
                    ),
                    const SizedBox(height: 8),
                    _LanguageTile(
                      flag: '🇩🇿',
                      label: 'العربية',
                      langCode: 'ar',
                      currentCode: currentLocale,
                      onTap: () =>
                          localeProvider.setLocale(const Locale('ar')),
                    ),
                    const SizedBox(height: 8),
                    _LanguageTile(
                      flag: '🇫🇷',
                      label: 'Français',
                      langCode: 'fr',
                      currentCode: currentLocale,
                      onTap: () =>
                          localeProvider.setLocale(const Locale('fr')),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Section 3: Privacy ─────────────────────────────────────
                _SettingsSection(
                  icon: Icons.shield_outlined,
                  title: l10n.privacy_security,
                  children: [
                    _SettingToggle(
                      label: 'Share location',
                      subtitle:
                          'Share your location to improve nearby recommendations',
                      value: _shareLocation,
                      onChanged: (v) => setState(() => _shareLocation = v),
                    ),
                    _SettingToggle(
                      label: 'Usage analytics',
                      subtitle: 'Help us improve the app with anonymous data',
                      value: _analytics,
                      onChanged: (v) => setState(() => _analytics = v),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Section 4: Display ─────────────────────────────────────
                _SettingsSection(
                  icon: Icons.palette_outlined,
                  title: 'Display',
                  addDividers: false,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.dark_mode,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.orange.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    'Coming soon',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: _darkMode,
                            onChanged: null,
                            activeColor: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Section 5: About / Information ─────────────────────────
                _SettingsSection(
                  icon: Icons.info_outline_rounded,
                  title: l10n.information_section,
                  children: [
                    _SettingNav(
                      label: l10n.about_app,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutScreen(),
                        ),
                      ),
                    ),
                    _SettingNav(
                      label: l10n.privacy_policy,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      ),
                    ),
                    _SettingNav(
                      label: l10n.terms_service,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsScreen(),
                        ),
                      ),
                    ),
                    // App Version — no navigation, no chevron
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.app_version_label,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          Text(
                            '1.0.0',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Danger Zone: Account ───────────────────────────────────
                _SettingsSection(
                  icon: Icons.manage_accounts_outlined,
                  iconColor: Colors.red.shade700,
                  iconBgColor: Colors.red.shade50,
                  title: 'Account',
                  titleColor: Colors.red.shade700,
                  children: [
                    _SettingNav(
                      label: l10n.delete_account,
                      labelColor: Colors.red.shade700,
                      leadingIcon: Icons.delete_outline_rounded,
                      leadingIconColor: Colors.red.shade700,
                      onTap: () => _showDeleteDialog(context, l10n),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Footer version watermark
                Center(
                  child: Column(
                    children: [
                      Text(
                        'SaveFood DZ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade700,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.delete_account,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to permanently delete your account? '
          'All your data, orders, and favorites will be removed forever. '
          'This action cannot be undone.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

/// A card-style section container with an icon+title header and a list
/// of children, with optional dividers inserted between them.
class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final String title;
  final Color? titleColor;
  final List<Widget> children;

  /// When true (default), thin grey dividers are inserted between children.
  final bool addDividers;

  const _SettingsSection({
    required this.icon,
    this.iconColor,
    this.iconBgColor,
    required this.title,
    this.titleColor,
    required this.children,
    this.addDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveIconColor = iconColor ?? AppTheme.primary;
    final Color effectiveIconBg =
        iconBgColor ?? const Color(0xFF2D8659).withOpacity(0.08);

    // Build children list with optional dividers between items.
    final List<Widget> dividedChildren = [];
    for (int i = 0; i < children.length; i++) {
      dividedChildren.add(children[i]);
      if (addDividers && i < children.length - 1) {
        dividedChildren.add(
          Divider(
            height: 1,
            thickness: 0.8,
            color: Colors.grey.shade100,
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header row: icon + title
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: effectiveIconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: effectiveIconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: titleColor ?? const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...dividedChildren,
        ],
      ),
    );
  }
}

/// A row with a label, optional subtitle, and a green Switch toggle.
class _SettingToggle extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

/// A tappable navigation row with an optional leading icon and a trailing
/// chevron. Used for items that push a new screen.
class _SettingNav extends StatelessWidget {
  final String label;
  final Color? labelColor;
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final VoidCallback onTap;

  const _SettingNav({
    required this.label,
    this.labelColor,
    this.leadingIcon,
    this.leadingIconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                color: leadingIconColor ?? const Color(0xFF1A1A2E),
                size: 20,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? const Color(0xFF1A1A2E),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: labelColor?.withOpacity(0.55) ?? Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// An animated language selection tile with a radio button indicator.
class _LanguageTile extends StatelessWidget {
  final String flag;
  final String label;
  final String langCode;
  final String currentCode;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.langCode,
    required this.currentCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = langCode == currentCode;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey.shade200,
            width: isSelected ? 1.8 : 1,
          ),
          color: isSelected
              ? AppTheme.primary.withOpacity(0.04)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: langCode,
              groupValue: currentCode,
              onChanged: (_) => onTap(),
              activeColor: AppTheme.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppTheme.primary
                      : const Color(0xFF1A1A2E),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
