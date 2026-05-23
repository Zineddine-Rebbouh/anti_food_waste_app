import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:animate_do/animate_do.dart';
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

  static const Color forestGreen = AppTheme.primary;
  static const Color accentBeige = Colors.white;
  static const Color textNavy = Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale.languageCode;

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
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: _SettingsSection(
                      icon: CupertinoIcons.bell,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 100),
                    child: _SettingsSection(
                      icon: CupertinoIcons.globe,
                      title: l10n.language,
                      addDividers: false,
                      children: [
                        _LanguageTile(
                          flag: '🇬🇧',
                          label: 'English',
                          langCode: 'en',
                          currentCode: currentLocale,
                          onTap: () => localeProvider.setLocale(const Locale('en')),
                        ),
                        const SizedBox(height: 12),
                        _LanguageTile(
                          flag: '🇩🇿',
                          label: 'العربية',
                          langCode: 'ar',
                          currentCode: currentLocale,
                          onTap: () => localeProvider.setLocale(const Locale('ar')),
                        ),
                        const SizedBox(height: 12),
                        _LanguageTile(
                          flag: '🇫🇷',
                          label: 'Français',
                          langCode: 'fr',
                          currentCode: currentLocale,
                          onTap: () => localeProvider.setLocale(const Locale('fr')),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 200),
                    child: _SettingsSection(
                      icon: CupertinoIcons.shield,
                      title: l10n.privacy_security,
                      children: [
                        _SettingToggle(
                          label: 'Share location',
                          subtitle: 'Share your location to improve nearby recommendations',
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
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 300),
                    child: _SettingsSection(
                      icon: CupertinoIcons.info,
                      title: l10n.information_section,
                      children: [
                        _SettingNav(
                          label: l10n.about_app,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                        ),
                        _SettingNav(
                          label: l10n.privacy_policy,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                        ),
                        _SettingNav(
                          label: l10n.terms_service,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen())),
                        ),
                        _buildVersionRow(l10n),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 400),
                    child: _SettingsSection(
                      icon: CupertinoIcons.trash,
                      iconColor: const Color(0xFFEF4444),
                      iconBgColor: const Color(0xFFEF4444).withOpacity(0.08),
                      title: 'Account',
                      titleColor: const Color(0xFFEF4444),
                      children: [
                        _SettingNav(
                          label: l10n.delete_account,
                          labelColor: const Color(0xFFEF4444),
                          onTap: () => _showDeleteDialog(context, l10n),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildFooter(),
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
                l10n.settings,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionRow(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.app_version_label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textNavy),
            ),
          ),
          Text('1.0.0', style: TextStyle(fontSize: 14, color: Colors.grey[400], fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'SaveFood DZ'.toUpperCase(),
          style: TextStyle(fontSize: 10, color: forestGreen.withOpacity(0.3), fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        const SizedBox(height: 4),
        Text(
          'v1.0.0',
          style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          l10n.delete_account,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFEF4444)),
        ),
        content: Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel, style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final String title;
  final Color? titleColor;
  final List<Widget> children;
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
    const forestGreen = AppTheme.primary;
    const textNavy = Color(0xFF1A1A2E);

    final dividedChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      dividedChildren.add(children[i]);
      if (addDividers && i < children.length - 1) {
        dividedChildren.add(Divider(height: 1, thickness: 1, color: Colors.grey[50]));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: forestGreen.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor ?? forestGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor ?? forestGreen, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: titleColor ?? textNavy),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...dividedChildren,
        ],
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({required this.label, this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const forestGreen = AppTheme.primary;
    const textNavy = Color(0xFF1A1A2E);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textNavy)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                ],
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: forestGreen,
          ),
        ],
      ),
    );
  }
}

class _SettingNav extends StatelessWidget {
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;

  const _SettingNav({required this.label, this.labelColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const textNavy = Color(0xFF1A1A2E);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: labelColor ?? textNavy),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[300], size: 14),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String label;
  final String langCode;
  final String currentCode;
  final VoidCallback onTap;

  const _LanguageTile({required this.flag, required this.label, required this.langCode, required this.currentCode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = langCode == currentCode;
    const forestGreen = AppTheme.primary;
    const textNavy = Color(0xFF1A1A2E);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? forestGreen.withOpacity(0.04) : Colors.white,
          border: Border.all(color: isSelected ? forestGreen.withOpacity(0.1) : Colors.grey[100]!, width: 1.5),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, color: isSelected ? forestGreen : textNavy),
              ),
            ),
            if (isSelected) const Icon(CupertinoIcons.checkmark_alt_circle_fill, color: forestGreen, size: 22),
          ],
        ),
      ),
    );
  }
}
