import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_stats.dart';

class MerchantEarningsScreen extends StatelessWidget {
  final MerchantProfile profile;

  const MerchantEarningsScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Earnings & Payouts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Commission info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D8659), Color(0xFF1A5E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Commission Rate',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Text(
                        '88%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'goes to you',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CommissionDetail(
                          label: 'You Keep', value: '88%', highlight: true),
                      _CommissionDetail(
                          label: 'Platform Fee', value: '12%'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payout info
            _InfoCard(
              icon: Icons.account_balance_outlined,
              title: 'Payout Schedule',
              content:
                  'Earnings are transferred to your bank account the next business day after each completed order.',
              color: const Color(0xFF3B82F6),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.security_outlined,
              title: 'Secure Payments',
              content:
                  'All online payments are processed securely. Cash on pickup orders are confirmed by you after receiving cash.',
              color: const Color(0xFF2D8659),
            ),
            const SizedBox(height: 24),

            // Period stats
            const Text(
              'Earnings Summary',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            _PeriodEarningsCard(
              title: 'Today',
              gross: profile.dailyStats.revenueToday,
              net: profile.dailyStats.netRevenueToday,
              orders: profile.dailyStats.ordersToday,
            ),
            const SizedBox(height: 10),
            _PeriodEarningsCard(
              title: 'This Week',
              gross: profile.weeklyStats.revenue,
              net: profile.weeklyStats.revenue * 0.88,
              orders: profile.weeklyStats.orders,
            ),
            const SizedBox(height: 10),
            _PeriodEarningsCard(
              title: 'This Month',
              gross: profile.monthlyStats.revenue,
              net: profile.monthlyStats.revenue * 0.88,
              orders: profile.monthlyStats.orders,
            ),
            const SizedBox(height: 10),
            _PeriodEarningsCard(
              title: 'All Time',
              gross: profile.allTimeStats.revenue,
              net: profile.allTimeStats.revenue * 0.88,
              orders: profile.allTimeStats.orders,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CommissionDetail extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _CommissionDetail({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: highlight ? Colors.white70 : Colors.white54,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? Colors.white : Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
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

  const _PeriodEarningsCard({
    required this.title,
    required this.gross,
    required this.net,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${net.toStringAsFixed(0)} DZD',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
                Text(
                  'net (${gross.toStringAsFixed(0)} DZD gross)',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$orders',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
              const Text(
                'orders',
                style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
