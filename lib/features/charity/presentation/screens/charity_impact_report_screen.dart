import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const Color _forestGreen = Color(0xFF2D8659);
const Color _accentBeige = Colors.white;
const Color _textNavy = Color(0xFF1A1A2E);

class CharityImpactReportScreen extends StatefulWidget {
  const CharityImpactReportScreen({super.key, required this.request});

  final CharityPickupRequest request;

  @override
  State<CharityImpactReportScreen> createState() =>
      _CharityImpactReportScreenState();
}

class _CharityImpactReportScreenState
    extends State<CharityImpactReportScreen> {
  late int _mealsServed;
  late int _beneficiaries;
  final _notesCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _mealsServed = widget.request.estimatedServings;
    _beneficiaries =
        (widget.request.estimatedServings ~/ 3).clamp(1, 999);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;
    _showSuccessDialog();
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
                    fontSize: 22,
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
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
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
                  FadeInUp(duration: const Duration(milliseconds: 350), child: _buildMealsServedCard(l10n)),
                  const SizedBox(height: 16),
                  FadeInUp(delay: const Duration(milliseconds: 80), duration: const Duration(milliseconds: 350), child: _buildBeneficiariesCard(l10n)),
                  const SizedBox(height: 16),
                  FadeInUp(delay: const Duration(milliseconds: 160), duration: const Duration(milliseconds: 350), child: _buildImpactPreviewCard(l10n)),
                  const SizedBox(height: 16),
                  FadeInUp(delay: const Duration(milliseconds: 240), duration: const Duration(milliseconds: 350), child: _buildNotesCard(l10n)),
                  const SizedBox(height: 32),
                  _buildSubmitButton(l10n),
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

  // ── Meals Served Card ────────────────────────────────────────────────────────

  Widget _buildMealsServedCard(AppLocalizations l10n) {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.meals_served_label.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _forestGreen.withOpacity(0.5), letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CounterButton(
                icon: Icons.remove_rounded,
                color: AppTheme.accent,
                onTap: () {
                  if (_mealsServed > 0) {
                    setState(() => _mealsServed--);
                  }
                },
              ),
              const SizedBox(width: 20),
              Text(
                '$_mealsServed',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: _forestGreen, letterSpacing: -1),
              ),
              const SizedBox(width: 20),
              _CounterButton(
                icon: Icons.add_rounded,
                color: AppTheme.primary,
                onTap: () => setState(() => _mealsServed++),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: GestureDetector(
              onTap: () => setState(() =>
                  _mealsServed = widget.request.estimatedServings),
              child: Text(
                l10n.reset,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.mutedForeground,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            value: _mealsServed.toDouble().clamp(0, 200),
            min: 0,
            max: 200,
            activeColor: AppTheme.primary,
            inactiveColor: AppTheme.muted,
            onChanged: (v) =>
                setState(() => _mealsServed = v.round()),
          ),
        ],
      ),
    );
  }

  // ── Beneficiaries Card ───────────────────────────────────────────────────────

  Widget _buildBeneficiariesCard(AppLocalizations l10n) {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.people_benefited_label.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _forestGreen.withOpacity(0.5), letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CounterButton(
                icon: Icons.remove_rounded,
                color: AppTheme.accent,
                onTap: () {
                  if (_beneficiaries > 0) {
                    setState(() => _beneficiaries--);
                  }
                },
              ),
              const SizedBox(width: 20),
              Text(
                '$_beneficiaries',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: _forestGreen, letterSpacing: -1),
              ),
              const SizedBox(width: 20),
              _CounterButton(
                icon: Icons.add_rounded,
                color: AppTheme.primary,
                onTap: () => setState(() => _beneficiaries++),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _beneficiaries =
                  (widget.request.estimatedServings ~/ 3).clamp(1, 999)),
              child: Text(
                l10n.reset,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.mutedForeground,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            value: _beneficiaries.toDouble().clamp(0, 100),
            min: 0,
            max: 100,
            activeColor: AppTheme.primary,
            inactiveColor: AppTheme.muted,
            onChanged: (v) =>
                setState(() => _beneficiaries = v.round()),
          ),
        ],
      ),
    );
  }

  // ── Impact Preview Card ──────────────────────────────────────────────────────

  Widget _buildImpactPreviewCard(AppLocalizations l10n) {
    final co2 = (_mealsServed * 0.3).toStringAsFixed(1);
    final water = _mealsServed * 100;
    final dzd = _mealsServed * 150;

    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.impact_preview_label.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _forestGreen.withOpacity(0.5), letterSpacing: 1),
          ),
          const SizedBox(height: 14),
          _ImpactMetricRow(
            icon: Icons.cloud_outlined,
            label: l10n.co2_saved_label,
            value: l10n.co2_saved_value(co2),
          ),
          const SizedBox(height: 10),
          _ImpactMetricRow(
            icon: Icons.water_drop_outlined,
            label: l10n.water_saved_label,
            value: l10n.water_saved_value(water),
          ),
          const SizedBox(height: 10),
          _ImpactMetricRow(
            icon: Icons.monetization_on_outlined,
            label: l10n.food_value_label,
            value: l10n.food_value_currency(dzd),
          ),
        ],
      ),
    );
  }

  // ── Notes Card ───────────────────────────────────────────────────────────────

  Widget _buildNotesCard(AppLocalizations l10n) {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.any_additional_notes.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _forestGreen.withOpacity(0.5), letterSpacing: 1),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _notesCtrl,
            maxLines: 4,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textNavy),
            decoration: InputDecoration(
              hintText: l10n.distribution_notes_hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _forestGreen, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Submit Button ────────────────────────────────────────────────────────────

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _forestGreen,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
        ),
      ),
    );
  }
}

// ── Shared helpers ───────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D8659).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }
}

class _ImpactMetricRow extends StatelessWidget {
  const _ImpactMetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2D8659).withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF2D8659)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: _textNavy.withOpacity(0.5), fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _forestGreen, letterSpacing: -0.3),
        ),
      ],
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
        Icon(icon, size: 18, color: color),
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



