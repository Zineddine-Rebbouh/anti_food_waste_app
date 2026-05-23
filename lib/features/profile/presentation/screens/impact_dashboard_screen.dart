import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Data models (private to this file)
// ---------------------------------------------------------------------------

class _BadgeData {
  final String emoji;
  final String name;
  final bool earned;

  const _BadgeData({
    required this.emoji,
    required this.name,
    required this.earned,
  });
}

class _BreakdownItem {
  final IconData icon;
  final String label;
  final double percent;
  final Color color;

  const _BreakdownItem({
    required this.icon,
    required this.label,
    required this.percent,
    required this.color,
  });
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ImpactDashboardScreen extends StatefulWidget {
  const ImpactDashboardScreen({super.key});

  @override
  State<ImpactDashboardScreen> createState() => _ImpactDashboardScreenState();
}

class _ImpactDashboardScreenState extends State<ImpactDashboardScreen> {
  static const Color forestGreen = AppTheme.primary;
  static const Color accentBeige = Colors.white;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: accentBeige,
      body: Column(
        children: [
          _buildHeader(context, l10n),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(l10n),
                  const SizedBox(height: 32),
                  _buildBadgesSection(l10n),
                  const SizedBox(height: 32),
                  _buildMonthlyChart(l10n),
                  const SizedBox(height: 32),
                  _buildImpactBreakdown(l10n),
                  const SizedBox(height: 32),
                  _buildLeaderboard(l10n),
                  const SizedBox(height: 32),
                  _buildShareCard(l10n),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: forestGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 24, 32),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.impact_dashboard_title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Section 1: Hero Stats Card
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildHeroCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: forestGreen,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: forestGreen.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.total_food_rescued.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 32),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) {
              return Text(
                '${value.toInt()} kg',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -2,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.star_fill, color: Color(0xFFD4AF37), size: 14),
                const SizedBox(width: 8),
                Text(
                  'Silver Level  •  Eco-Score 85',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildMiniStat('14.4 kg', l10n.co2_avoided),
              _buildMiniStatDivider(),
              _buildMiniStat('2 🌳', 'Trees Saved'),
              _buildMiniStatDivider(),
              _buildMiniStat('4,800', 'DZD Saved'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withOpacity(0.2),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Section 2: Achievements / Badges
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildBadgesSection(AppLocalizations l10n) {
    final badges = [
      const _BadgeData(emoji: '🌱', name: 'Eco Starter', earned: true),
      const _BadgeData(emoji: '🌿', name: 'Food Saver', earned: true),
      const _BadgeData(emoji: '🍃', name: 'Green Hero', earned: true),
      const _BadgeData(emoji: '♻️', name: 'CO₂ Fighter', earned: false),
      const _BadgeData(emoji: '🏆', name: 'Champion', earned: false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionTitle(l10n.your_badges),
            TextButton(
              onPressed: () {},
              child: const Text('SEE ALL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: forestGreen, letterSpacing: 1)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal scrollable badges
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: badges
                .map((badge) => _buildBadgeItem(badge))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(_BadgeData badge) {
    return SizedBox(
      width: 84,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Circle background
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: badge.earned ? forestGreen.withOpacity(0.05) : Colors.grey[50],
                    border: Border.all(
                      color: badge.earned ? forestGreen.withOpacity(0.1) : Colors.grey[100]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      badge.emoji,
                      style: TextStyle(fontSize: 28, color: badge.earned ? null : Colors.grey[300]),
                    ),
                  ),
                ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          badge.name.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: badge.earned ? const Color(0xFF1A1A2E) : Colors.grey[300],
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Section 3: Monthly Activity Chart
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildMonthlyChart(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.monthly_activity),
        const SizedBox(height: 16),
        _EditorialCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: forestGreen, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Text(
                    l10n.food_rescues_label.toUpperCase(),
                    style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Chart
              SizedBox(
                height: 160,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 2,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade100,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26,
                          getTitlesWidget: (value, meta) {
                            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                            final idx = value.toInt();
                            if (idx < 0 || idx >= months.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                months[idx],
                                style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w500),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: 2,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10, color: Colors.black38),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 5,
                    minY: 0,
                    maxY: 10,
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 2),
                          FlSpot(1, 4),
                          FlSpot(2, 3),
                          FlSpot(3, 6),
                          FlSpot(4, 8),
                          FlSpot(5, 5),
                        ],
                        isCurved: true,
                        color: AppTheme.primary,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: AppTheme.primary,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary.withOpacity(0.18),
                              AppTheme.primary.withOpacity(0.0),
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
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Section 4: Impact Breakdown
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildImpactBreakdown(AppLocalizations l10n) {
    final items = [
      _BreakdownItem(
        icon: Icons.eco_rounded,
        label: l10n.environmental_impact,
        percent: 0.85,
        color: forestGreen,
      ),
      _BreakdownItem(
        icon: Icons.attach_money_rounded,
        label: l10n.economic_impact,
        percent: 0.70,
        color: const Color(0xFF2D6A4F),
      ),
      _BreakdownItem(
        icon: Icons.people_alt_rounded,
        label: l10n.social_impact,
        percent: 0.60,
        color: const Color(0xFF40916C),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.impact_breakdown),
        const SizedBox(height: 16),
        _EditorialCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  _buildBreakdownRow(item),
                  if (index != items.length - 1) ...[
                    const SizedBox(height: 24),
                    Divider(color: Colors.grey[50], height: 1),
                    const SizedBox(height: 24),
                  ],
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(_BreakdownItem item) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(item.icon, color: item.color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1A2E).withOpacity(0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: item.percent),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) {
                      return Text(
                        '${(value * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: item.color,
                          letterSpacing: -0.5,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: item.percent),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey[50],
                      valueColor: AlwaysStoppedAnimation<Color>(item.color),
                      minHeight: 6,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Section 5: Leaderboard Preview
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildLeaderboard(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.community_leaderboard),
        const SizedBox(height: 16),
        _EditorialCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildLeaderboardRow(rank: '01', name: 'Ahmed B.', rescues: 78, isYou: false),
              const SizedBox(height: 12),
              _buildLeaderboardRow(rank: '02', name: 'Fatima Z.', rescues: 65, isYou: false),
              const SizedBox(height: 12),
              _buildLeaderboardRow(rank: '03', name: 'Karim M.', rescues: 54, isYou: false),
              const SizedBox(height: 20),
              Divider(color: Colors.grey[50], height: 1),
              const SizedBox(height: 20),
              _buildLeaderboardRow(rank: '12', name: 'You', rescues: 32, isYou: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow({required String rank, required String name, required int rescues, required bool isYou}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isYou ? forestGreen.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isYou ? forestGreen.withOpacity(0.1) : Colors.transparent),
      ),
      child: Row(
        children: [
          Text(rank, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isYou ? forestGreen : Colors.grey[300], letterSpacing: -0.5)),
          const SizedBox(width: 20),
          Expanded(child: Text(name, style: TextStyle(fontSize: 15, fontWeight: isYou ? FontWeight.w900 : FontWeight.w700, color: const Color(0xFF1A1A2E)))),
          Text('$rescues kg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isYou ? forestGreen : Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildShareCard(AppLocalizations l10n) {
    return _EditorialCard(
      color: forestGreen,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(CupertinoIcons.share_up, color: Colors.white, size: 32),
          const SizedBox(height: 20),
          Text(
            'Share Your Impact'.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Inspire others to rescue food and help the planet!',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Share.share('I have rescued 32kg of food using Tawfir! Join me in reducing food waste. 🌍✨');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: forestGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('SHARE NOW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  const _EditorialCard({required this.child, this.padding, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: color != null
            ? [BoxShadow(color: color!.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]
            : [BoxShadow(color: AppTheme.primary.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppTheme.primary.withOpacity(0.4),
        letterSpacing: 2,
      ),
    );
  }
}
