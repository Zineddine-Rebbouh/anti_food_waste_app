import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_cubit.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_state.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const Color _forestGreen = Color(0xFF2D8659);
const Color _accentBeige = Colors.white;
const Color _textNavy = Color(0xFF1A1A2E);

class CharityImpactReportScreen extends StatefulWidget {
  const CharityImpactReportScreen({
    super.key,
    required this.request,
    this.actualWeightKg,
    this.actualServings,
  });

  final CharityPickupRequest request;
  final double? actualWeightKg;
  final int? actualServings;

  @override
  State<CharityImpactReportScreen> createState() =>
      _CharityImpactReportScreenState();
}

class _CharityImpactReportScreenState
    extends State<CharityImpactReportScreen> {
  late int _mealsServed;
  late int _beneficiaries;
  late double _weightKg;
  final _notesCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _weightKg = widget.actualWeightKg ?? widget.request.quantityKg;
    if (_weightKg <= 0) {
      _weightKg = 10.0; // fallback default
    }
    _mealsServed = widget.actualServings ?? widget.request.estimatedServings;
    if (_mealsServed <= 0) {
      _mealsServed = (_weightKg * 3).round().clamp(1, 999); // fallback calculation
    }
    _beneficiaries = (_mealsServed ~/ 3).clamp(1, 999);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      await context.read<CharityCubit>().submitImpactReport(
        donationId: widget.request.donationId,
        pickupRequestId: widget.request.id,
        donationTitle: widget.request.donationTitle,
        mealsServed: _mealsServed,
        beneficiaries: _beneficiaries,
        actualWeightKg: _weightKg,
        notes: _notesCtrl.text.trim(),
      );
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _showSuccessDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌱', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                Text(
                  l10n.impact_logged_title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _forestGreen,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _ImpactSummaryRow(
                  icon: Icons.restaurant_rounded,
                  label: l10n.meals_served_count(_mealsServed),
                  color: _forestGreen,
                ),
                const SizedBox(height: 6),
                _ImpactSummaryRow(
                  icon: Icons.people_alt_rounded,
                  label: l10n.people_benefited_count(_beneficiaries),
                  color: const Color(0xFF2D8659),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _forestGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.back_to_home,
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog to view reports list
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: Text(l10n.view_all_reports),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _accentBeige,
      body: Column(
        children: [
          _buildHeader(context, l10n),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "LOG NEW IMPACT".toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: _forestGreen.withOpacity(0.6),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInUp(
                    duration: const Duration(milliseconds: 350),
                    child: _buildNewReportForm(l10n),
                  ),
                  const SizedBox(height: 24),
                  _buildSubmitButton(l10n),
                  const SizedBox(height: 48),
                  
                  // Past reports section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.view_reports.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: _forestGreen.withOpacity(0.6),
                          letterSpacing: 1,
                        ),
                      ),
                      const Icon(Icons.history_rounded, size: 16, color: _forestGreen),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  BlocBuilder<CharityCubit, CharityState>(
                    builder: (context, state) {
                      if (state is CharityLoaded && state.reports.isNotEmpty) {
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.reports.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final report = state.reports[index];
                            return FadeInUp(
                              duration: const Duration(milliseconds: 300),
                              delay: Duration(milliseconds: index * 50),
                              child: _buildPastReportTile(report, l10n),
                            );
                          },
                        );
                      }
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            "No reports submitted yet",
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Premium Header ────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _forestGreen,
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
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.impact_report_title,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.skip_action, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── New Report Form ────────────────────────────────────────────────────────

  Widget _buildNewReportForm(AppLocalizations l10n) {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _forestGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.restaurant_rounded, color: _forestGreen, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.request.donationTitle,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _textNavy),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.request.merchantName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  Icons.restaurant_rounded,
                  "$_mealsServed",
                  l10n.meals_served_label,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade100),
              Expanded(
                child: _buildMetricTile(
                  Icons.people_alt_rounded,
                  "$_beneficiaries",
                  l10n.people_benefited_label,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade100),
              Expanded(
                child: _buildMetricTile(
                  Icons.scale_rounded,
                  "${_weightKg.toStringAsFixed(1)} kg",
                  "Food Rescued",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F1F1)),
          const SizedBox(height: 20),
          
          // Environmental Impact
          Text(
            l10n.impact_preview_label.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _forestGreen.withOpacity(0.5), letterSpacing: 1),
          ),
          const SizedBox(height: 14),
          _buildImpactMetricRow(
            Icons.cloud_outlined,
            l10n.co2_saved_label,
            l10n.co2_saved_value((_mealsServed * 0.3).toStringAsFixed(1)),
          ),
          const SizedBox(height: 10),
          _buildImpactMetricRow(
            Icons.water_drop_outlined,
            l10n.water_saved_label,
            l10n.water_saved_value((_mealsServed * 100).toString()),
          ),
          const SizedBox(height: 10),
          _buildImpactMetricRow(
            Icons.monetization_on_outlined,
            l10n.food_value_label,
            l10n.food_value_currency((_mealsServed * 150).toString()),
          ),
          const SizedBox(height: 24),
          
          // Notes Card
          Text(
            l10n.any_additional_notes.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _forestGreen.withOpacity(0.5), letterSpacing: 1),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _notesCtrl,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textNavy),
            decoration: InputDecoration(
              hintText: l10n.distribution_notes_hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _forestGreen, width: 1.5)),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: _forestGreen, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _textNavy),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildImpactMetricRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _forestGreen.withOpacity(0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: _textNavy.withOpacity(0.6), fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _forestGreen),
        ),
      ],
    );
  }

  // ── Past Report Tile ─────────────────────────────────────────────────────────

  Widget _buildPastReportTile(CharityImpactReport report, AppLocalizations l10n) {
    final reportedDateStr = "${report.reportedAt.day}/${report.reportedAt.month}/${report.reportedAt.year}";
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  report.donationTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: _textNavy,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                reportedDateStr,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniMetric(Icons.restaurant_rounded, "${report.mealsServed} meals"),
              _buildMiniMetric(Icons.people_alt_rounded, "${report.beneficiaries} families"),
              _buildMiniMetric(Icons.scale_rounded, "${report.actualWeightKg.toStringAsFixed(1)} kg"),
            ],
          ),
          if (report.notes != null && report.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                report.notes!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniMetric(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 12, color: _forestGreen.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _textNavy,
          ),
        ),
      ],
    );
  }

  // ── Submit Button ────────────────────────────────────────────────────────────

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _forestGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                l10n.submit_impact_report.toUpperCase(),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: child,
    );
  }
}

class _ImpactSummaryRow extends StatelessWidget {
  const _ImpactSummaryRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
