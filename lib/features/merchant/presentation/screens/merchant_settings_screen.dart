import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/providers/locale_provider.dart';
import 'package:anti_food_waste_app/core/services/preferences_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MerchantSettingsScreen extends StatefulWidget {
  const MerchantSettingsScreen({super.key});

  @override
  State<MerchantSettingsScreen> createState() => _MerchantSettingsScreenState();
}

class _MerchantSettingsScreenState extends State<MerchantSettingsScreen> {
  bool _darkMode = false;
  bool _compactView = false;
  bool _autoAccept = false;
  bool _twoFactor = false;
  late bool _chatBubbleEnabled;

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _chatBubbleEnabled = PreferencesService.isChatBubbleEnabled();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLang = localeProvider.locale.languageCode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, l10n),
            const SizedBox(height: 24),
            _buildSectionHeader(l10n.language.toUpperCase()),
            _buildSectionCard([
              _LanguageTile(
                flag: '🇬🇧',
                label: 'English',
                code: 'en',
                selected: currentLang == 'en',
                onTap: () => localeProvider.setLocale(const Locale('en')),
              ),
              _LanguageTile(
                flag: '🇫🇷',
                label: 'Français',
                code: 'fr',
                selected: currentLang == 'fr',
                onTap: () => localeProvider.setLocale(const Locale('fr')),
              ),
              _LanguageTile(
                flag: '🇩🇿',
                label: 'العربية',
                code: 'ar',
                selected: currentLang == 'ar',
                onTap: () => localeProvider.setLocale(const Locale('ar')),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader(l10n.app_preferences.toUpperCase()),
            _buildSectionCard([
              _SwitchTile(
                icon: Icons.dark_mode_outlined,
                iconColor: const Color(0xFF6366F1),
                label: l10n.dark_mode,
                subtitle: l10n.dark_mode_desc,
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              _SwitchTile(
                icon: Icons.view_compact_outlined,
                iconColor: const Color(0xFFF59E0B),
                label: l10n.compact_view,
                subtitle: l10n.compact_view_desc,
                value: _compactView,
                onChanged: (v) => setState(() => _compactView = v),
              ),
              _SwitchTile(
                icon: Icons.auto_awesome_outlined,
                iconColor: const Color(0xFF2D8659),
                label: l10n.auto_accept,
                subtitle: l10n.auto_accept_desc,
                value: _autoAccept,
                onChanged: (v) => setState(() => _autoAccept = v),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader(l10n.account_security.toUpperCase()),
            _buildSectionCard([
              _SwitchTile(
                icon: Icons.security_outlined,
                iconColor: primaryGreen,
                label: l10n.two_factor,
                subtitle: l10n.two_factor_desc,
                value: _twoFactor,
                onChanged: (v) => setState(() => _twoFactor = v),
              ),
              _SwitchTile(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: const Color(0xFF2563EB),
                label: 'Chat assistant bubble',
                subtitle: 'Show the draggable chat bubble on main screens.',
                value: _chatBubbleEnabled,
                onChanged: (v) {
                  setState(() => _chatBubbleEnabled = v);
                  PreferencesService.setChatBubbleEnabled(v);
                },
              ),
              _ActionTile(
                icon: Icons.lock_outline,
                iconColor: const Color(0xFF374151),
                label: l10n.change_password,
                subtitle: l10n.change_password_desc,
                onTap: () => _showChangePassword(context),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader(l10n.danger_zone_label),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFEE2E2)),
                ),
                child: _ActionTile(
                  icon: Icons.person_off_outlined,
                  iconColor: const Color(0xFFEF4444),
                  label: l10n.deactivate_account,
                  subtitle: l10n.deactivate_account_desc,
                  textColor: const Color(0xFFEF4444),
                  onTap: () => _confirmDeactivate(context),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                l10n.app_version_label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD1D5DB)),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -20,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withOpacity(0.04),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      l10n.app_settings_title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      l10n.app_settings_subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Color(0xFF374151)),
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: primaryGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showChangePassword(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.change_password,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                decoration: InputDecoration(
                    labelText: l10n.current_password,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextField(
                decoration: InputDecoration(
                    labelText: l10n.new_password,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)))),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel,
                  style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              Navigator.pop(ctx);
              _showSnack(context, l10n.password_updated);
            },
            child: Text(l10n.update),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivate(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.deactivate_account_confirm,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(l10n.deactivate_warning),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel,
                  style: const TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.deactivate,
                  style: const TextStyle(
                      color: Color(0xFFEF4444), fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LanguageTile(
      {required this.flag,
      required this.label,
      required this.selected,
      required this.onTap,
      required String code});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: selected
                  ? const Color(0xFF2D8659)
                  : const Color(0xFF111827))),
      trailing: selected
          ? const Icon(Icons.check_circle, color: Color(0xFF2D8659), size: 22)
          : null,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile(
      {required this.icon,
      required this.iconColor,
      required this.label,
      required this.subtitle,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 20)),
      title: Text(label,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827))),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF2D8659)),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final Color? textColor;
  final VoidCallback onTap;

  const _ActionTile(
      {required this.icon,
      required this.iconColor,
      required this.label,
      required this.subtitle,
      required this.onTap,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 20)),
      title: Text(label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textColor ?? const Color(0xFF111827))),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing:
          const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB), size: 20),
    );
  }
}
