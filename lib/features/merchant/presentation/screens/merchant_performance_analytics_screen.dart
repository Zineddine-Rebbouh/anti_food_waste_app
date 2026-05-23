import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_stats.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/utils/l10n_utils.dart';

class MerchantPerformanceAnalyticsScreen extends StatefulWidget {
  const MerchantPerformanceAnalyticsScreen({super.key});

  @override
  State<MerchantPerformanceAnalyticsScreen> createState() =>
      _MerchantPerformanceAnalyticsScreenState();
}

class _MerchantPerformanceAnalyticsScreenState
    extends State<MerchantPerformanceAnalyticsScreen> {
  int _selectedIndex = 0;

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color accentBeige = Colors.white;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<MerchantCubit, MerchantState>(
      builder: (context, state) {
        if (state is MerchantLoading) {
          return const Scaffold(
            backgroundColor: accentBeige,
            body: Center(child: CircularProgressIndicator(color: primaryGreen)),
          );
        }
        if (state is MerchantError) {
          return Scaffold(
            backgroundColor: accentBeige,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      L10nUtils.translateError(state.message, l10n),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context.read<MerchantCubit>().load(),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state is! MerchantLoaded) {
          return const Scaffold(
            backgroundColor: accentBeige,
            body: Center(child: CircularProgressIndicator(color: primaryGreen)),
          );
        }
        final profile = state.profile;
        
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
              l10n.performance_analytics_title.toUpperCase(),
              style: const TextStyle(color: primaryGreen, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildSegmentedControl(l10n),
                const SizedBox(height: 32),
                _buildSelectedContent(profile, l10n),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSegmentedControl(AppLocalizations l10n) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          _buildSegmentItem(0, l10n.today),
          _buildSegmentItem(1, l10n.week_short),
          _buildSegmentItem(2, l10n.month_short),
          _buildSegmentItem(3, l10n.all_short),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(int index, String label) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade400,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedContent(MerchantProfile profile, AppLocalizations l10n) {
    switch (_selectedIndex) {
      case 0:
        return _DayAnalyticsTab(profile: profile);
      case 1:
        return _PeriodAnalyticsTab(stats: profile.weeklyStats, label: l10n.this_week_analytics);
      case 2:
        return _PeriodAnalyticsTab(stats: profile.monthlyStats, label: l10n.this_month_analytics);
      case 3:
        return _PeriodAnalyticsTab(stats: profile.allTimeStats, label: l10n.all_time_analytics);
      default:
        return _DayAnalyticsTab(profile: profile);
    }
  }
}

class _DayAnalyticsTab extends StatelessWidget {
  final MerchantProfile profile;
  const _DayAnalyticsTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final d = profile.dailyStats;
    final l10n = AppLocalizations.of(context)!;
    const primaryGreen = Color(0xFF2D8659);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.shopping_bag_rounded,
                iconColor: primaryGreen,
                label: l10n.orders_today,
                value: '${d.ordersToday}',
                delta: d.ordersDelta > 0 ? '+${d.ordersDelta}' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _KpiCard(
                icon: Icons.account_balance_wallet_rounded,
                iconColor: const Color(0xFF3B82F6),
                label: l10n.net_revenue,
                value: '${d.netRevenueToday.toInt()} DZD',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.eco_rounded,
                iconColor: const Color(0xFF2D8659),
                label: l10n.food_saved_label,
                value: '${d.foodSavedKgToday.toInt()} kg',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _KpiCard(
                icon: Icons.cloud_done_rounded,
                iconColor: const Color(0xFF06B6D4),
                label: l10n.co2_avoided,
                value: '${d.co2AvoidedKgToday.toInt()} kg',
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          l10n.activity_peaks,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5),
        ),
        const SizedBox(height: 20),
        _BarChart(
          bars: [
            _Bar(label: l10n.chart_8am, value: 0.2),
            _Bar(label: l10n.chart_12pm, value: 0.5),
            _Bar(label: l10n.chart_4pm, value: 0.8),
            _Bar(label: l10n.chart_8pm, value: 1.0),
            _Bar(label: l10n.chart_10pm, value: 0.4),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          l10n.daily_breakdown,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5),
        ),
        const SizedBox(height: 20),
        _BreakdownCard(
          rows: [
            _BreakdownRow(label: l10n.gross_sales, value: '${d.revenueToday.toInt()} DZD'),
            _BreakdownRow(label: l10n.platform_fee_label, value: '- ${(d.revenueToday * 0.12).toInt()} DZD', isNegative: true),
            _BreakdownRow(label: l10n.net_earnings_label, value: '${d.netRevenueToday.toInt()} DZD', isMain: true),
          ],
        ),
      ],
    );
  }
}

class _PeriodAnalyticsTab extends StatelessWidget {
  final MerchantPeriodStats stats;
  final String label;
  const _PeriodAnalyticsTab({required this.stats, required this.label});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const primaryGreen = Color(0xFF2D8659);
    final netRevenue = stats.revenue * 0.88;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.receipt_rounded,
                iconColor: primaryGreen,
                label: l10n.total_orders_label,
                value: '${stats.orders}',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _KpiCard(
                icon: Icons.payments_rounded,
                iconColor: const Color(0xFF3B82F6),
                label: l10n.net_revenue,
                value: '${netRevenue.toInt()} DZD',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.eco_rounded,
                iconColor: const Color(0xFF2D8659),
                label: l10n.food_saved_label,
                value: '${stats.foodSavedKg.toInt()} kg',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _KpiCard(
                icon: Icons.restaurant_rounded,
                iconColor: const Color(0xFFF59E0B),
                label: l10n.meals_rescued_label,
                value: '~${(stats.foodSavedKg / 0.4).round()}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          l10n.performance_trend,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5),
        ),
        const SizedBox(height: 20),
        _BarChart(
          bars: [
            _Bar(label: l10n.chart_mon, value: 0.4),
            _Bar(label: l10n.chart_wed, value: 0.7),
            _Bar(label: l10n.chart_fri, value: 0.9),
            _Bar(label: l10n.chart_sat, value: 1.0),
            _Bar(label: l10n.chart_sun, value: 0.3),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          l10n.revenue_breakdown,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5),
        ),
        const SizedBox(height: 20),
        _BreakdownCard(
          rows: [
            _BreakdownRow(label: l10n.gross_revenue, value: '${stats.revenue.toInt()} DZD'),
            _BreakdownRow(label: l10n.platform_fee_label, value: '- ${(stats.revenue * 0.12).toInt()} DZD', isNegative: true),
            _BreakdownRow(label: l10n.net_earnings_label, value: '${netRevenue.toInt()} DZD', isMain: true),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? delta;

  const _KpiCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              if (delta != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(100)),
                  child: Text(delta!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF16A34A))),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _Bar {
  final String label;
  final double value;
  const _Bar({required this.label, required this.value});
}

class _BarChart extends StatelessWidget {
  final List<_Bar> bars;
  const _BarChart({required this.bars});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2D8659);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: SizedBox(
        height: 160,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: bars.map((b) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    width: 32,
                    decoration: BoxDecoration(
                      color: b.value == 1.0 ? primaryGreen : primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: b.value,
                      child: Container(
                        width: 32,
                        decoration: BoxDecoration(
                          color: b.value == 1.0 ? primaryGreen : primaryGreen.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  b.label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade400),
                ),
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
  final bool isNegative;
  final bool isMain;
  _BreakdownRow({required this.label, required this.value, this.isNegative = false, this.isMain = false});
}

class _BreakdownCard extends StatelessWidget {
  final List<_BreakdownRow> rows;
  const _BreakdownCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final i = e.key;
          final r = e.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: r.isMain ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: i == 0 || r.isMain ? null : Border(top: BorderSide(color: Colors.grey.shade50)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  r.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: r.isMain ? FontWeight.w800 : FontWeight.w600,
                    color: r.isMain ? const Color(0xFF2D8659) : const Color(0xFF374151),
                  ),
                ),
                Text(
                  r.value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: r.isMain ? FontWeight.w900 : FontWeight.w700,
                    color: r.isNegative ? const Color(0xFFEF4444) : (r.isMain ? const Color(0xFF2D8659) : const Color(0xFF111827)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}



