import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/providers/locale_provider.dart';
import 'package:provider/provider.dart';

class MerchantSettingsScreen extends StatefulWidget {
  const MerchantSettingsScreen({super.key});

  @override
  State<MerchantSettingsScreen> createState() =>
      _MerchantSettingsScreenState();
}

class _MerchantSettingsScreenState extends State<MerchantSettingsScreen> {
  bool _darkMode = false;
  bool _compactView = false;
  bool _autoAccept = false;
  bool _twoFactor = false;

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLang = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110,
            pinned: true,
            backgroundColor: const Color(0xFF2D8659),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2D8659), Color(0xFF1A5E3C)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(56, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text(
                          'Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'App preferences & account',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Language section
                _buildSectionTitle('Language'),
                _buildCard(children: [
                  _LanguageTile(
                    flag: '🇬🇧',
                    label: 'English',
                    code: 'en',
                    selected: currentLang == 'en',
                    onTap: () => localeProvider.setLocale(const Locale('en')),
                  ),
                  const _Div(),
                  _LanguageTile(
                    flag: '🇫🇷',
                    label: 'Français',
                    code: 'fr',
                    selected: currentLang == 'fr',
                    onTap: () => localeProvider.setLocale(const Locale('fr')),
                  ),
                  const _Div(),
                  _LanguageTile(
                    flag: '🇩🇿',
                    label: 'العربية',
                    code: 'ar',
                    selected: currentLang == 'ar',
                    onTap: () => localeProvider.setLocale(const Locale('ar')),
                  ),
                ]),

                const SizedBox(height: 20),

                // App Preferences
                _buildSectionTitle('App Preferences'),
                _buildCard(children: [
                  _SwitchTile(
                    icon: Icons.dark_mode_outlined,
                    iconColor: const Color(0xFF6366F1),
                    label: 'Dark Mode',
                    subtitle: 'Use dark theme throughout the app',
                    value: _darkMode,
                    onChanged: (v) => setState(() => _darkMode = v),
                  ),
                  const _Div(),
                  _SwitchTile(
                    icon: Icons.view_compact_outlined,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Compact View',
                    subtitle: 'Display more items on screen',
                    value: _compactView,
                    onChanged: (v) => setState(() => _compactView = v),
                  ),
                  const _Div(),
                  _SwitchTile(
                    icon: Icons.auto_awesome_outlined,
                    iconColor: const Color(0xFF10B981),
                    label: 'Auto-Accept Donations',
                    subtitle: 'Auto-confirm charity pickup requests',
                    value: _autoAccept,
                    onChanged: (v) => setState(() => _autoAccept = v),
                  ),
                ]),

                const SizedBox(height: 20),

                // Account Security
                _buildSectionTitle('Account Security'),
                _buildCard(children: [
                  _SwitchTile(
                    icon: Icons.security_outlined,
                    iconColor: const Color(0xFF2D8659),
                    label: 'Two-Factor Authentication',
                    subtitle: 'Extra security for your account',
                    value: _twoFactor,
                    onChanged: (v) => setState(() => _twoFactor = v),
                  ),
                  const _Div(),
                  _ActionTile(
                    icon: Icons.lock_outline,
                    iconColor: const Color(0xFF374151),
                    label: 'Change Password',
                    subtitle: 'Update your login password',
                    onTap: () => _showChangePassword(context),
                  ),
                  const _Div(),
                  _ActionTile(
                    icon: Icons.devices_outlined,
                    iconColor: const Color(0xFF6B7280),
                    label: 'Connected Devices',
                    subtitle: 'Manage logged-in sessions',
                    onTap: () {},
                  ),
                ]),

                const SizedBox(height: 20),

                // Data Management
                _buildSectionTitle('Data & Privacy'),
                _buildCard(children: [
                  _ActionTile(
                    icon: Icons.download_outlined,
                    iconColor: const Color(0xFF2D8659),
                    label: 'Export My Data',
                    subtitle: 'Download your orders and earnings history',
                    onTap: () => _showSnack(context, 'Preparing export...'),
                  ),
                  const _Div(),
                  _ActionTile(
                    icon: Icons.cleaning_services_outlined,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Clear Cache',
                    subtitle: 'Free up storage space',
                    onTap: () =>
                        _showSnack(context, 'Cache cleared successfully'),
                  ),
                  const _Div(),
                  _ActionTile(
                    icon: Icons.policy_outlined,
                    iconColor: const Color(0xFF6B7280),
                    label: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    onTap: () {},
                  ),
                ]),

                const SizedBox(height: 20),

                // Danger zone
                _buildSectionTitle('Danger Zone'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.3)),
                    ),
                    child: _ActionTile(
                      icon: Icons.person_off_outlined,
                      iconColor: const Color(0xFFEF4444),
                      label: 'Deactivate Account',
                      subtitle:
                          'Temporarily suspend your merchant account',
                      textColor: const Color(0xFFEF4444),
                      onTap: () => _confirmDeactivate(context),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Center(
                  child: Text(
                    'SaveFood DZ Business v1.0.0',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFFD1D5DB)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(children: children),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF2D8659),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showChangePassword(BuildContext context) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password',
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF6B7280)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D8659)),
            onPressed: () {
              Navigator.pop(ctx);
              _showSnack(context, 'Password updated successfully');
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivate(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Deactivate Account?',
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text(
          'Your listings will be hidden and no new orders will come in. You can reactivate at any time by contacting support.',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF6B7280)))),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Deactivate',
                style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Shared Tiles ──────────────────────────────────────────────────────────────

class _Div extends StatelessWidget {
  const _Div();

  @override
  Widget build(BuildContext context) {
    return const Divider(
        height: 1, thickness: 1, color: Color(0xFFF3F4F6), indent: 16);
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String label;
  final String code;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.code,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: selected
              ? const Color(0xFF2D8659)
              : const Color(0xFF374151),
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle,
              color: Color(0xFF2D8659), size: 20)
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

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151))),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2D8659),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
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

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = textColor ?? const Color(0xFF374151);
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(label,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: c)),
      subtitle: Text(subtitle,
          style:
              const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
      trailing: const Icon(Icons.chevron_right,
          color: Color(0xFF9CA3AF), size: 20),
    );
  }
}
