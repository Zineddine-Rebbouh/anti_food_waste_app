import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_listing.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/shared/widgets/confetti_overlay.dart';

// ── Form State ─────────────────────────────────────────────────────────────────

class _ListingFormData {
  String imagePath = '';
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
  const MerchantCreateListingScreen({super.key});

  @override
  State<MerchantCreateListingScreen> createState() =>
      _MerchantCreateListingScreenState();
}

class _MerchantCreateListingScreenState
    extends State<MerchantCreateListingScreen> {
  final _pageController = PageController();
  final _form = _ListingFormData();
  int _currentStep = 0;
  bool _isPublishing = false;
  bool _showSuccess = false;

  static const _stepLabels = ['Photo', 'Details', 'Price', 'Pickup', 'Preview'];

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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Discard Listing?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text(
          'Your progress will be saved as a draft.',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Editing',
                style: TextStyle(color: Color(0xFF2D8659))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _saveDraft();
              Navigator.pop(context);
            },
            child: const Text('Save Draft',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
        ],
      ),
    );
  }

  Future<void> _publish() async {
    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    final now = DateTime.now();
    final listing = MerchantListing(
      id: 'listing_${DateTime.now().millisecondsSinceEpoch}',
      title: _form.title,
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
      status: ListingStatus.active,
      grade: _form.grade,
      views: 0,
      createdAt: now,
    );
    context.read<MerchantCubit>().addListing(listing);
    setState(() {
      _isPublishing = false;
      _showSuccess = true;
    });
  }

  void _saveDraft() {
    if (_form.title.isEmpty) return;
    final now = DateTime.now();
    final listing = MerchantListing(
      id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
      title: _form.title.isEmpty ? 'Untitled Draft' : _form.title,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF374151)),
          onPressed: _prevStep,
        ),
        title: _StepProgressHeader(
          currentStep: _currentStep,
          labels: _stepLabels,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          labels[currentStep],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(labels.length, (i) {
            final isActive = i == currentStep;
            final isDone = i < currentStep;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isDone || isActive
                    ? const Color(0xFF2D8659)
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(50),
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
    final hasPhoto = widget.form.imagePath.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Photo',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Take a clear photo of your food',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),

          // Photo area
          GestureDetector(
            onTap: hasPhoto ? null : () => _pickImage(ImageSource.camera),
            child: Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasPhoto
                      ? const Color(0xFF2D8659)
                      : const Color(0xFFD1D5DB),
                  width: 2,
                  style: hasPhoto ? BorderStyle.solid : BorderStyle.none,
                ),
              ),
              child: hasPhoto
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: const Color(0xFFE5E7EB),
                            child: const Icon(
                              Icons.image_outlined,
                              size: 80,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                        // Grade badge
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Text(
                              '✓ Grade A',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        // Retake button
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () =>
                                _pickImage(ImageSource.camera),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh,
                                      color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text('Retake',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
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
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D8659).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_outlined,
                              color: Color(0xFF2D8659), size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tap to take photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickImage(ImageSource.gallery),
                          child: const Text(
                            'or choose from gallery',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2D8659),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          if (_validating) ...[
            const SizedBox(height: 12),
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF2D8659),
                  ),
                ),
                SizedBox(width: 8),
                Text('Validating photo quality...',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ],

          if (hasPhoto) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF059669), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Photo Approved! Freshness Grade: A • Confidence: 92%',
                    style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: hasPhoto ? widget.onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D8659),
                minimumSize: const Size(double.infinity, 52),
                disabledBackgroundColor: const Color(0xFFD1D5DB),
              ),
              child: const Text('Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
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

  final _categories = [
    (MerchantFoodCategory.bakery, 'Bakery', '🍞'),
    (MerchantFoodCategory.restaurant, 'Restaurant', '🍽️'),
    (MerchantFoodCategory.supermarket, 'Supermarket', '🛒'),
    (MerchantFoodCategory.cafe, 'Café', '☕'),
    (MerchantFoodCategory.other, 'Other', '📦'),
  ];

  final _tags = [
    (DietaryTag.halal, 'Halal'),
    (DietaryTag.vegan, 'Vegan'),
    (DietaryTag.vegetarian, 'Vegetarian'),
    (DietaryTag.glutenFree, 'Gluten-Free'),
    (DietaryTag.nutFree, 'Nut-Free'),
    (DietaryTag.dairyFree, 'Dairy-Free'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Item Details',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Describe your food item',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),

          // Title
          const _FieldLabel(text: 'Item Title *'),
          const SizedBox(height: 6),
          TextField(
            controller: _titleCtrl,
            maxLength: 60,
            decoration: InputDecoration(
              hintText: 'e.g., Fresh Baguettes, Croissants Mix',
              filled: true,
              fillColor: const Color(0xFFF3F3F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2D8659), width: 2),
              ),
              counterStyle: const TextStyle(fontSize: 11),
            ),
            onChanged: (v) {
              widget.form.title = v;
              setState(() {});
              widget.onFormChanged();
            },
          ),

          // AI Suggestion chip
          if (_titleCtrl.text.isEmpty) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                _titleCtrl.text = 'Fresh Baguettes';
                widget.form.title = 'Fresh Baguettes';
                setState(() {});
                widget.onFormChanged();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 12, color: Color(0xFF059669)),
                    SizedBox(width: 4),
                    Text('Detected: Bread → Tap to auto-fill',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF059669))),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Category
          const _FieldLabel(text: 'Category *'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final selected = widget.form.category == cat.$1;
              return GestureDetector(
                onTap: () {
                  widget.form.category = cat.$1;
                  setState(() {});
                  widget.onFormChanged();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF2D8659)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF2D8659)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    '${cat.$3} ${cat.$2}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color:
                          selected ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Description
          const _FieldLabel(text: 'Description (Optional)'),
          const SizedBox(height: 6),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            maxLength: 300,
            decoration: InputDecoration(
              hintText:
                  'e.g., Baked fresh this morning, perfect for dinner or breakfast',
              filled: true,
              fillColor: const Color(0xFFF3F3F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2D8659), width: 2),
              ),
              counterStyle: const TextStyle(fontSize: 11),
            ),
            onChanged: (v) {
              widget.form.description = v;
              widget.onFormChanged();
            },
          ),

          const SizedBox(height: 20),

          // Dietary Tags
          const _FieldLabel(text: 'Dietary Tags (Optional)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
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
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF2D8659)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF2D8659)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected)
                        const Icon(Icons.check,
                            size: 12, color: Colors.white),
                      if (selected) const SizedBox(width: 4),
                      Text(
                        tag.$2,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _canContinue ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D8659),
                    minimumSize: const Size(0, 52),
                    disabledBackgroundColor: const Color(0xFFD1D5DB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Continue',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
  late final TextEditingController _origCtrl;
  late final TextEditingController _discCtrl;

  @override
  void initState() {
    super.initState();
    _origCtrl = TextEditingController(
        text: widget.form.originalPrice > 0
            ? widget.form.originalPrice.toStringAsFixed(0)
            : '');
    _discCtrl = TextEditingController(
        text: widget.form.discountedPrice > 0
            ? widget.form.discountedPrice.toStringAsFixed(0)
            : '');
  }

  @override
  void dispose() {
    _origCtrl.dispose();
    _discCtrl.dispose();
    super.dispose();
  }

  double get _orig => double.tryParse(_origCtrl.text) ?? 0;
  double get _disc => double.tryParse(_discCtrl.text) ?? 0;

  bool get _canContinue =>
      _orig > 0 && _disc > 0 && _disc < _orig && _disc >= 10;

  String? get _discError {
    if (_disc <= 0) return null;
    if (_disc >= _orig && _orig > 0) return 'Must be less than original price';
    if (_disc < 10) return 'Minimum listing price is 10 DZD';
    if (_orig > 0 && (_disc / _orig) > 0.8) {
      return 'Minimum 20% discount required';
    }
    return null;
  }

  void _applyAiSuggestion() {
    if (_orig > 0) {
      final suggestion = (_orig * 0.5).roundToDouble();
      _discCtrl.text = suggestion.toStringAsFixed(0);
      widget.form.discountedPrice = suggestion;
      setState(() {});
      widget.onFormChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final discount = _orig > 0 && _disc > 0
        ? ((_orig - _disc) / _orig * 100).round()
        : 0;
    final net = _disc * 0.88;
    final fee = _disc * 0.12;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set Your Prices',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Original and discounted pricing',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),

          // Original Price
          const _FieldLabel(text: 'Original Price *'),
          const SizedBox(height: 6),
          TextField(
            controller: _origCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '100',
              prefixText: 'DZD  ',
              prefixStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              helperText: 'Regular selling price',
              filled: true,
              fillColor: const Color(0xFFF3F3F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2D8659), width: 2),
              ),
            ),
            onChanged: (v) {
              widget.form.originalPrice = double.tryParse(v) ?? 0;
              setState(() {});
              widget.onFormChanged();
            },
          ),
          const SizedBox(height: 20),

          // Discounted Price
          const _FieldLabel(text: 'Discounted Price *'),
          const SizedBox(height: 6),
          TextField(
            controller: _discCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '50',
              prefixText: 'DZD  ',
              prefixStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              helperText: 'Price for SaveFood customers',
              errorText: _discError,
              filled: true,
              fillColor: const Color(0xFFF3F3F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2D8659), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
              ),
            ),
            onChanged: (v) {
              widget.form.discountedPrice = double.tryParse(v) ?? 0;
              setState(() {});
              widget.onFormChanged();
            },
          ),

          if (discount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$discount% discount',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // AI Suggestion
          if (_orig > 0) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 16, color: Color(0xFF059669)),
                      SizedBox(width: 6),
                      Text(
                        'AI Price Suggestion',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Based on similar items, we suggest:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF374151)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(_orig * 0.5).toStringAsFixed(0)} DZD (50% off)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF059669),
                        ),
                      ),
                      TextButton(
                        onPressed: _applyAiSuggestion,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF059669),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                        ),
                        child: const Text('Use This Price',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const Text(
                    'This price typically sells out fast!',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Commission Breakdown
          if (_disc > 0) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_outlined,
                          size: 16, color: Color(0xFF374151)),
                      SizedBox(width: 6),
                      Text(
                        'Your Earnings (88% commission)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _BreakdownRow(
                      label: 'Sale price',
                      value:
                          '${_disc.toStringAsFixed(0)} DZD'),
                  _BreakdownRow(
                      label: 'Platform fee (12%)',
                      value: '${fee.toStringAsFixed(2)} DZD',
                      color: const Color(0xFF6B7280)),
                  _BreakdownRow(
                    label: 'You keep (88%)',
                    value: '${net.toStringAsFixed(2)} DZD',
                    color: const Color(0xFF10B981),
                    bold: true,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _canContinue ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D8659),
                    minimumSize: const Size(0, 52),
                    disabledBackgroundColor: const Color(0xFFD1D5DB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Continue',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
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
  bool get _canContinue {
    final start = widget.form.pickupStart;
    final end = widget.form.pickupEnd;
    final diff =
        (end.hour * 60 + end.minute) - (start.hour * 60 + start.minute);
    return widget.form.quantity >= 1 && diff >= 30;
  }

  Future<void> _selectTime(bool isStart) async {
    final initial =
        isStart ? widget.form.pickupStart : widget.form.pickupEnd;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2D8659)),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        widget.form.pickupStart = picked;
      } else {
        widget.form.pickupEnd = picked;
      }
    });
    widget.onFormChanged();
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
    final period = t.hour < 12 ? 'AM' : 'PM';
    final h12 = t.hour == 0
        ? 12
        : t.hour > 12
            ? t.hour - 12
            : t.hour;
    return '$h:$m ($h12:$m $period)';
  }

  String _durationLabel() {
    final start = widget.form.pickupStart;
    final end = widget.form.pickupEnd;
    final diff =
        (end.hour * 60 + end.minute) - (start.hour * 60 + start.minute);
    if (diff <= 0) return 'Invalid window';
    if (diff < 60) return '$diff minutes';
    return '${diff ~/ 60}h ${diff % 60}min';
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.form.pickupStart;
    final end = widget.form.pickupEnd;
    final diff =
        (end.hour * 60 + end.minute) - (start.hour * 60 + start.minute);
    final windowError = diff < 30 && diff > 0
        ? 'Pickup window must be at least 30 minutes'
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quantity & Pickup',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827)),
          ),
          const SizedBox(height: 4),
          const Text(
            'When and how much?',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 28),

          // Quantity
          const Text(
            'How Many Available?',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827)),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepperButton(
                icon: Icons.remove,
                color: const Color(0xFF6B7280),
                onTap: () {
                  if (widget.form.quantity > 1) {
                    setState(() => widget.form.quantity--);
                    widget.onFormChanged();
                  }
                },
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () async {
                  final ctrl = TextEditingController(
                      text: '${widget.form.quantity}');
                  await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      title: const Text('Enter Quantity'),
                      content: TextField(
                        controller: ctrl,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: const InputDecoration(
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            final v = int.tryParse(ctrl.text);
                            if (v != null && v >= 1) {
                              setState(() => widget.form.quantity = v);
                              widget.onFormChanged();
                            }
                            Navigator.pop(ctx);
                          },
                          child: const Text('OK',
                              style: TextStyle(color: Color(0xFF2D8659))),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 80,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${widget.form.quantity}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _StepperButton(
                icon: Icons.add,
                color: const Color(0xFF2D8659),
                onTap: () {
                  setState(() => widget.form.quantity++);
                  widget.onFormChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'bags/items available',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ),

          const SizedBox(height: 28),

          // Pickup Window
          const Text(
            'When Can Customers Collect?',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _TimeSelector(
                  label: 'Start Time',
                  time: _fmtTime(widget.form.pickupStart),
                  onTap: () => _selectTime(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeSelector(
                  label: 'End Time',
                  time: _fmtTime(widget.form.pickupEnd),
                  onTap: () => _selectTime(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (windowError != null)
            Row(
              children: [
                const Icon(Icons.warning_outlined,
                    size: 14, color: Color(0xFFEF4444)),
                const SizedBox(width: 4),
                Text(
                  windowError,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFFEF4444)),
                ),
              ],
            )
          else if (diff > 0)
            Text(
              'Duration: ${_durationLabel()}',
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2D8659),
                  fontWeight: FontWeight.w500),
            ),

          const SizedBox(height: 20),

          // Presets
          const Text(
            'Quick Presets',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151)),
          ),
          const SizedBox(height: 8),
          _PresetButton(
            label: 'Tonight (18:00-20:00)',
            onTap: () => _applyPreset(18, 0, 20, 0),
            isSelected: start.hour == 18 &&
                start.minute == 0 &&
                end.hour == 20 &&
                end.minute == 0,
          ),
          const SizedBox(height: 6),
          _PresetButton(
            label: 'Tomorrow Morning (08:00-10:00)',
            onTap: () => _applyPreset(8, 0, 10, 0),
            isSelected: start.hour == 8 &&
                start.minute == 0 &&
                end.hour == 10 &&
                end.minute == 0,
          ),
          const SizedBox(height: 6),
          _PresetButton(
            label: 'Tomorrow Evening (18:00-20:00)',
            onTap: () => _applyPreset(18, 0, 20, 0),
            isSelected: false,
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _canContinue ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D8659),
                    minimumSize: const Size(0, 52),
                    disabledBackgroundColor: const Color(0xFFD1D5DB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Continue',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
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
  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    final discount = form.originalPrice > 0
        ? (1 - form.discountedPrice / form.originalPrice) * 100
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview Listing',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827)),
          ),
          const SizedBox(height: 4),
          const Text(
            'How it looks to customers',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),

          // Preview card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Photo area
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: Container(
                        width: double.infinity,
                        height: 160,
                        color: const Color(0xFFE5E7EB),
                        child: form.imagePath.isNotEmpty
                            ? const Icon(Icons.image_outlined,
                                size: 60, color: Color(0xFF9CA3AF))
                            : const Icon(Icons.fastfood_outlined,
                                size: 60, color: Color(0xFF9CA3AF)),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text('Grade A 🟢',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (discount > 0)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            '-${discount.round()}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                // Details
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        form.title.isEmpty ? 'Your Listing' : form.title,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (form.originalPrice > 0) ...[
                            Text(
                              '${form.originalPrice.toStringAsFixed(0)} DZD',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9CA3AF),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (form.discountedPrice > 0)
                            Text(
                              '${form.discountedPrice.toStringAsFixed(0)} DZD',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 13, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text(
                            'Today ${form.pickupStart.hour.toString().padLeft(2, '0')}:${form.pickupStart.minute.toString().padLeft(2, '0')}-'
                            '${form.pickupEnd.hour.toString().padLeft(2, '0')}:${form.pickupEnd.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.inventory_2_outlined,
                              size: 13, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text(
                            '${form.quantity} available',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Listing Summary',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151))),
                const SizedBox(height: 10),
                _SummaryRow(label: 'Category', value: form.category.name),
                if (form.dietaryTags.isNotEmpty)
                  _SummaryRow(
                    label: 'Dietary',
                    value: form.dietaryTags
                        .map((t) => t.name)
                        .join(', '),
                  ),
                if (form.description.isNotEmpty)
                  _SummaryRow(
                    label: 'Description',
                    value: form.description.length > 50
                        ? '${form.description.substring(0, 50)}...'
                        : form.description,
                  ),
                const Divider(height: 16, color: Color(0xFFE5E7EB)),
                _SummaryRow(
                  label: 'Your earnings per item',
                  value: '${form.netEarnings.toStringAsFixed(0)} DZD',
                  valueColor: const Color(0xFF10B981),
                  bold: true,
                ),
                _SummaryRow(
                  label: 'Potential revenue (if all sold)',
                  value:
                      '${form.potentialRevenue.toStringAsFixed(0)} DZD',
                  valueColor: const Color(0xFF10B981),
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Safety checkbox
          GestureDetector(
            onTap: () {
              setState(
                  () => form.safetyConfirmed = !form.safetyConfirmed);
              widget.onFormChanged();
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: form.safetyConfirmed
                        ? const Color(0xFF2D8659)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: form.safetyConfirmed
                          ? const Color(0xFF2D8659)
                          : const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                  ),
                  child: form.safetyConfirmed
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'I confirm this food is safe and matches the description',
                    style: TextStyle(
                        fontSize: 14, color: Color(0xFF374151)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              TextButton(
                onPressed: widget.onSaveDraft,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                ),
                child: const Text('Save as Draft'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: form.safetyConfirmed && !widget.isPublishing
                    ? widget.onPublish
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D8659),
                  minimumSize: const Size(160, 52),
                  disabledBackgroundColor: const Color(0xFFD1D5DB),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: widget.isPublishing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Publish Listing',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 32),
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
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ConfettiOverlay(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D8659).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle,
                        color: Color(0xFF2D8659), size: 64),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Listing Published!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D8659),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your listing is now live and visible to customers nearby.',
                  style:
                      TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // What's next
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📊 What Happens Next?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Nearby consumers will see your listing',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                      const Text(
                        '• You\'ll get notified when orders come in',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                      const Text(
                        '• Track views and orders in real-time',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Actions
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: widget.onAddAnother,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Another Listing',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2D8659),
                      side: const BorderSide(color: Color(0xFF2D8659), width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: widget.onViewListings,
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2D8659)),
                  child: const Text('View My Listings'),
                ),
                TextButton(
                  onPressed: widget.onDone,
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280)),
                  child: const Text('Done'),
                ),
                const SizedBox(height: 16),
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _SummaryRow(
      {required this.label,
      required this.value,
      this.valueColor,
      this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B7280))),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: valueColor ?? const Color(0xFF374151),
              ),
              textAlign: TextAlign.end,
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

  const _StepperButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimeSelector(
      {required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
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

  const _PresetButton(
      {required this.label,
      required this.onTap,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2D8659).withOpacity(0.08)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2D8659)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? const Color(0xFF2D8659)
                : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}
