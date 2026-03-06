import 'package:flutter/material.dart';

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
  bool _monthlyReport = false;
  bool _payoutAlerts = true;

  // Marketing
  bool _tipsAndFeatures = false;
  bool _promotionalOffers = false;

  // Delivery
  bool _pushNotifications = true;
  bool _smsAlerts = false;
  bool _emailAlerts = true;

  @override
  Widget build(BuildContext context) {
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
                          'Notification Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Manage your alerts and preferences',
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
                // Delivery method section
                _SectionHeader(
                  icon: Icons.send_outlined,
                  title: 'Delivery Method',
                  subtitle: 'How you receive notifications',
                ),
                _ToggleCard(children: [
                  _ToggleTile(
                    icon: Icons.notifications_outlined,
                    iconColor: const Color(0xFF2D8659),
                    label: 'Push Notifications',
                    subtitle: 'On-device alerts',
                    value: _pushNotifications,
                    onChanged: (v) =>
                        setState(() => _pushNotifications = v),
                  ),
                  const _TileDivider(),
                  _ToggleTile(
                    icon: Icons.sms_outlined,
                    iconColor: const Color(0xFF6366F1),
                    label: 'SMS Alerts',
                    subtitle: 'Text messages to your phone',
                    value: _smsAlerts,
                    onChanged: (v) => setState(() => _smsAlerts = v),
                  ),
                  const _TileDivider(),
                  _ToggleTile(
                    icon: Icons.email_outlined,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Email Notifications',
                    subtitle: 'Sent to your registered email',
                    value: _emailAlerts,
                    onChanged: (v) => setState(() => _emailAlerts = v),
                  ),
                ]),
                const SizedBox(height: 20),
                _SectionHeader(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order Alerts',
                  subtitle: 'Stay on top of your orders',
                ),
                _ToggleCard(children: [
                  _ToggleTile(
                    icon: Icons.add_shopping_cart_outlined,
                    iconColor: const Color(0xFF2D8659),
                    label: 'New Orders',
                    subtitle: 'Get notified for every new reservation',
                    value: _newOrders,
                    onChanged: (v) => setState(() => _newOrders = v),
                  ),
                  const _TileDivider(),
                  _ToggleTile(
                    icon: Icons.timer_outlined,
                    iconColor: const Color(0xFFEF4444),
                    label: 'Urgent Pickup Alerts',
                    subtitle: 'Orders due within 10 minutes',
                    value: _urgentPickup,
                    onChanged: (v) => setState(() => _urgentPickup = v),
                  ),
                  const _TileDivider(),
                  _ToggleTile(
                    icon: Icons.cancel_outlined,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Cancellations',
                    subtitle: 'When a customer cancels an order',
                    value: _cancellations,
                    onChanged: (v) =>
                        setState(() => _cancellations = v),
                  ),
                  const _TileDivider(),
                  _ToggleTile(
                    icon: Icons.volunteer_activism_outlined,
                    iconColor: const Color(0xFF10B981),
                    label: 'Donation Requests',
                    subtitle: 'New charity pickup requests',
                    value: _donationRequests,
                    onChanged: (v) =>
                        setState(() => _donationRequests = v),
                  ),
                ]),
                const SizedBox(height: 20),
                _SectionHeader(
                  icon: Icons.business_center_outlined,
                  title: 'Business Updates',
                  subtitle: 'Your store performance & payouts',
                ),
                _ToggleCard(children: [
                  _ToggleTile(
                    icon: Icons.verified_outlined,
                    iconColor: const Color(0xFF2D8659),
                    label: 'Trust Score Changes',
                    subtitle: 'Changes to your merchant rating',
                    value: _trustScoreChanges,
                    onChanged: (v) =>
                        setState(() => _trustScoreChanges = v),
                  ),
                  const _TileDivider(),
                  _ToggleTile(
                    icon: Icons.payments_outlined,
                    iconColor: const Color(0xFF6366F1),
                    label: 'Payout Alerts',
                    subtitle: 'When earnings are transferred',
                    value: _payoutAlerts,
                    onChanged: (v) =>
                        setState(() => _payoutAlerts = v),
                  ),
                  const _TileDivider(),
                  _ToggleTile(
                    icon: Icons.bar_chart_outlined,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Weekly Summary',
                    subtitle: 'Your performance digest each week',
                    value: _weeklySummary,
                    onChanged: (v) =>
                        setState(() => _weeklySummary = v),
                  ),
                  const _TileDivider(),
                  _ToggleTile(
                    icon: Icons.calendar_month_outlined,
                    iconColor: const Color(0xFF06B6D4),
                    label: 'Monthly Report',
                    subtitle: 'Detailed monthly earnings report',
                    value: _monthlyReport,
                    onChanged: (v) =>
                        setState(() => _monthlyReport = v),
                  ),
                ]),
                const SizedBox(height: 20),
                _SectionHeader(
                  icon: Icons.campaign_outlined,
                  title: 'Tips & Promotions',
                  subtitle: 'Feature updates and merchant tips',
                ),
                _ToggleCard(children: [
                  _ToggleTile(
                    icon: Icons.lightbulb_outline,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Tips & Features',
                    subtitle: 'How to improve your listings',
                    value: _tipsAndFeatures,
                    onChanged: (v) =>
                        setState(() => _tipsAndFeatures = v),
                  ),
                  const _TileDivider(),
                  _ToggleTile(
                    icon: Icons.local_offer_outlined,
                    iconColor: const Color(0xFFEC4899),
                    label: 'Promotional Offers',
                    subtitle: 'Special deals for merchants',
                    value: _promotionalOffers,
                    onChanged: (v) =>
                        setState(() => _promotionalOffers = v),
                  ),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Components ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SectionHeader(
      {required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF2D8659).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2D8659), size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final List<Widget> children;
  const _ToggleCard({required this.children});

  @override
  Widget build(BuildContext context) {
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
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
        height: 1, thickness: 1, color: Color(0xFFF3F4F6), indent: 16);
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
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
