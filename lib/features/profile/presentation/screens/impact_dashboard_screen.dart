import 'package:flutter/material.dart';
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
  // TweenAnimationBuilders start automatically on first build, so no extra
  // controller is needed. All animations fire once on page load.

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.impact_dashboard_title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.foreground,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: Hero Stats Card ────────────────────────────────
            _buildHeroCard(l10n),
            const SizedBox(height: 24),

            // ── Section 2: Achievements / Badges ─────────────────────────
            _buildBadgesSection(l10n),
            const SizedBox(height: 24),

            // ── Section 3: Monthly Activity Chart ────────────────────────
            _buildMonthlyChart(l10n),
            const SizedBox(height: 24),

            // ── Section 4: Impact Breakdown ───────────────────────────────
            _buildImpactBreakdown(l10n),
            const SizedBox(height: 24),

            // ── Section 5: Leaderboard Preview ────────────────────────────
            _buildLeaderboard(l10n),
            const SizedBox(height: 24),

            // ── Section 6: Share Card ─────────────────────────────────────
            _buildShareCard(l10n),
            const SizedBox(height: 32),
          ],
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D8659), Color(0xFF1B5E3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D8659).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            l10n.total_food_rescued,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),

          // Animated counter: 0 → 32 kg
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 32),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) {
              return Text(
                '${value.toInt()} kg',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  height: 1.05,
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🌟  Silver Level  •  Eco-Score 85',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Divider
          Divider(color: Colors.white.withOpacity(0.2), height: 1),
          const SizedBox(height: 20),

          // Mini stats row
          Row(
            children: [
              _buildMiniStat('14.4 kg', l10n.co2_avoided),
              _buildMiniStatDivider(),
              _buildMiniStat('2 🌳', '2 trees equivalent'),
              _buildMiniStatDivider(),
              _buildMiniStat('4,800 DZD', l10n.money_saved_label),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
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
            Text(
              l10n.your_badges,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'See all',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: badge.earned
                        ? const LinearGradient(
                            colors: [Color(0xFF2D8659), Color(0xFF1B5E3F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.shade200,
                              Colors.grey.shade300,
                            ],
                          ),
                    boxShadow: badge.earned
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      badge.emoji,
                      style: TextStyle(
                        fontSize: 26,
                        color: badge.earned ? null : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),

                // Locked overlay
                if (!badge.earned)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.28),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: badge.earned ? Colors.black87 : Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            if (!badge.earned) ...[
              const SizedBox(height: 2),
              Text(
                'Locked',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
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
        Text(
          l10n.monthly_activity,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Legend row
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.food_rescues_label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
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
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (value, meta) {
                              const months = [
                                'Jan',
                                'Feb',
                                'Mar',
                                'Apr',
                                'May',
                                'Jun'
                              ];
                              final idx = value.toInt();
                              if (idx < 0 || idx >= months.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  months[idx],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
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
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black38,
                                ),
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
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
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
        color: AppTheme.primary,
      ),
      _BreakdownItem(
        icon: Icons.attach_money_rounded,
        label: l10n.economic_impact,
        percent: 0.70,
        color: AppTheme.info,
      ),
      _BreakdownItem(
        icon: Icons.people_alt_rounded,
        label: l10n.social_impact,
        percent: 0.60,
        color: AppTheme.warning,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.impact_breakdown,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(items.length, (index) {
                final item = items[index];
                return Column(
                  children: [
                    if (index != 0)
                      Divider(
                        color: Colors.grey.shade100,
                        height: 1,
                      ),
                    if (index != 0) const SizedBox(height: 12),
                    _buildBreakdownRow(item),
                    if (index != items.length - 1) const SizedBox(height: 12),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(_BreakdownItem item) {
    return Row(
      children: [
        // Icon container
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: item.color, size: 20),
        ),
        const SizedBox(width: 14),

        // Label + progress
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  // Animated percentage text
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: item.percent),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) {
                      return Text(
                        '${(value * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: item.color,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Animated progress bar
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: item.percent),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(item.color),
                      minHeight: 8,
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
        Text(
          l10n.community_leaderboard,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildLeaderboardRow(
                  rank: '🥇',
                  name: 'Ahmed B.',
                  rescues: 78,
                  isYou: false,
                ),
                const SizedBox(height: 8),
                _buildLeaderboardRow(
                  rank: '🥈',
                  name: 'Fatima Z.',
                  rescues: 65,
                  isYou: false,
                ),
                const SizedBox(height: 8),
                _buildLeaderboardRow(
                  rank: '🥉',
                  name: 'Karim M.',
                  rescues: 54,
                  isYou: false,
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade100, height: 1),
                const SizedBox(height: 12),
                _buildLeaderboardRow(
                  rank: '#12',
                  name: 'You',
                  rescues: 32,
                  isYou: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow({
    required String rank,
    required String name,
    required int rescues,
    required bool isYou,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: isYou
          ? BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.2),
                width: 1,
              ),
            )
          : null,
      child: Row(
        children: [
          // Rank medal / number
          SizedBox(
            width: 40,
            child: Text(
              rank,
              style: TextStyle(
                fontSize: rank.startsWith('#') ? 13 : 22,
                fontWeight: FontWeight.bold,
                color: rank.startsWith('#') ? AppTheme.primary : null,
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Name
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isYou ? FontWeight.bold : FontWeight.w500,
                color: isYou ? AppTheme.primary : Colors.black87,
              ),
            ),
          ),

          // Rescue count chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isYou
                  ? AppTheme.primary.withOpacity(0.12)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$rescues rescues',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isYou ? AppTheme.primary : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Section 6: Share Card
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildShareCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3949AB).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Share icon bubble
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.share_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          // Text + button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.share_your_impact,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Inspire others to rescue food and help the planet!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    Share.share(
                      'I rescued 32 kg of food with SaveFood DZ! 🌱\n'
                      '• CO₂ avoided: 14.4 kg ☁️\n'
                      '• Equivalent to 2 trees 🌳\n'
                      '• Money saved: 4,800 DZD 💰\n\n'
                      'Together, let\'s fight food waste in Algeria!\n'
                      '#SaveFoodDZ #ZeroFoodWaste #Algeria',
                      subject: 'My SaveFood DZ Impact',
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Share Now',
                      style: TextStyle(
                        color: Color(0xFF3949AB),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
