import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';

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
                const Text(
                  '🌱',
                  style: TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Impact Logged!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                _ImpactSummaryRow(
                  icon: Icons.restaurant_rounded,
                  label: '$_mealsServed meals served',
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 6),
                _ImpactSummaryRow(
                  icon: Icons.people_alt_rounded,
                  label: '$_beneficiaries people benefited',
                  color: AppTheme.info,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(
                          context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      minimumSize:
                          const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.mutedForeground,
                  ),
                  child: const Text('View All Reports'),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Impact Report',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.mutedForeground,
            ),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderBanner(),
            const SizedBox(height: 12),
            _buildMealsServedCard(),
            const SizedBox(height: 12),
            _buildBeneficiariesCard(),
            const SizedBox(height: 12),
            _buildImpactPreviewCard(),
            const SizedBox(height: 12),
            _buildNotesCard(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // ── Header Banner ────────────────────────────────────────────────────────────

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, Color(0xFF1B5E36)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🌱 Log Your Impact',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Every report helps us measure our community impact',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.70),
            ),
          ),
        ],
      ),
    );
  }

  // ── Meals Served Card ────────────────────────────────────────────────────────

  Widget _buildMealsServedCard() {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meals Served',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
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
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
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
              child: const Text(
                'Reset',
                style: TextStyle(
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

  Widget _buildBeneficiariesCard() {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'People Benefitted',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
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
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
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
              child: const Text(
                'Reset',
                style: TextStyle(
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

  Widget _buildImpactPreviewCard() {
    final co2 = (_mealsServed * 0.3).toStringAsFixed(1);
    final water = _mealsServed * 100;
    final dzd = _mealsServed * 150;

    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Impact Preview',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _ImpactMetricRow(
            icon: Icons.cloud_outlined,
            label: 'CO\u2082 Saved',
            value: '$co2 kg CO\u2082',
          ),
          const SizedBox(height: 10),
          _ImpactMetricRow(
            icon: Icons.water_drop_outlined,
            label: 'Water Saved',
            value: '$water litres',
          ),
          const SizedBox(height: 10),
          _ImpactMetricRow(
            icon: Icons.monetization_on_outlined,
            label: 'Food Value',
            value: '$dzd DZD equivalent',
          ),
        ],
      ),
    );
  }

  // ── Notes Card ───────────────────────────────────────────────────────────────

  Widget _buildNotesCard() {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Any additional notes?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _notesCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Describe how the food was distributed, any feedback '
                  'from recipients...',
              filled: true,
              fillColor: AppTheme.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Submit Button ────────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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
              : const Text(
                  'Submit Impact Report',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 20, color: color),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.mutedForeground,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
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
