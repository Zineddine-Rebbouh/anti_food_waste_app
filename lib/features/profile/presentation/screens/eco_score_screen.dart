import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/profile/domain/models/app_user.dart';
import 'package:anti_food_waste_app/features/profile/domain/models/eco_score_event.dart';
import 'package:anti_food_waste_app/features/profile/presentation/cubits/eco_score_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:anti_food_waste_app/shared/widgets/tawfir_loading_indicator.dart';

class EcoScoreScreen extends StatefulWidget {
  final AppUser user;
  const EcoScoreScreen({super.key, required this.user});

  @override
  State<EcoScoreScreen> createState() => _EcoScoreScreenState();
}

class _EcoScoreScreenState extends State<EcoScoreScreen> {
  static const Color forestGreen = AppTheme.primary;
  static const Color accentBeige = Colors.white;

  @override
  void initState() {
    super.initState();
    context.read<EcoScoreCubit>().loadDetails();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: accentBeige,
      body: BlocBuilder<EcoScoreCubit, EcoScoreState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(context, l10n),
              Expanded(
                child: state is EcoScoreLoading
                    ? Center(
                        child: TawfirLoadingIndicator(
                            message: l10n.eco_calculating))
                    : state is EcoScoreError
                        ? Center(child: Text(state.message))
                        : state is EcoScoreLoaded
                            ? SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    _buildScoreHeader(state.details, l10n),
                                    const SizedBox(height: 24),
                                    _buildTierPrivileges(state.details, l10n),
                                    const SizedBox(height: 24),
                                    _buildHistorySection(state.history, l10n),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
              ),
            ],
          );
        },
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
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.eco_score_title,
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

  Widget _buildScoreHeader(Map<String, dynamic> details, AppLocalizations l10n) {
    final score = (details['score'] as num? ?? 0).toInt();
    final tier = details['tier_label'] as String? ?? 'Developing';
    final color = _getTierColor(details['tier'] as String? ?? 'developing');
    final nextTier = details['next_tier'] as Map<String, dynamic>?;

    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: forestGreen.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[50],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: -2,
                      ),
                    ),
                    Text(
                      l10n.eco_score_points,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getTierIcon(details['tier']), color: color, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    tier.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            if (nextTier != null) ...[
              const SizedBox(height: 32),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: score / nextTier['score_needed'],
                  minHeight: 8,
                  backgroundColor: Colors.grey[50],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(color.withOpacity(0.3)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${nextTier['points_away']} points to reach ${nextTier['name']}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTierPrivileges(Map<String, dynamic> details, AppLocalizations l10n) {
    final privileges = details['privileges'] as Map<String, dynamic>? ?? {};
    if (privileges.isEmpty) return const SizedBox.shrink();

    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(l10n.eco_tier_benefits),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: forestGreen.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: privileges.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: forestGreen.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(CupertinoIcons.checkmark_alt,
                            color: forestGreen, size: 14),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _formatPrivilege(e.key, e.value),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(List<EcoScoreEvent> history, AppLocalizations l10n) {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(l10n.eco_score_history),
          const SizedBox(height: 16),
          if (history.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Text(
                  l10n.eco_no_history,
                  style: TextStyle(
                      color: Colors.grey[400], fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = history[index];
                final isPositive = event.delta > 0;
                final color =
                    isPositive ? forestGreen : const Color(0xFFBC4749);

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: forestGreen.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPositive
                              ? CupertinoIcons.add
                              : CupertinoIcons.minus,
                          color: color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.typeLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, yyyy').format(event.createdAt),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isPositive ? "+" : ""}${event.delta}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: color,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'exemplary':
        return const Color(0xFFD4AF37); // Gold
      case 'reliable':
        return forestGreen;
      case 'developing':
        return forestGreen;
      case 'at_risk':
        return const Color(0xFFBC4749); // Red
      default:
        return forestGreen;
    }
  }

  IconData _getTierIcon(String? tier) {
    switch (tier) {
      case 'exemplary':
        return CupertinoIcons.star_fill;
      case 'reliable':
        return CupertinoIcons.checkmark_seal_fill;
      case 'at_risk':
        return CupertinoIcons.exclamationmark_triangle_fill;
      default:
        return CupertinoIcons.leaf_arrow_circlepath;
    }
  }

  String _formatPrivilege(String key, dynamic value) {
    final label = key.replaceAll('_', ' ');
    if (value is bool) return label.toUpperCase();
    return '${label.toUpperCase()}: $value';
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
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: AppTheme.primary.withOpacity(0.4),
        letterSpacing: 2,
      ),
    );
  }
}
