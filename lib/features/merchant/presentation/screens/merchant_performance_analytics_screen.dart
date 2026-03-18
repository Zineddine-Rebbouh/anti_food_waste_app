import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_stats.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';

class MerchantPerformanceAnalyticsScreen extends StatefulWidget {
  const MerchantPerformanceAnalyticsScreen({super.key});

  @override
  State<MerchantPerformanceAnalyticsScreen> createState() =>
      _MerchantPerformanceAnalyticsScreenState();
}

class _MerchantPerformanceAnalyticsScreenState
    extends State<MerchantPerformanceAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MerchantCubit, MerchantState>(
      builder: (context, state) {
        if (state is MerchantLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (state is MerchantError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<MerchantCubit>().load(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state is! MerchantLoaded) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final profile = state.profile;
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
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
                          children: [
                            const Text(
                              'Performance Analytics',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${profile.businessName} · ${profile.wilaya}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Today'),
                    Tab(text: 'Week'),
                    Tab(text: 'Month'),
                    Tab(text: 'All Time'),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _DayAnalyticsTab(profile: profile),
                    _PeriodAnalyticsTab(
                        stats: profile.weeklyStats, label: 'This Week'),
                    _PeriodAnalyticsTab(
                        stats: profile.monthlyStats, label: 'This Month'),
                    _PeriodAnalyticsTab(
                        stats: profile.allTimeStats, label: 'All Time'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Today Tab ─────────────────────────────────────────────────────────────────

class _DayAnalyticsTab extends StatelessWidget {
  final MerchantProfile profile;
  const _DayAnalyticsTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final d = profile.dailyStats;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 4),
        // KPI row
        Row(
          children: [
            Expanded(
                child: _KpiCard(
              icon: Icons.receipt_long_outlined,
              iconColor: const Color(0xFF2D8659),
              label: 'Orders Today',
              value: '${d.ordersToday}',
              badge: d.ordersDelta > 0
                  ? '+${d.ordersDelta} vs yesterday'
                  : null,
              badgeColor: const Color(0xFF10B981),
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _KpiCard(
              icon: Icons.payments_outlined,
              iconColor: const Color(0xFF6366F1),
              label: 'Net Revenue',
              value: '${d.netRevenueToday.toStringAsFixed(0)} DZD',
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _KpiCard(
              icon: Icons.eco_outlined,
              iconColor: const Color(0xFF10B981),
              label: 'Food Saved',
              value: '${d.foodSavedKgToday} kg',
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _KpiCard(
              icon: Icons.cloud_outlined,
              iconColor: const Color(0xFF06B6D4),
              label: 'CO² Avoided',
              value: '${d.co2AvoidedKgToday} kg',
            )),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle('Hourly Activity'),
        const SizedBox(height: 12),
        _BarChart(
          bars: const [
            _Bar(label: '8am', value: 0.1),
            _Bar(label: '9am', value: 0.2),
            _Bar(label: '10am', value: 0.15),
            _Bar(label: '12pm', value: 0.35),
            _Bar(label: '2pm', value: 0.55),
            _Bar(label: '4pm', value: 0.8),
            _Bar(label: '6pm', value: 1.0),
            _Bar(label: '8pm', value: 0.65),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle('Revenue Breakdown'),
        const SizedBox(height: 12),
        _BreakdownCard(
          rows: [
            _BreakdownRow(
              label: 'Gross Revenue',
              value: '${d.revenueToday.toStringAsFixed(0)} DZD',
              bold: false,
            ),
            _BreakdownRow(
              label: 'Platform Commission (12%)',
              value:
                  '- ${(d.revenueToday * 0.12).toStringAsFixed(0)} DZD',
              valueColor: const Color(0xFFEF4444),
              bold: false,
            ),
            _BreakdownRow(
              label: 'Your Net Earnings',
              value: '${d.netRevenueToday.toStringAsFixed(0)} DZD',
              valueColor: const Color(0xFF2D8659),
              bold: true,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle('Conversion'),
        const SizedBox(height: 12),
        _ConversionCard(
          views: 145,
          reservations: d.ordersToday,
          completedOrders: d.ordersToday,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Period Tab (Week / Month / All Time) ──────────────────────────────────────

class _PeriodAnalyticsTab extends StatelessWidget {
  final MerchantPeriodStats stats;
  final String label;
  const _PeriodAnalyticsTab(
      {required this.stats, required this.label});

  @override
  Widget build(BuildContext context) {
    final grossRevenue = stats.revenue;
    final netRevenue = grossRevenue * 0.88;
    final avgOrderValue =
        stats.orders > 0 ? grossRevenue / stats.orders : 0.0;
    final co2Avoided = stats.foodSavedKg * 4;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 4),
        // Header label
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2D8659).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2D8659),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // KPI cards
        Row(
          children: [
            Expanded(
                child: _KpiCard(
              icon: Icons.receipt_long_outlined,
              iconColor: const Color(0xFF2D8659),
              label: 'Total Orders',
              value: '${stats.orders}',
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _KpiCard(
              icon: Icons.payments_outlined,
              iconColor: const Color(0xFF6366F1),
              label: 'Net Revenue',
              value: '${netRevenue.toStringAsFixed(0)} DZD',
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _KpiCard(
              icon: Icons.eco_outlined,
              iconColor: const Color(0xFF10B981),
              label: 'Food Saved',
              value: '${stats.foodSavedKg.toStringAsFixed(1)} kg',
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _KpiCard(
              icon: Icons.show_chart,
              iconColor: const Color(0xFFF59E0B),
              label: 'Avg. Order',
              value: '${avgOrderValue.toStringAsFixed(0)} DZD',
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _KpiCard(
              icon: Icons.cloud_outlined,
              iconColor: const Color(0xFF06B6D4),
              label: 'CO² Avoided',
              value: '${co2Avoided.toStringAsFixed(1)} kg',
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _KpiCard(
              icon: Icons.restaurant_outlined,
              iconColor: const Color(0xFFEC4899),
              label: 'Meals Rescued',
              value: '~${(stats.foodSavedKg / 0.4).round()}',
            )),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle('Revenue Breakdown'),
        const SizedBox(height: 12),
        _BreakdownCard(
          rows: [
            _BreakdownRow(
              label: 'Gross Revenue',
              value: '${grossRevenue.toStringAsFixed(0)} DZD',
              bold: false,
            ),
            _BreakdownRow(
              label: 'Platform Commission (12%)',
              value:
                  '- ${(grossRevenue * 0.12).toStringAsFixed(0)} DZD',
              valueColor: const Color(0xFFEF4444),
              bold: false,
            ),
            _BreakdownRow(
              label: 'Your Net Earnings',
              value: '${netRevenue.toStringAsFixed(0)} DZD',
              valueColor: const Color(0xFF2D8659),
              bold: true,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle('Top Performing Days'),
        const SizedBox(height: 12),
        _BarChart(
          bars: const [
            _Bar(label: 'Mon', value: 0.4),
            _Bar(label: 'Tue', value: 0.65),
            _Bar(label: 'Wed', value: 0.5),
            _Bar(label: 'Thu', value: 0.85),
            _Bar(label: 'Fri', value: 1.0),
            _Bar(label: 'Sat', value: 0.9),
            _Bar(label: 'Sun', value: 0.3),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? badge;
  final Color? badgeColor;

  const _KpiCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.badge,
    this.badgeColor,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9CA3AF))),
          if (badge != null) ...[
            const SizedBox(height: 4),
            Text(
              badge!,
              style: TextStyle(
                  fontSize: 10,
                  color: badgeColor ?? const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bar {
  final String label;
  final double value; // 0.0 – 1.0
  const _Bar({required this.label, required this.value});
}

class _BarChart extends StatelessWidget {
  final List<_Bar> bars;
  const _BarChart({required this.bars});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: SizedBox(
        height: 110,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: bars.map((b) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 24,
                      height: 72 * b.value,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            const Color(0xFF2D8659),
                            const Color(0xFF2D8659).withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(b.label,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF9CA3AF))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _BreakdownRow {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  const _BreakdownRow(
      {required this.label,
      required this.value,
      this.valueColor,
      required this.bold});
}

class _BreakdownCard extends StatelessWidget {
  final List<_BreakdownRow> rows;
  const _BreakdownCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return Column(
            children: [
              if (i > 0)
                const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF3F4F6),
                    indent: 16),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: row.bold
                            ? const Color(0xFF111827)
                            : const Color(0xFF6B7280),
                        fontWeight: row.bold
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    Text(
                      row.value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: row.bold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: row.valueColor ??
                            const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ConversionCard extends StatelessWidget {
  final int views;
  final int reservations;
  final int completedOrders;
  const _ConversionCard(
      {required this.views,
      required this.reservations,
      required this.completedOrders});

  @override
  Widget build(BuildContext context) {
    final reservationRate =
        views > 0 ? (reservations / views * 100).toStringAsFixed(1) : '0';
    final completionRate = reservations > 0
        ? (completedOrders / reservations * 100).toStringAsFixed(1)
        : '0';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ConversionStep(
              label: 'Listing Views',
              value: '$views',
              iconColor: const Color(0xFF6366F1)),
          _Arrow(),
          _ConversionStep(
              label: 'Reserved',
              value: '$reservations',
              sub: '$reservationRate%',
              iconColor: const Color(0xFFF59E0B)),
          _Arrow(),
          _ConversionStep(
              label: 'Completed',
              value: '$completedOrders',
              sub: '$completionRate%',
              iconColor: const Color(0xFF10B981)),
        ],
      ),
    );
  }
}

class _ConversionStep extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final Color iconColor;

  const _ConversionStep(
      {required this.label,
      required this.value,
      this.sub,
      required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: iconColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF6B7280))),
        if (sub != null)
          Text(sub!,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.arrow_forward,
        size: 16, color: Color(0xFFD1D5DB));
  }
}
