import 'dart:io';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_listing.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/shared/widgets/confetti_overlay.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ── Form State ─────────────────────────────────────────────────────────────────

class _ListingFormData {
  String imagePath = '';
  String originalImageUrl = '';
  FreshnessGrade grade = FreshnessGrade.a;
  String title = '';
  MerchantFoodCategory category = MerchantFoodCategory.bakery;
  String description = '';
  List<DietaryTag> dietaryTags = [DietaryTag.halal];
  double originalPrice = 0;
  double discountedPrice = 0;
  int quantity = 10;
  TimeOfDay pickupStart = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay pickupEnd = const TimeOfDay(hour: 20, minute: 0);
  bool safetyConfirmed = false;

  double get discount =>
      originalPrice > 0 ? (1 - discountedPrice / originalPrice) * 100 : 0;
  double get netEarnings => discountedPrice * 0.88;
  double get platformFee => discountedPrice * 0.12;
  double get potentialRevenue => netEarnings * quantity;
}

// ── Main Container ─────────────────────────────────────────────────────────────

class MerchantCreateListingScreen extends StatefulWidget {
  final MerchantListing? existingListing;
  const MerchantCreateListingScreen({super.key, this.existingListing});

  @override
  State<MerchantCreateListingScreen> createState() =>
      _MerchantCreateListingScreenState();
}

class _MerchantCreateListingScreenState
    extends State<MerchantCreateListingScreen> {
  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color backgroundColor = Colors.white;

  final _pageController = PageController();
  final _form = _ListingFormData();
  int _currentStep = 0;
  bool _isPublishing = false;
  bool _showSuccess = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  List<String> _getStepLabels(AppLocalizations l10n) => [
        l10n.step_photo,
        l10n.step_details,
        l10n.step_price,
        l10n.step_pickup,
        l10n.step_preview
      ];

  @override
  void initState() {
    super.initState();
    if (widget.existingListing != null) {
      final listing = widget.existingListing!;
      _form.title = listing.title;
      _form.description = listing.description;
      _form.category = listing.category;
      _form.dietaryTags = [...listing.dietaryTags];
      _form.originalPrice = listing.originalPrice;
      _form.discountedPrice = listing.discountedPrice;
      _form.quantity = listing.totalQuantity;
      _form.grade = listing.grade;
      _form.pickupStart = TimeOfDay.fromDateTime(listing.pickupStart);
      _form.pickupEnd = TimeOfDay.fromDateTime(listing.pickupEnd);
      _form.originalImageUrl = listing.imageUrl;
      _form.safetyConfirmed = true;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _confirmClose();
    }
  }

  void _confirmClose() {
    if (_form.title.isEmpty && _form.imagePath.isEmpty) {
      Navigator.pop(context);
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.discard_listing,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
        content: Text(
          l10n.discard_listing_desc,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.keep_editing.toUpperCase(),
                style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _saveDraft();
              Navigator.pop(context);
            },
            child: Text(l10n.save_draft.toUpperCase(),
                style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Future<void> _publish() async {
    setState(() => _isPublishing = true);
    final now = DateTime.now();

    DateTime toFutureDateTime(TimeOfDay tod, {DateTime? mustBeAfter}) {
      var dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
      if (!dt.isAfter(now.add(const Duration(minutes: 5)))) {
        dt = dt.add(const Duration(days: 1));
      }
      if (mustBeAfter != null && !dt.isAfter(mustBeAfter)) {
        dt = dt.add(const Duration(days: 1));
      }
      return dt;
    }

    final pickupStart = toFutureDateTime(_form.pickupStart);
    final pickupEnd = toFutureDateTime(_form.pickupEnd, mustBeAfter: pickupStart);

    try {
      if (widget.existingListing != null) {
        await context.read<MerchantCubit>().updateListingAsync(
              widget.existingListing!.id,
              title: _form.title,
              description: _form.description,
              discountedPrice: _form.discountedPrice,
              quantity: _form.quantity,
              grade: _form.grade,
              dietaryTags: _form.dietaryTags,
              pickupStart: pickupStart,
              pickupEnd: pickupEnd,
              imagePath: _form.imagePath.isNotEmpty ? _form.imagePath : null,
            );
      } else {
        await context.read<MerchantCubit>().createListingAsync(
              category: _form.category,
              title: _form.title,
              description: _form.description,
              originalPrice: _form.originalPrice,
              discountedPrice: _form.discountedPrice,
              quantity: _form.quantity,
              grade: _form.grade,
              dietaryTags: _form.dietaryTags,
              pickupStart: pickupStart,
              pickupEnd: pickupEnd,
              imagePath: _form.imagePath.isNotEmpty ? _form.imagePath : null,
            );
      }
      setState(() {
        _isPublishing = false;
        _showSuccess = true;
      });
    } catch (e) {
      setState(() => _isPublishing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _saveDraft() {
    if (_form.title.isEmpty) return;
    final now = DateTime.now();
    final listing = MerchantListing(
      id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
      title: _form.title.isEmpty ? l10n.untitled_draft : _form.title,
      description: _form.description,
      imageUrl: '',
      category: _form.category,
      dietaryTags: _form.dietaryTags,
      originalPrice: _form.originalPrice,
      discountedPrice: _form.discountedPrice,
      totalQuantity: _form.quantity,
      reservedQuantity: 0,
      pickupStart: DateTime(
          now.year, now.month, now.day, _form.pickupStart.hour,
          _form.pickupStart.minute),
      pickupEnd: DateTime(
          now.year, now.month, now.day, _form.pickupEnd.hour,
          _form.pickupEnd.minute),
      status: ListingStatus.draft,
      grade: _form.grade,
      views: 0,
      createdAt: now,
    );
    context.read<MerchantCubit>().addListing(listing);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_showSuccess) {
      return _SuccessScreen(
        form: _form,
        onAddAnother: () {
          setState(() {
            _showSuccess = false;
            _currentStep = 0;
            _form.imagePath = '';
            _form.title = '';
            _form.description = '';
            _form.originalPrice = 0;
            _form.discountedPrice = 0;
            _form.dietaryTags = [DietaryTag.halal];
            _form.safetyConfirmed = false;
          });
          _pageController.jumpToPage(0);
        },
        onViewListings: () => Navigator.pop(context),
        onDone: () => Navigator.pop(context),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryGreen, size: 20),
          onPressed: _prevStep,
        ),
        title: _StepProgressHeader(
          currentStep: _currentStep,
          labels: _getStepLabels(l10n),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _Step1Photo(
            form: _form,
            onNext: _nextStep,
            onFormChanged: () => setState(() {}),
          ),
          _Step2Details(
            form: _form,
            onNext: _nextStep,
            onBack: _prevStep,
            onFormChanged: () => setState(() {}),
          ),
          _Step3Pricing(
            form: _form,
            onNext: _nextStep,
            onBack: _prevStep,
            onFormChanged: () => setState(() {}),
          ),
          _Step4Pickup(
            form: _form,
            onNext: _nextStep,
            onBack: _prevStep,
            onFormChanged: () => setState(() {}),
          ),
          _Step5Preview(
            form: _form,
            isPublishing: _isPublishing,
            onPublish: _publish,
            onSaveDraft: () {
              _saveDraft();
              Navigator.pop(context);
            },
            onBack: _prevStep,
            onFormChanged: () => setState(() {}),
          ),
        ],
      ),
    );
  }
}

// ── Step Progress Header ───────────────────────────────────────────────────────

class _StepProgressHeader extends StatelessWidget {
  final int currentStep;
  final List<String> labels;

  const _StepProgressHeader(
      {required this.currentStep, required this.labels});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2D8659);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          labels[currentStep].toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w900,
            color: primaryGreen,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(labels.length, (i) {
            final isActive = i == currentStep;
            final isDone = i < currentStep;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 12,
              height: 6,
              decoration: BoxDecoration(
                color: isDone || isActive
                    ? primaryGreen
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(100),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Step 1: Photo ─────────────────────────────────────────────────────────────

class _Step1Photo extends StatefulWidget {
  final _ListingFormData form;
  final VoidCallback onNext;
  final VoidCallback onFormChanged;

  const _Step1Photo(
      {required this.form,
      required this.onNext,
      required this.onFormChanged});

  @override
  State<_Step1Photo> createState() => _Step1PhotoState();
}

class _Step1PhotoState extends State<_Step1Photo> {
  bool _validating = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);
    if (file == null) return;
    setState(() => _validating = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _validating = false;
      widget.form.imagePath = file.path;
    });
    widget.onFormChanged();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.form.imagePath.isNotEmpty || widget.form.originalImageUrl.isNotEmpty;

    final l10n = AppLocalizations.of(context)!;
    const primaryGreen = Color(0xFF2D8659);
    const accentBeige = Colors.white;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.add_photo_title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.add_photo_desc,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),

          // Photo area
          GestureDetector(
            onTap: hasPhoto ? null : () => _pickImage(ImageSource.camera),
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: hasPhoto
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: widget.form.imagePath.isNotEmpty
                            ? Image.file(
                                File(widget.form.imagePath),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: widget.form.originalImageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                            ),
                        ),
                        // Retake button
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: () => _pickImage(ImageSource.camera),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.refresh, color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  Text(l10n.retake_label.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: const BoxDecoration(color: accentBeige, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt_outlined, color: primaryGreen, size: 36),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.snap_photo_label,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickImage(ImageSource.gallery),
                          child: Text(
                            l10n.choose_from_gallery.toUpperCase(),
                            style: const TextStyle(fontSize: 12, color: primaryGreen, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          if (_validating) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: primaryGreen)),
                const SizedBox(width: 12),
                Text(l10n.analyzing_photo, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
              ],
            ),
          ],

          if (hasPhoto) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      l10n.photo_quality_passed,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF16A34A), fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),
          ElevatedButton(
            onPressed: hasPhoto ? widget.onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: Text(l10n.continue_label.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Details ───────────────────────────────────────────────────────────

class _Step2Details extends StatefulWidget {
  final _ListingFormData form;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onFormChanged;

  const _Step2Details(
      {required this.form,
      required this.onNext,
      required this.onBack,
      required this.onFormChanged});

  @override
  State<_Step2Details> createState() => _Step2DetailsState();
}

class _Step2DetailsState extends State<_Step2Details> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;

  List<(MerchantFoodCategory, String, String)> _getCategories(AppLocalizations l10n) => [
        (MerchantFoodCategory.bakery, l10n.bakery, '🍞'),
        (MerchantFoodCategory.restaurant, l10n.restaurant, '🍽️'),
        (MerchantFoodCategory.supermarket, l10n.supermarket, '🛒'),
        (MerchantFoodCategory.cafe, l10n.cafe, '☕'),
        (MerchantFoodCategory.other, l10n.other_label, '📦'),
      ];

  List<(DietaryTag, String)> _getTags(AppLocalizations l10n) => [
        (DietaryTag.halal, l10n.halal),
        (DietaryTag.vegan, l10n.vegan),
        (DietaryTag.vegetarian, l10n.vegetarian),
        (DietaryTag.glutenFree, l10n.gluten_free),
        (DietaryTag.nutFree, l10n.nut_free),
        (DietaryTag.dairyFree, l10n.dairy_free),
      ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.form.title);
    _descCtrl = TextEditingController(text: widget.form.description);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _titleCtrl.text.trim().length >= 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = _getCategories(l10n);
    final tags = _getTags(l10n);

    const primaryGreen = Color(0xFF2D8659);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.item_details_title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.item_details_desc,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),

          // Title
          Text(l10n.title_label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryGreen, letterSpacing: 1)),
          const SizedBox(height: 8),
          TextField(
            controller: _titleCtrl,
            maxLength: 60,
            style: const TextStyle(fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: l10n.title_hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade100)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: primaryGreen, width: 2)),
              counterStyle: const TextStyle(fontSize: 11),
            ),
            onChanged: (v) {
              widget.form.title = v;
              setState(() {});
              widget.onFormChanged();
            },
          ),
          const SizedBox(height: 24),

          // Category
          Text(l10n.category_label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryGreen, letterSpacing: 1)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.map((cat) {
              final selected = widget.form.category == cat.$1;
              return GestureDetector(
                onTap: () {
                  widget.form.category = cat.$1;
                  setState(() {});
                  widget.onFormChanged();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: selected ? primaryGreen : Colors.grey.shade100),
                    boxShadow: selected ? [BoxShadow(color: primaryGreen.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
                  ),
                  child: Text(
                    '${cat.$3} ${cat.$2}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: selected ? Colors.white : const Color(0xFF374151)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Description
          Text(l10n.description_label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryGreen, letterSpacing: 1)),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            maxLines: 4,
            maxLength: 300,
            style: const TextStyle(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: l10n.description_hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade100)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: primaryGreen, width: 2)),
              counterStyle: const TextStyle(fontSize: 11),
            ),
            onChanged: (v) {
              widget.form.description = v;
              widget.onFormChanged();
            },
          ),
          const SizedBox(height: 24),

          // Dietary Tags
          Text(l10n.dietary_info_label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryGreen, letterSpacing: 1)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              final selected = widget.form.dietaryTags.contains(tag.$1);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      widget.form.dietaryTags.remove(tag.$1);
                    } else {
                      widget.form.dietaryTags.add(tag.$1);
                    }
                  });
                  widget.onFormChanged();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFDCFCE7) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? const Color(0xFF16A34A) : Colors.grey.shade100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) const Icon(Icons.check, size: 14, color: Color(0xFF16A34A)),
                      if (selected) const SizedBox(width: 6),
                      Text(
                        tag.$2,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: selected ? const Color(0xFF16A34A) : Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade200),
                    minimumSize: const Size(0, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(l10n.back_label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _canContinue ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: Text(l10n.continue_label.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Step 3: Pricing ───────────────────────────────────────────────────────────

class _Step3Pricing extends StatefulWidget {
  final _ListingFormData form;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onFormChanged;

  const _Step3Pricing(
      {required this.form,
      required this.onNext,
      required this.onBack,
      required this.onFormChanged});

  @override
  State<_Step3Pricing> createState() => _Step3PricingState();
}

class _Step3PricingState extends State<_Step3Pricing> {
  late final TextEditingController _origPriceCtrl;
  late final TextEditingController _discPriceCtrl;

  @override
  void initState() {
    super.initState();
    _origPriceCtrl = TextEditingController(text: widget.form.originalPrice > 0 ? widget.form.originalPrice.toStringAsFixed(0) : '');
    _discPriceCtrl = TextEditingController(text: widget.form.discountedPrice > 0 ? widget.form.discountedPrice.toStringAsFixed(0) : '');
  }

  @override
  void dispose() {
    _origPriceCtrl.dispose();
    _discPriceCtrl.dispose();
    super.dispose();
  }

  bool get _canContinue => widget.form.originalPrice > 0 && widget.form.discountedPrice > 0 && widget.form.discountedPrice < widget.form.originalPrice;

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2D8659);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pricing_inventory_title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pricing_inventory_desc,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.original_price_label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryGreen, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _origPriceCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                      decoration: InputDecoration(
                        suffixText: l10n.currency_label,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade100)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryGreen, width: 2)),
                      ),
                      onChanged: (v) {
                        setState(() => widget.form.originalPrice = double.tryParse(v) ?? 0);
                        widget.onFormChanged();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.discounted_label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryGreen, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _discPriceCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: primaryGreen),
                      decoration: InputDecoration(
                        suffixText: l10n.currency_label,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade100)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryGreen, width: 2)),
                      ),
                      onChanged: (v) {
                        setState(() => widget.form.discountedPrice = double.tryParse(v) ?? 0);
                        widget.onFormChanged();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(28)),
            child: Column(
              children: [
                _SummaryRow(label: l10n.your_discount_label, value: "${widget.form.discount.toStringAsFixed(0)}%", color: Colors.white),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white24)),
                _SummaryRow(label: l10n.estimated_earnings_label, value: "${widget.form.netEarnings.toStringAsFixed(0)} ${l10n.currency_label}", color: Colors.white, isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 40),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade200),
                    minimumSize: const Size(0, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(l10n.back_label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _canContinue ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: Text(l10n.continue_label.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _SummaryRow({required this.label, required this.value, required this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(color: color, fontSize: isBold ? 20 : 16, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

// ── Step 4: Quantity & Pickup ──────────────────────────────────────────────────

class _Step4Pickup extends StatefulWidget {
  final _ListingFormData form;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onFormChanged;

  const _Step4Pickup(
      {required this.form,
      required this.onNext,
      required this.onBack,
      required this.onFormChanged});

  @override
  State<_Step4Pickup> createState() => _Step4PickupState();
}

class _Step4PickupState extends State<_Step4Pickup> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool get _canContinue {
    final start = widget.form.pickupStart;
    final end = widget.form.pickupEnd;
    final diff = (end.hour * 60 + end.minute) - (start.hour * 60 + start.minute);
    return widget.form.quantity >= 1 && diff >= 30;
  }

  Future<void> _selectTime(bool isStart) async {
    final initial = isStart ? widget.form.pickupStart : widget.form.pickupEnd;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF2D8659))),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) widget.form.pickupStart = picked;
        else widget.form.pickupEnd = picked;
      });
      widget.onFormChanged();
    }
  }

  void _applyPreset(int startH, int startM, int endH, int endM) {
    setState(() {
      widget.form.pickupStart = TimeOfDay(hour: startH, minute: startM);
      widget.form.pickupEnd = TimeOfDay(hour: endH, minute: endM);
    });
    widget.onFormChanged();
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour < 12 ? l10n.am_label : l10n.pm_label;
    final h12 = t.hour == 0 ? 12 : t.hour > 12 ? t.hour - 12 : t.hour;
    return '$h12:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2D8659);
    const accentBeige = Colors.white;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quantity_pickup_title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.quantity_pickup_desc,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),

          Text(l10n.quantity_label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryGreen, letterSpacing: 1)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade100)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StepperButton(icon: Icons.remove, color: Colors.grey, onTap: () { if (widget.form.quantity > 1) setState(() => widget.form.quantity--); widget.onFormChanged(); }),
                Text(l10n.count_bags(widget.form.quantity), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                _StepperButton(icon: Icons.add, color: primaryGreen, onTap: () { setState(() => widget.form.quantity++); widget.onFormChanged(); }),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Text(l10n.pickup_window_label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryGreen, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _TimeSelector(label: l10n.from_label.toUpperCase(), time: _fmtTime(widget.form.pickupStart), onTap: () => _selectTime(true))),
              const SizedBox(width: 16),
              Expanded(child: _TimeSelector(label: l10n.until_label.toUpperCase(), time: _fmtTime(widget.form.pickupEnd), onTap: () => _selectTime(false))),
            ],
          ),
          const SizedBox(height: 24),

          Text(l10n.quick_presets_label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryGreen, letterSpacing: 1)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PresetChip(label: l10n.preset_tonight, onTap: () => _applyPreset(18, 0, 20, 0)),
              _PresetChip(label: l10n.preset_morning, onTap: () => _applyPreset(8, 0, 10, 0)),
            ],
          ),
          const SizedBox(height: 40),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade200),
                    minimumSize: const Size(0, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(l10n.back_label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _canContinue ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: Text(l10n.continue_label.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF2D8659)),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100), side: const BorderSide(color: Color(0xFF2D8659), width: 0.5)),
    );
  }
}

// ── Step 5: Preview & Publish ─────────────────────────────────────────────────

class _Step5Preview extends StatefulWidget {
  final _ListingFormData form;
  final bool isPublishing;
  final Future<void> Function() onPublish;
  final VoidCallback onSaveDraft;
  final VoidCallback onBack;
  final VoidCallback onFormChanged;

  const _Step5Preview(
      {required this.form,
      required this.isPublishing,
      required this.onPublish,
      required this.onSaveDraft,
      required this.onBack,
      required this.onFormChanged});

  @override
  State<_Step5Preview> createState() => _Step5PreviewState();
}

class _Step5PreviewState extends State<_Step5Preview> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2D8659);
    const accentBeige = Colors.white;
    final l10n = AppLocalizations.of(context)!;
    final form = widget.form;
    final discount = form.originalPrice > 0 ? (1 - form.discountedPrice / form.originalPrice) * 100 : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.final_preview_title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.final_preview_desc,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),

          // Preview Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: form.imagePath.isNotEmpty
                            ? Image.file(File(form.imagePath), fit: BoxFit.cover)
                            : form.originalImageUrl.isNotEmpty
                                ? CachedNetworkImage(imageUrl: form.originalImageUrl, fit: BoxFit.cover)
                                : Container(color: accentBeige, child: const Icon(Icons.fastfood, size: 48, color: primaryGreen)),
                      ),
                      if (discount > 0)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(100)),
                            child: Text("-${discount.round()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(form.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text("${form.discountedPrice.toStringAsFixed(0)} ${l10n.currency_label}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryGreen)),
                          const SizedBox(width: 12),
                          Text("${form.originalPrice.toStringAsFixed(0)} ${l10n.currency_label}", style: TextStyle(fontSize: 16, decoration: TextDecoration.lineThrough, color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 16, color: primaryGreen),
                          const SizedBox(width: 8),
                          Text(l10n.pickup_range_msg("${form.pickupStart.hour}:${form.pickupStart.minute.toString().padLeft(2, '0')}", "${form.pickupEnd.hour}:${form.pickupEnd.minute.toString().padLeft(2, '0')}"), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: primaryGreen)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Confirmation
          GestureDetector(
            onTap: () { setState(() => form.safetyConfirmed = !form.safetyConfirmed); widget.onFormChanged(); },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: form.safetyConfirmed ? primaryGreen.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: form.safetyConfirmed ? primaryGreen : Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: form.safetyConfirmed ? primaryGreen : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: form.safetyConfirmed ? primaryGreen : Colors.grey.shade200),
                    ),
                    child: form.safetyConfirmed ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text(l10n.health_safety_confirmation, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151)))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),

          Row(
            children: [
              TextButton(
                onPressed: widget.onSaveDraft,
                child: Text(l10n.save_as_draft_action.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: form.safetyConfirmed && !widget.isPublishing ? widget.onPublish : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(180, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: widget.isPublishing
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l10n.publish_now_action.toUpperCase(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Success Screen ────────────────────────────────────────────────────────────

class _SuccessScreen extends StatefulWidget {
  final _ListingFormData form;
  final VoidCallback onAddAnother;
  final VoidCallback onViewListings;
  final VoidCallback onDone;

  const _SuccessScreen({
    required this.form,
    required this.onAddAnother,
    required this.onViewListings,
    required this.onDone,
  });

  @override
  State<_SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<_SuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2D8659);
    const backgroundColor = Colors.white;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: ConfettiOverlay(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle_rounded, color: primaryGreen, size: 80),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.listing_published_title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -1),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.listing_published_desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: widget.onAddAnother,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: Text(l10n.add_another_listing_action.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: widget.onDone,
                  child: Text(l10n.back_to_home_action.toUpperCase(), style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Small Supporting Widgets ──────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF374151),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool bold;

  const _BreakdownRow(
      {required this.label,
      required this.value,
      this.color,
      this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF6B7280))),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: color ?? const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}


class _StepperButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = AppTheme.primary;
    final isActive = color == primaryGreen;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive ? primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? primaryGreen : Colors.grey.shade200, width: 2),
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 24),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimeSelector({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2D8659);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 18, color: primaryGreen),
                const SizedBox(width: 8),
                Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _PresetButton({required this.label, required this.onTap, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2D8659);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryGreen : Colors.grey.shade100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}



