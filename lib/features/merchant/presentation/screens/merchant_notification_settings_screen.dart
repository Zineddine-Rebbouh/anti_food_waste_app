import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MerchantNotificationSettingsScreen extends StatefulWidget {
  const MerchantNotificationSettingsScreen({super.key});

  @override
  State<MerchantNotificationSettingsScreen> createState() =>
      _MerchantNotificationSettingsScreenState();
}

class _MerchantNotificationSettingsScreenState
    extends State<MerchantNotificationSettingsScreen> {
  // Order Alerts
  bool _newOrders = true;
  bool _urgentPickup = true;
  bool _cancellations = true;
  bool _donationRequests = true;

  // Business Updates
  bool _trustScoreChanges = true;
  bool _weeklySummary = true;
  bool _payoutAlerts = true;

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color backgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, l10n),
            const SizedBox(height: 24),
            
            _buildSectionHeader(l10n.order_alerts_label),
            _buildSectionCard([
              _ToggleTile(
                icon: Icons.add_shopping_cart_outlined,
                iconColor: primaryGreen,
                label: l10n.new_orders,
                subtitle: l10n.new_orders_desc,
                value: _newOrders,
                onChanged: (v) => setState(() => _newOrders = v),
              ),
              _ToggleTile(
                icon: Icons.timer_outlined,
                iconColor: const Color(0xFFEF4444),
                label: l10n.urgent_pickup_alerts,
                subtitle: l10n.urgent_pickup_desc,
                value: _urgentPickup,
                onChanged: (v) => setState(() => _urgentPickup = v),
              ),
              _ToggleTile(
                icon: Icons.cancel_outlined,
                iconColor: const Color(0xFFF59E0B),
                label: l10n.cancellations,
                subtitle: l10n.cancellations_desc,
                value: _cancellations,
                onChanged: (v) => setState(() => _cancellations = v),
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionHeader(l10n.business_updates_label),
            _buildSectionCard([
              _ToggleTile(
                icon: Icons.verified_outlined,
                iconColor: primaryGreen,
                label: l10n.trust_score_changes,
                subtitle: l10n.trust_score_changes_desc,
                value: _trustScoreChanges,
                onChanged: (v) => setState(() => _trustScoreChanges = v),
              ),
              _ToggleTile(
                icon: Icons.payments_outlined,
                iconColor: const Color(0xFF6366F1),
                label: l10n.payout_alerts,
                subtitle: l10n.payout_alerts_desc,
                value: _payoutAlerts,
                onChanged: (v) => setState(() => _payoutAlerts = v),
              ),
              _ToggleTile(
                icon: Icons.bar_chart_outlined,
                iconColor: const Color(0xFF2D8659),
                label: l10n.weekly_summary,
                subtitle: l10n.weekly_summary_desc,
                value: _weeklySummary,
                onChanged: (v) => setState(() => _weeklySummary = v),
              ),
            ]),

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
                      l10n.notifications_title,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      l10n.notifications_subtitle,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15),
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
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Color(0xFF374151)),
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
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({required this.icon, required this.iconColor, required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 20)),
      title: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Switch.adaptive(value: value, onChanged: onChanged, activeColor: const Color(0xFF2D8659)),
    );
  }
}



