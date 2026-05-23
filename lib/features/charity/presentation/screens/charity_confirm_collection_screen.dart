import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_cubit.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_impact_report_screen.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const Color _forestGreen = Color(0xFF2D8659);
const Color _accentBeige = Colors.white;
const Color _textNavy = Color(0xFF1A1A2E);

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

  List<String> _getConditionLabels(AppLocalizations l10n) => [
        l10n.very_poor,
        l10n.poor,
        l10n.average,
        l10n.good,
        l10n.excellent,
      ];

  @override
  void dispose() {
    _actualWeightCtrl.dispose();
    _actualServingsCtrl.dispose();
    super.dispose();
  }


  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      // Update status to collected
      await context.read<CharityCubit>().updateRequestStatus(widget.request.id, PickupRequestStatus.collected);
      setState(() => _isSubmitting = false);
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return;
    }

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(l10n.collection_confirmed_msg),
          ],
        ),
        backgroundColor: _forestGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => BlocProvider.value(
          value: context.read<CharityCubit>(),
          child: CharityImpactReportScreen(request: widget.request),
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(l10n),
                    const SizedBox(height: 20),
                    _buildActualQuantitiesCard(l10n),
                    const SizedBox(height: 20),
                    _buildConditionRatingCard(l10n),
                    const SizedBox(height: 20),
                    _buildPhotoCard(l10n),
                    const SizedBox(height: 32),
                    _buildSubmitButton(l10n),
                  ],
                ),
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
              Text(
                l10n.confirm_collection_title,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card 1: Summary ─────────────────────────────────────────────────────────

  Widget _buildSummaryCard(AppLocalizations l10n) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.confirming_collection_from.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _forestGreen.withOpacity(0.5), letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            widget.request.merchantName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _forestGreen, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(
            widget.request.donationTitle,
            style: TextStyle(fontSize: 14, color: _textNavy.withOpacity(0.7), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 14, color: AppTheme.mutedForeground),
              const SizedBox(width: 4),
              Text(
                l10n.expected_label(widget.request.quantityKg, widget.request.estimatedServings),
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

  Widget _buildActualQuantitiesCard(AppLocalizations l10n) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.what_actually_collected.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _forestGreen.withOpacity(0.5), letterSpacing: 1),
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
                    labelText: l10n.actual_weight_label,
                    hintText: '0.0',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _forestGreen, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.required_field;
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return l10n.must_be_greater_than_zero;
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
                    labelText: l10n.servings,
                    hintText: '0',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _forestGreen, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.required_field;
                    final n = int.tryParse(v);
                    if (n == null || n <= 0) return l10n.must_be_greater_than_zero;
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

  Widget _buildConditionRatingCard(AppLocalizations l10n) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.food_condition_label.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _forestGreen.withOpacity(0.5), letterSpacing: 1),
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
              _getConditionLabels(l10n)[_conditionRating - 1],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: _conditionRating >= 4
                    ? _forestGreen
                    : _conditionRating == 3
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card 4: Photo Evidence ───────────────────────────────────────────────────

  Widget _buildPhotoCard(AppLocalizations l10n) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.add_photo_optional.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _forestGreen.withOpacity(0.5), letterSpacing: 1),
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
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _hasPhoto ? _forestGreen.withOpacity(0.4) : Colors.grey.shade200,
                  width: 1.5,
                ),
                color: _hasPhoto ? _forestGreen.withOpacity(0.04) : Colors.grey[50],
              ),
              child: _hasPhoto
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: _forestGreen, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          l10n.photo_attached,
                          style: const TextStyle(fontSize: 14, color: _forestGreen, fontWeight: FontWeight.w700),
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
                          l10n.tap_to_attach_photo,
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
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Text(
                  l10n.confirm_collection_title.toUpperCase(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 4),
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



