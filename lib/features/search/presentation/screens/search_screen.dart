import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/shared/widgets/listing_card.dart';
import 'package:anti_food_waste_app/shared/widgets/notification_panel.dart';
import 'package:anti_food_waste_app/shared/widgets/empty_state.dart';
import 'package:anti_food_waste_app/shared/widgets/map_view.dart';
import 'package:anti_food_waste_app/shared/widgets/filter_sheet.dart';
import 'package:anti_food_waste_app/shared/data/mock_listings.dart';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';
import 'package:anti_food_waste_app/features/home/presentation/screens/listing_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<FoodListing> _filteredListings = mockListings;
  Map<String, dynamic>? _activeFilters;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtering logic ────────────────────────────────────────────────────
  void _onSearchChanged(String _) => _applySearch();

  void _applySearch() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredListings = mockListings.where((listing) {
        // Text search
        if (query.isNotEmpty) {
          final matchesQuery =
              listing.title.toLowerCase().contains(query) ||
                  listing.merchantName.toLowerCase().contains(query);
          if (!matchesQuery) return false;
        }

        // Filter sheet results
        if (_activeFilters != null) {
          final f = _activeFilters!;

          // Distance
          if (listing.distance > (f['radius'] as double)) return false;

          // Category
          final cats = f['categories'] as List<String>;
          if (cats.isNotEmpty && !cats.contains(listing.category.name)) {
            return false;
          }

          // Discount
          final dMin = f['discountMin'] as double;
          final dMax = f['discountMax'] as double;
          if (listing.discountPercent < dMin ||
              listing.discountPercent > dMax) {
            return false;
          }

          // Dietary (listing must have at least one of the chosen dietary)
          final dietary = f['dietary'] as List<String>;
          if (dietary.isNotEmpty) {
            final hasMatch = dietary.any((filter) => listing.dietary.any(
                (d) => d.toLowerCase().contains(filter.replaceAll('_', ' '))));
            if (!hasMatch) return false;
          }

          // Min rating
          if (listing.rating < (f['minRating'] as double)) return false;
        }

        return true;
      }).toList();
    });
  }

  // ── Filter sheet ───────────────────────────────────────────────────────
  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          FilterSheet(initialFilters: _activeFilters),
    );
    if (result != null) {
      _activeFilters = result;
      _applySearch();
    }
  }

  // ── Notification panel ────────────────────────────────────────────────
  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationPanel(),
    );
  }

  bool get _hasActiveFilters =>
      _activeFilters != null &&
      ((_activeFilters!['categories'] as List).isNotEmpty ||
          (_activeFilters!['dietary'] as List).isNotEmpty ||
          (_activeFilters!['minRating'] as double) > 0 ||
          (_activeFilters!['radius'] as double) != 5.0 ||
          (_activeFilters!['discountMin'] as double) != 0 ||
          (_activeFilters!['discountMax'] as double) != 100);

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.search,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.bell, size: 22, color: Colors.black87),
            onPressed: _showNotifications,
            tooltip: l10n.notifications,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ── Search & Filter bar ─────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.search_placeholder,
                      prefixIcon: Icon(Icons.search,
                          color: Colors.grey[500], size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              color: Colors.grey,
                              onPressed: () {
                                _searchController.clear();
                                _applySearch();
                              },
                            )
                          : null,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Filter button with active badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _hasActiveFilters
                              ? AppTheme.primary
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        color: _hasActiveFilters
                            ? AppTheme.primary.withOpacity(0.08)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune_rounded,
                          color: _hasActiveFilters
                              ? AppTheme.primary
                              : Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: _showFilterSheet,
                        tooltip: l10n.filter,
                      ),
                    ),
                    if (_hasActiveFilters)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ── Tabs ──────────────────────────────────────────────────────
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map_outlined, size: 17),
                    const SizedBox(width: 6),
                    Text(l10n.map_view),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.list_rounded, size: 17),
                    const SizedBox(width: 6),
                    Text(l10n.list_view),
                  ],
                ),
              ),
            ],
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),

          // ── Tab content ───────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Map View ─────────────────────────────────────────────
                MapView(
                  listings: _filteredListings,
                  onListingTap: (listing) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ListingDetailScreen(listing: listing),
                      ),
                    );
                  },
                ),

                // List View ────────────────────────────────────────────
                RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 1));
                    if (mounted) _applySearch();
                  },
                  child: _filteredListings.isEmpty
                      ? const EmptyState(type: EmptyStateType.noResults)
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 80),
                          itemCount: _filteredListings.length,
                          itemBuilder: (context, index) {
                            final listing = _filteredListings[index];
                            return ListingCard(
                              listing: listing,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ListingDetailScreen(
                                            listing: listing),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
