import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

class FilterSheet extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const FilterSheet({super.key, this.initialFilters});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late double _radius;
  late RangeValues _discountRange;
  late List<String> _selectedCategories;
  late List<String> _selectedDietary;
  late double _minRating;

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters;
    _radius = (f?['radius'] as double?) ?? 5.0;
    _discountRange = RangeValues(
      (f?['discountMin'] as double?) ?? 0.0,
      (f?['discountMax'] as double?) ?? 100.0,
    );
    _selectedCategories = List<String>.from(f?['categories'] ?? []);
    _selectedDietary = List<String>.from(f?['dietary'] ?? ['halal']);
    _minRating = (f?['minRating'] as double?) ?? 0.0;
  }

  void _clearAll() {
    setState(() {
      _radius = 5.0;
      _discountRange = const RangeValues(0, 100);
      _selectedCategories.clear();
      _selectedDietary
        ..clear()
        ..add('halal');
      _minRating = 0.0;
    });
  }

  int get _activeFilterCount {
    int count = 0;
    if (_radius != 5.0) count++;
    if (_selectedCategories.isNotEmpty) count++;
    if (_discountRange.start != 0 || _discountRange.end != 100) count++;
    if (!(_selectedDietary.length == 1 && _selectedDietary.contains('halal'))) {
      count++;
    }
    if (_minRating != 0.0) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.filter,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (_activeFilterCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l10n.active_filter_count(_activeFilterCount),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                TextButton(
                  onPressed: _clearAll,
                  child: Text(
                    l10n.clear_all,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Scrollable body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Distance ──────────────────────────────────────────
                  _buildSectionTitle('📍 ${l10n.distance}'),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _radius,
                          min: 1,
                          max: 20,
                          divisions: 19,
                          label: '${_radius.round()} ${l10n.km}',
                          activeColor: AppTheme.primary,
                          onChanged: (val) =>
                              setState(() => _radius = val),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_radius.round()} ${l10n.km}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Category ──────────────────────────────────────────
                  _buildSectionTitle('🍽️ ${l10n.category}'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      {'key': 'bakery', 'label': l10n.bakery},
                      {'key': 'restaurant', 'label': l10n.restaurant},
                      {'key': 'supermarket', 'label': l10n.supermarket},
                      {'key': 'cafe', 'label': l10n.cafe},
                    ].map((item) {
                      final key = item['key']!;
                      final isSelected = _selectedCategories.contains(key);
                      return _buildFilterChip(
                        label: item['label']!,
                        isSelected: isSelected,
                        onSelected: (val) => setState(() {
                          val
                              ? _selectedCategories.add(key)
                              : _selectedCategories.remove(key);
                        }),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ── Discount ──────────────────────────────────────────
                  _buildSectionTitle('💰 ${l10n.discount}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRangeLabel('${_discountRange.start.round()}%'),
                      _buildRangeLabel('${_discountRange.end.round()}%'),
                    ],
                  ),
                  RangeSlider(
                    values: _discountRange,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    labels: RangeLabels(
                      '${_discountRange.start.round()}%',
                      '${_discountRange.end.round()}%',
                    ),
                    activeColor: AppTheme.primary,
                    onChanged: (val) =>
                        setState(() => _discountRange = val),
                  ),

                  const SizedBox(height: 20),

                  // ── Dietary ───────────────────────────────────────────
                  _buildSectionTitle('🌱 ${l10n.dietary}'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      {'key': 'vegan', 'label': l10n.vegan},
                      {'key': 'halal', 'label': l10n.halal},
                      {'key': 'gluten_free', 'label': l10n.gluten_free},
                    ].map((item) {
                      final key = item['key']!;
                      final isSelected = _selectedDietary.contains(key);
                      return _buildFilterChip(
                        label: item['label']!,
                        isSelected: isSelected,
                        onSelected: (val) => setState(() {
                          val
                              ? _selectedDietary.add(key)
                              : _selectedDietary.remove(key);
                        }),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ── Min Rating ────────────────────────────────────────
                  _buildSectionTitle('⭐ ${l10n.min_rating}'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [0.0, 3.0, 4.0, 4.5].map((rating) {
                      final isSelected = _minRating == rating;
                      final label =
                          rating == 0.0 ? l10n.any_rating : '$rating+';
                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _minRating = rating),
                        selectedColor: AppTheme.primary.withOpacity(0.15),
                        backgroundColor: Colors.grey[100],
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primary
                              : Colors.grey.shade200,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primary
                              : Colors.grey[700],
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Apply button ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, {
                    'radius': _radius,
                    'categories': List<String>.from(_selectedCategories),
                    'discountMin': _discountRange.start,
                    'discountMax': _discountRange.end,
                    'dietary': List<String>.from(_selectedDietary),
                    'minRating': _minRating,
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.apply_filters,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required void Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: true,
      onSelected: onSelected,
      selectedColor: AppTheme.primary.withOpacity(0.15),
      checkmarkColor: AppTheme.primary,
      backgroundColor: Colors.grey[100],
      side: BorderSide(
        color: isSelected ? AppTheme.primary : Colors.grey.shade200,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primary : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRangeLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
            fontSize: 13),
      ),
    );
  }
}
