import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_cubit.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_state.dart';
import 'package:anti_food_waste_app/features/charity/presentation/widgets/charity_donation_card.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_donation_detail_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CharityDonationsScreen
// ─────────────────────────────────────────────────────────────────────────────
class CharityDonationsScreen extends StatefulWidget {
  const CharityDonationsScreen({super.key});

  @override
  State<CharityDonationsScreen> createState() =>
      _CharityDonationsScreenState();
}

class _CharityDonationsScreenState extends State<CharityDonationsScreen> {
  String _searchQuery = '';
  DonationCategory? _selectedCategory;
  bool _showUrgentOnly = false;

  final TextEditingController _searchController = TextEditingController();

  // ── Computed filtered list ────────────────────────────────────────────────
  List<CharityDonation> _getFilteredDonations(List<CharityDonation> donations) {
    return donations.where((d) {
      final matchesSearch = _searchQuery.isEmpty ||
          d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.merchantName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || d.category == _selectedCategory;
      final matchesUrgency =
          !_showUrgentOnly || d.urgency != UrgencyLevel.normal;
      return matchesSearch && matchesCategory && matchesUrgency;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filter bottom sheet ───────────────────────────────────────────────────
  void _showFilterSheet() {
    // Capture current values so the sheet can preview without committing
    DonationCategory? tempCategory = _selectedCategory;
    bool tempUrgentOnly = _showUrgentOnly;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title
                Text(
                  AppLocalizations.of(context)!.filter_donations,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // ── Category section ────────────────────────────────────────
                Text(
                  AppLocalizations.of(context)!.donation_category,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: AppLocalizations.of(context)!.clear_all,
                      selected: tempCategory == null,
                      onTap: () =>
                          setSheetState(() => tempCategory = null),
                    ),
                    ..._buildCategoryChips(AppLocalizations.of(ctx)!).map(
                      (data) => _FilterChip(
                        label: data.label,
                        selected: tempCategory == data.category,
                        onTap: () => setSheetState(
                            () => tempCategory = data.category),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Urgency section ─────────────────────────────────────────
                Text(
                  AppLocalizations.of(context)!.show_only_urgent,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.urgent_desc,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.mutedForeground),
                      ),
                    ),
                    Switch.adaptive(
                      value: tempUrgentOnly,
                      activeColor: AppTheme.primary,
                      onChanged: (v) =>
                          setSheetState(() => tempUrgentOnly = v),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Apply button ────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = tempCategory;
                        _showUrgentOnly = tempUrgentOnly;
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(ctx)!.apply_filters,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharityCubit, CharityState>(
      builder: (context, state) {
        if (state is CharityLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF6F6F8),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final List<CharityDonation> rawDonations = state is CharityLoaded ? state.donations : [];
        final donations = _getFilteredDonations(rawDonations);

        return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.charity_donations_title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Color(0xFF1A1A2E)),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.search_donations,
                filled: true,
                fillColor: AppTheme.inputBackground,
                prefixIcon: const Icon(Icons.search,
                    color: AppTheme.mutedForeground, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppTheme.mutedForeground, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppTheme.primary.withOpacity(0.4)),
                ),
              ),
            ),
          ),

          // ── Horizontal filter chips ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterChip(
                    label: AppLocalizations.of(context)!.clear_all,
                    selected:
                        !_showUrgentOnly && _selectedCategory == null,
                    onTap: () => setState(() {
                      _selectedCategory = null;
                      _showUrgentOnly = false;
                    }),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: AppLocalizations.of(context)!.urgent_filter,
                    selected: _showUrgentOnly,
                    onTap: () =>
                        setState(() => _showUrgentOnly = !_showUrgentOnly),
                  ),
                  const SizedBox(width: 8),
                  ..._buildCategoryChips(AppLocalizations.of(context)!).map(
                    (data) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: data.label,
                        selected: _selectedCategory == data.category,
                        onTap: () => setState(() {
                          _selectedCategory =
                              _selectedCategory == data.category
                                  ? null
                                  : data.category;
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Results count ───────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${donations.length} ${AppLocalizations.of(context)!.charity_donations_title.toLowerCase()}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.mutedForeground),
            ),
          ),

          // ── Donation list ───────────────────────────────────────────────
          Expanded(
            child: donations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_outlined,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.no_matching_donations,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.only(top: 4, bottom: 24),
                    itemCount: donations.length,
                    itemBuilder: (context, index) {
                      final item = donations[index];
                      return CharityDonationCard(
                        donation: item,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CharityDonationDetailScreen(
                                    donation: item),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
      },
    );
  }
}

// ─── Category chip metadata ───────────────────────────────────────────────────
class _CategoryData {
  final String label;
  final DonationCategory category;
  const _CategoryData(this.label, this.category);
}

List<_CategoryData> _buildCategoryChips(AppLocalizations l10n) => [
  _CategoryData(l10n.bakery, DonationCategory.bakery),
  _CategoryData(l10n.restaurant, DonationCategory.restaurant),
  _CategoryData('Grocery', DonationCategory.grocery),
  _CategoryData(l10n.cafe, DonationCategory.cafe),
  _CategoryData(l10n.hotel, DonationCategory.hotel),
];

// ─── Reusable filter chip ─────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withOpacity(0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : Colors.grey.shade300,
            width: selected ? 1.4 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? AppTheme.primary
                : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
