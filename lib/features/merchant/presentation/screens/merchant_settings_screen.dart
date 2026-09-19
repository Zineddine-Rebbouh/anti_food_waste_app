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
  bool _autoAccept = false;
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
                icon: Icons.auto_awesome_outlined,
                iconColor: const Color(0xFF2D8659),
                label: l10n.auto_accept,
                subtitle: l10n.auto_accept_desc,
                value: _autoAccept,
                onChanged: (v) => setState(() => _autoAccept = v),
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
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('ACCOUNT'),
            _buildSectionCard([
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
                      'Settings',
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
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.lock_outline, color: primaryGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.change_password,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a strong new password for your account.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _ModernPasswordField(
                controller: currentCtrl,
                label: l10n.current_password,
                obscureText: true,
              ),
              const SizedBox(height: 14),
              _ModernPasswordField(
                controller: newCtrl,
                label: l10n.new_password,
                obscureText: true,
              ),
              const SizedBox(height: 14),
              _ModernPasswordField(
                controller: confirmCtrl,
                label: l10n.confirm_new_password,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        foregroundColor: const Color(0xFF111827),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showSnack(context, l10n.password_updated);
                      },
                      child: Text(l10n.update),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

class _ModernPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;

  const _ModernPasswordField({
    required this.controller,
    required this.label,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Color(0xFF2D8659), width: 1.5),
        ),
      ),
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
