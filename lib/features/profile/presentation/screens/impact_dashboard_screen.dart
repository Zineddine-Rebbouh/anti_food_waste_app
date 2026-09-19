import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImpactDashboardScreen extends StatelessWidget {
  const ImpactDashboardScreen({super.key});

  static const Color ink = Color(0xFF081C15);
  static const Color moss = Color(0xFF2D8659);
  static const Color sand = Color(0xFFF7F3EA);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: sand,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
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
                      right: -40,
                      top: -20,
                      child: Container(width: 180, height: 180, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle)),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -50,
                      child: Container(width: 140, height: 140, decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), shape: BoxShape.circle)),
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
                              style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.view_detailed_impact,
                              style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.8),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.activity_overview,
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
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
                  duration: const Duration(milliseconds: 400),
                  child: _HeroImpactCard(
                    totalKg: 1280,
                    meals: 4860,
                    families: 820,
                    co2: 540,
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 80),
                  duration: const Duration(milliseconds: 400),
                  child: _ActivityOverviewCard(l10n: l10n),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 120),
                  duration: const Duration(milliseconds: 400),
                  child: _TrendCard(),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 160),
                  duration: const Duration(milliseconds: 400),
                  child: _ImpactStoryCard(),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 400),
                  child: _ImpactBreakdownCard(),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 240),
                  duration: const Duration(milliseconds: 400),
                  child: _ShareCard(onShare: () {
                    Share.share('We rescued 1280 kg of food and helped 820 families with Tawfir.');
                  }),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImpactCard extends StatelessWidget {
  const _HeroImpactCard({required this.totalKg, required this.meals, required this.families, required this.co2});

  final int totalKg;
  final int meals;
  final int families;
  final int co2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Charity impact at a glance'.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1.6)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: totalKg.toDouble()),
                duration: const Duration(milliseconds: 1400),
                builder: (_, value, __) => Text('${value.toInt()} kg', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: ImpactDashboardScreen.ink, letterSpacing: -1.5)),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('rescued', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey.shade500)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _MiniMetric(icon: Icons.restaurant_rounded, label: 'Meals', value: meals.toString(), color: const Color(0xFF2D8659))),
              const SizedBox(width: 12),
              Expanded(child: _MiniMetric(icon: Icons.groups_rounded, label: 'Families', value: families.toString(), color: const Color(0xFF3B82F6))),
              const SizedBox(width: 12),
              Expanded(child: _MiniMetric(icon: Icons.co2_rounded, label: 'CO2', value: '$co2 kg', color: const Color(0xFFF59E0B))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityOverviewCard extends StatelessWidget {
  const _ActivityOverviewCard({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.activity_overview.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1.6)),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(child: _MetricPill(icon: Icons.task_alt_rounded, label: 'Completed pickups', value: '128')),
              SizedBox(width: 10),
              Expanded(child: _MetricPill(icon: Icons.pending_actions_rounded, label: 'Open requests', value: '19')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(child: _MetricPill(icon: Icons.hourglass_bottom_rounded, label: 'Overdue requests', value: '4')),
              SizedBox(width: 10),
              Expanded(child: _MetricPill(icon: Icons.star_rounded, label: 'Charity rating', value: '4.9')),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2119),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly rescue trend', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('How your collections are moving over time', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 2, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.06), strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24, getTitlesWidget: (value, meta) {
                    const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                    final idx = value.toInt();
                    if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(labels[idx], style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                    );
                  })),
                ),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 2), FlSpot(1, 4), FlSpot(2, 3), FlSpot(3, 6), FlSpot(4, 8), FlSpot(5, 7)],
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 3,
                    dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: ImpactDashboardScreen.moss, strokeWidth: 2, strokeColor: Colors.white)),
                    belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
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

class _ImpactStoryCard extends StatelessWidget {
  const _ImpactStoryCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Charity story'.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1.6)),
          const SizedBox(height: 14),
          const Text(
            'Every pickup becomes a meal, a family connection, and less waste in the city.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ImpactDashboardScreen.ink, height: 1.35),
          ),
          const SizedBox(height: 14),
          Text(
            'This dashboard is designed for charitable operations: collections, response time, social reach, and what still needs attention.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ImpactBreakdownCard extends StatelessWidget {
  const _ImpactBreakdownCard();
  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Food rescued', 0.86, const Color(0xFF2D8659)),
      ('Meals served', 0.72, const Color(0xFF3B82F6)),
      ('Families helped', 0.64, const Color(0xFFF59E0B)),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Impact breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ImpactDashboardScreen.ink)),
          const SizedBox(height: 18),
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ProgressRow(label: row.$1, value: row.$2, color: row.$3),
              )),
        ],
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.onShare});
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [ImpactDashboardScreen.moss, Color(0xFF0D2119)]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Icon(CupertinoIcons.share_up, color: Colors.white, size: 30),
          const SizedBox(height: 12),
          const Text('Share your impact', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Show partners and donors what the charity achieved this month.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 13, height: 1.4)),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onShare,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: ImpactDashboardScreen.ink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('SHARE REPORT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF7F3EA), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: ImpactDashboardScreen.moss),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ImpactDashboardScreen.ink)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1)),
            Text('${(value * 100).round()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(value: value, minHeight: 8, backgroundColor: Colors.grey.shade100, valueColor: AlwaysStoppedAnimation<Color>(color)),
        ),
      ],
    );
  }
}
