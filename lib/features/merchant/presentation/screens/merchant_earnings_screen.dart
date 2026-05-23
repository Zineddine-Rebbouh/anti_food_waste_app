import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_stats.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MerchantEarningsScreen extends StatelessWidget {
  final MerchantProfile profile;

  const MerchantEarningsScreen({super.key, required this.profile});

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color accentBeige = Colors.white;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: accentBeige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryGreen, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.earnings_title.toUpperCase(),
          style: const TextStyle(color: primaryGreen, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildEditorialHeader(l10n),
            const SizedBox(height: 32),
            _buildCommissionCard(l10n),
            const SizedBox(height: 40),
            Text(
              l10n.earnings_summary,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            _PeriodEarningsCard(
              title: l10n.today,
              gross: profile.dailyStats.revenueToday,
              net: profile.dailyStats.netRevenueToday,
              orders: profile.dailyStats.ordersToday,
              isActive: true,
            ),
            const SizedBox(height: 12),
            _PeriodEarningsCard(
              title: l10n.this_week,
              gross: profile.weeklyStats.revenue,
              net: profile.weeklyStats.revenue * 0.88,
              orders: profile.weeklyStats.orders,
            ),
            const SizedBox(height: 12),
            _PeriodEarningsCard(
              title: l10n.this_month,
              gross: profile.monthlyStats.revenue,
              net: profile.monthlyStats.revenue * 0.88,
              orders: profile.monthlyStats.orders,
            ),
            const SizedBox(height: 32),
            Text(
              l10n.payouts_label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              icon: Icons.account_balance_rounded,
              title: l10n.payout_schedule,
              content: l10n.payout_schedule_desc,
              color: primaryGreen,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorialHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.net_earnings_label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              profile.allTimeStats.revenue.toStringAsFixed(0),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: primaryGreen, letterSpacing: -2),
            ),
            const SizedBox(width: 8),
            const Text(
              "DZD",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: primaryGreen),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
          child: Text(
            l10n.all_time_revenue_label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryGreen, letterSpacing: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.commission_rate.toUpperCase(),
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
              const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "88%",
                style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -3),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 12),
                child: Text(
                  l10n.of_sales_are_yours,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.88,
              child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100))),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodEarningsCard extends StatelessWidget {
  final String title;
  final double gross;
  final double net;
  final int orders;
  final bool isActive;

  const _PeriodEarningsCard({
    required this.title,
    required this.gross,
    required this.net,
    required this.orders,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const primaryGreen = Color(0xFF2D8659);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isActive ? Border.all(color: primaryGreen, width: 2) : Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Text(
                  '${net.toStringAsFixed(0)} DZD',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.net_revenue.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: primaryGreen.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text(
                  '$orders',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: primaryGreen),
                ),
                Text(
                  l10n.orders_label.toUpperCase(),
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: primaryGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade50),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



