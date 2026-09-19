import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:anti_food_waste_app/features/profile/domain/models/app_user.dart';

class ConsumerImpactDashboardScreen extends StatelessWidget {
  const ConsumerImpactDashboardScreen({
    super.key,
    required this.user,
  });

  final AppUser user;

  static const Color ink = Color(0xFF0F241A);
  static const Color moss = Color(0xFF2E8B57);
  static const Color mint = Color(0xFF76C893);
  static const Color sand = Color(0xFFF4FBF6);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final impactTrend = [
      user.ordersCount * 0.35 + 1,
      user.ordersCount * 0.45 + 2,
      user.ordersCount * 0.55 + 2.5,
      user.ordersCount * 0.62 + 3,
      user.ordersCount * 0.7 + 3.5,
      user.ordersCount * 0.82 + 4,
    ];

    return Scaffold(
      backgroundColor: sand,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 230,
            backgroundColor: ink,
            surfaceTintColor: ink,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [ink, moss],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -24,
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -40,
                      bottom: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              l10n.impact_dashboard_title.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.consumer_impact_title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l10n.consumer_impact_subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.72),
                                fontSize: 14,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeInUp(
                  duration: const Duration(milliseconds: 360),
                  child: _ConsumerHeroCard(user: user, l10n: l10n),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 70),
                  duration: const Duration(milliseconds: 360),
                  child: _ConsumerSignalsCard(user: user),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 120),
                  duration: const Duration(milliseconds: 360),
                  child: _ConsumerTrendCard(trend: impactTrend),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 160),
                  duration: const Duration(milliseconds: 360),
                  child: _ConsumerInsightsCard(user: user),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 360),
                  child: _ShareCard(
                    l10n: l10n,
                    onShare: () {
                      Share.share(
                        'I saved ${user.mealsSaved} meals, reduced ${user.co2Reduced.toStringAsFixed(1)} kg CO2, and completed ${user.ordersCount} orders with Tawfir.',
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsumerHeroCard extends StatelessWidget {
  const _ConsumerHeroCard({required this.user, required this.l10n});

  final AppUser user;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD8EBDD)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E8B57).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.consumer_impact_glance.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade500,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: user.ecoScore),
                duration: const Duration(milliseconds: 1200),
                builder: (_, value, __) => Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    color: ConsumerImpactDashboardScreen.ink,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FAF3),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD7EEDC)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCF5E4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_florist_rounded, color: ConsumerImpactDashboardScreen.moss, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.consumer_impact_message,
                    style: TextStyle(
                      color: Colors.green.shade900,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  icon: Icons.shopping_bag_rounded,
                  label: 'Orders',
                  value: user.ordersCount.toString(),
                  color: const Color(0xFF1E7A4D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniMetric(
                  icon: Icons.restaurant_rounded,
                  label: 'Meals saved',
                  value: user.mealsSaved.toString(),
                  color: ConsumerImpactDashboardScreen.moss,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniMetric(
                  icon: Icons.savings_rounded,
                  label: 'Money saved',
                  value: '${user.moneySaved.toStringAsFixed(0)} DZD',
                  color: const Color(0xFF1E7A4D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConsumerSignalsCard extends StatelessWidget {
  const _ConsumerSignalsCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final tier = user.ecoTier.isEmpty ? 'active consumer' : user.ecoTier;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD8EBDD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR PROFILE SIGNALS'.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade500,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricPill(
                  icon: Icons.eco_rounded,
                  label: 'Tier',
                  value: tier.toUpperCase(),
                  color: ConsumerImpactDashboardScreen.moss,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricPill(
                  icon: Icons.cloud_done_rounded,
                  label: 'CO2 reduced',
                  value: '${user.co2Reduced.toStringAsFixed(1)} kg',
                  color: const Color(0xFF1E7A4D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricPill(
                  icon: Icons.calendar_month_rounded,
                  label: 'Joined',
                  value: user.joinDate.isEmpty ? 'New member' : user.joinDate,
                  color: const Color(0xFF4CB97A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricPill(
                  icon: Icons.verified_rounded,
                  label: 'Profile',
                  value: 'Consumer',
                  color: const Color(0xFF2E8B57),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConsumerTrendCard extends StatelessWidget {
  const _ConsumerTrendCard({required this.trend});

  final List<double> trend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF123424),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E8B57).withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly consumer trend',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'A visual snapshot of how your food-saving activity is growing.',
            style: TextStyle(color: Colors.white.withOpacity(0.62), fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.06),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                      child: Text(labels[idx], style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 12,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < trend.length; i++)
                        FlSpot(i.toDouble(), trend[i].clamp(0, 12)),
                    ],
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: ConsumerImpactDashboardScreen.mint,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.20),
                          Colors.white.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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
}

class _ConsumerInsightsCard extends StatelessWidget {
  const _ConsumerInsightsCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final checklist = [
      ('You completed ${user.ordersCount} orders', Icons.check_circle_rounded, ConsumerImpactDashboardScreen.mint),
      ('You saved ${user.mealsSaved} meals', Icons.restaurant_rounded, const Color(0xFF1E7A4D)),
      ('You reduced ${user.co2Reduced.toStringAsFixed(1)} kg CO2', Icons.air_rounded, const Color(0xFFF59E0B)),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD8EBDD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consumer highlights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ConsumerImpactDashboardScreen.ink),
          ),
          const SizedBox(height: 14),
          ...checklist.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (item.$3).withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.$2, size: 18, color: item.$3),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.$1,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
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
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.onShare, required this.l10n});

  final VoidCallback onShare;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [ConsumerImpactDashboardScreen.moss, ConsumerImpactDashboardScreen.ink]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Icon(CupertinoIcons.share_up, color: Colors.white, size: 30),
          const SizedBox(height: 12),
          Text(
            l10n.consumer_impact_share_title,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.consumer_impact_share_subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onShare,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: ConsumerImpactDashboardScreen.ink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(l10n.consumer_impact_share_button.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8EBDD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: ConsumerImpactDashboardScreen.ink),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
