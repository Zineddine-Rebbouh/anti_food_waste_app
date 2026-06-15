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
  State<CharityDonationsScreen> createState() => _CharityDonationsScreenState();
}

class _CharityDonationsScreenState extends State<CharityDonationsScreen> {
  static const Color _green = Color(0xFF2D8659);
  static const Color _beige = Colors.white;

  String _searchQuery = '';
  DonationCategory? _selectedCategory;
  bool _showUrgentOnly = false;

  final TextEditingController _searchController = TextEditingController();

  // ── Filtering ─────────────────────────────────────────────────────────────
  List<CharityDonation> _getFilteredDonations(List<CharityDonation> donations) {
    return donations.where((d) {
      final matchesSearch = _searchQuery.isEmpty ||
          d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.merchantName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || d.category == _selectedCategory;
      final matchesUrgency = !_showUrgentOnly || d.urgency != UrgencyLevel.normal;
      return matchesSearch && matchesCategory && matchesUrgency;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filter bottom sheet ───────────────────────────────────────────────────
  void _showFilterSheet(AppLocalizations l10n) {
    var tempCategory = _selectedCategory;
    var tempUrgentOnly = _showUrgentOnly;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(l10n.filter_donations,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),
                Text(l10n.donation_category,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: l10n.clear_all,
                      selected: tempCategory == null,
                      onTap: () => setSheetState(() => tempCategory = null),
                    ),
                    ..._buildCategoryChips(l10n).map(
                      (data) => _FilterChip(
                        label: data.label,
                        selected: tempCategory == data.category,
                        onTap: () => setSheetState(() => tempCategory = data.category),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(l10n.show_only_urgent,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(l10n.urgent_desc,
                          style: const TextStyle(fontSize: 13, color: AppTheme.mutedForeground)),
                    ),
                    Switch.adaptive(
                      value: tempUrgentOnly,
                      activeColor: _green,
                      onChanged: (v) => setSheetState(() => tempUrgentOnly = v),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
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
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(l10n.apply_filters,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
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
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CharityCubit, CharityState>(
      builder: (context, state) {
        if (state is CharityLoading) {
          return const Scaffold(
            backgroundColor: _beige,
            body: Center(child: CircularProgressIndicator(color: _green)),
          );
        }
        final rawDonations = state is CharityLoaded ? state.donations : <CharityDonation>[];
        final donations = _getFilteredDonations(rawDonations);

        return Scaffold(
          backgroundColor: _beige,
          body: Column(
            children: [
              // ── Premium green header ──────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 16, 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.charity_donations_title.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.charity_donations_title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5),
                            ),
                          ],
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14)),
                          child: IconButton(
                            icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                            onPressed: () => _showFilterSheet(l10n),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Search bar ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: l10n.search_donations,
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF), size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: _green, width: 1.5)),
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              // ── Filter chips ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 2),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: l10n.clear_all,
                        selected: !_showUrgentOnly && _selectedCategory == null,
                        onTap: () => setState(() {
                          _selectedCategory = null;
                          _showUrgentOnly = false;
                        }),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: l10n.urgent_filter,
                        selected: _showUrgentOnly,
                        onTap: () => setState(() => _showUrgentOnly = !_showUrgentOnly),
                      ),
                      const SizedBox(width: 8),
                      ..._buildCategoryChips(l10n).map(
                        (data) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: data.label,
                            selected: _selectedCategory == data.category,
                            onTap: () => setState(() {
                              _selectedCategory =
                                  _selectedCategory == data.category ? null : data.category;
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Results count ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      l10n.offers_count(donations.length),
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              // ── Donation list ─────────────────────────────────────────────
              Expanded(
                child: donations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_outlined,
                                size: 56, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              l10n.no_matching_donations,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 100),
                        itemCount: donations.length,
                        itemBuilder: (context, index) {
                          final item = donations[index];
                          return CharityDonationCard(
                            donation: item,
                            isRequested: state is CharityLoaded
                                ? state.myRequests.any((req) => req.donationId == item.id)
                                : false,
                            prominentImage: true,
                            onTap: () {
                              final cubit = context.read<CharityCubit>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: cubit,
                                    child: CharityDonationDetailScreen(donation: item),
                                  ),
                                ),
                              );
                            },
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
  _CategoryData(l10n.grocery, DonationCategory.grocery),
  _CategoryData(l10n.cafe, DonationCategory.cafe),
  _CategoryData(l10n.hotel, DonationCategory.hotel),
];

// ─── Reusable filter chip ─────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2D8659);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? green.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? green : Colors.grey.shade200,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? green : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}



