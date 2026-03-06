import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_impact_report_screen.dart';

class CharityConfirmCollectionScreen extends StatefulWidget {
  const CharityConfirmCollectionScreen({super.key, required this.request});

  final CharityPickupRequest request;

  @override
  State<CharityConfirmCollectionScreen> createState() =>
      _CharityConfirmCollectionScreenState();
}

class _CharityConfirmCollectionScreenState
    extends State<CharityConfirmCollectionScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _actualWeightCtrl;
  late final TextEditingController _actualServingsCtrl;

  int _conditionRating = 5;
  bool _hasPhoto = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _actualWeightCtrl =
        TextEditingController(text: widget.request.quantityKg.toString());
    _actualServingsCtrl = TextEditingController(
        text: widget.request.estimatedServings.toString());
  }

  @override
  void dispose() {
    _actualWeightCtrl.dispose();
    _actualServingsCtrl.dispose();
    super.dispose();
  }

  static const _conditionLabels = [
    'Very Poor',
    'Poor',
    'Average',
    'Good',
    'Excellent',
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Collection confirmed! ✓'),
          ],
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CharityImpactReportScreen(request: widget.request),
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
          'Confirm Collection',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 12),
              _buildActualQuantitiesCard(),
              const SizedBox(height: 12),
              _buildConditionRatingCard(),
              const SizedBox(height: 12),
              _buildPhotoCard(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card 1: Summary ─────────────────────────────────────────────────────────

  Widget _buildSummaryCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirming collection from:',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.request.merchantName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.request.donationTitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 14, color: AppTheme.mutedForeground),
              const SizedBox(width: 4),
              Text(
                'Expected: ${widget.request.quantityKg} kg  /  '
                '${widget.request.estimatedServings} servings',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.mutedForeground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Card 2: Actual Quantities ────────────────────────────────────────────────

  Widget _buildActualQuantitiesCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What did you actually collect?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _actualWeightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Actual weight (kg)',
                    hintText: '0.0',
                    filled: true,
                    fillColor: AppTheme.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return 'Must be > 0';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _actualServingsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Servings',
                    hintText: '0',
                    filled: true,
                    fillColor: AppTheme.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final n = int.tryParse(v);
                    if (n == null || n <= 0) return 'Must be > 0';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Card 3: Condition Rating ─────────────────────────────────────────────────

  Widget _buildConditionRatingCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Food Condition',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              return GestureDetector(
                onTap: () =>
                    setState(() => _conditionRating = starIndex),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    starIndex <= _conditionRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 36,
                    color: starIndex <= _conditionRating
                        ? Colors.amber
                        : Colors.grey.shade300,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _conditionLabels[_conditionRating - 1],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _conditionRating >= 4
                    ? AppTheme.primary
                    : _conditionRating == 3
                        ? Colors.orange
                        : AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card 4: Photo Evidence ───────────────────────────────────────────────────

  Widget _buildPhotoCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Photo (optional)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _hasPhoto
                ? null
                : () => setState(() => _hasPhoto = true),
            child: Container(
              width: double.infinity,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasPhoto
                      ? AppTheme.primary.withOpacity(0.4)
                      : Colors.grey.shade300,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                color: _hasPhoto
                    ? AppTheme.primary.withOpacity(0.04)
                    : Colors.transparent,
              ),
              child: _hasPhoto
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Photo attached',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _hasPhoto = false),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppTheme.accent,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 28,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap to attach photo',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
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
                  'Confirm Collection',
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

// ── Shared section card wrapper ──────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

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
