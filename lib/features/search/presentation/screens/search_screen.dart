import 'dart:async';
import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/shared/widgets/notification_bell_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/core/providers/favorites_provider.dart';
import 'package:anti_food_waste_app/shared/widgets/listing_card.dart';
import 'package:anti_food_waste_app/shared/widgets/notification_panel.dart';
import 'package:anti_food_waste_app/shared/widgets/empty_state.dart';
import 'package:anti_food_waste_app/shared/widgets/map_view.dart';
import 'package:anti_food_waste_app/shared/widgets/filter_sheet.dart';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';
import 'package:anti_food_waste_app/features/consumer/data/repositories/consumer_repository.dart';
import 'package:anti_food_waste_app/features/home/presentation/screens/listing_detail_screen.dart';
import 'package:anti_food_waste_app/core/utils/error_handler.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final _repository = ConsumerRepository();

  // â”€â”€ State â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  List<FoodListing> _listings = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  Map<String, dynamic>? _activeFilters;

  // Debounce timer id so rapid typing doesn't spam the API
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchListings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // â”€â”€ Backend fetch â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _fetchListings() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final f = _activeFilters;
      final query = _searchController.text.trim();

      final results = await _repository.fetchListings(
        search: query.isNotEmpty ? query : null,
        category: _mapCategory(f),
        ordering: _mapOrdering(f),
        minRating: f?['minRating'] as double?,
        radius: f != null ? (f['radius'] as double) : null,
      );
      if (mounted) setState(() => _listings = results);
} catch (e) {
      if (mounted) setState(() {
        _hasError = true;
        _errorMessage = AppErrorHandler.getMessage(e);
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Convert filter category list â†’ single backend category string.
  String? _mapCategory(Map<String, dynamic>? f) {
    if (f == null) return null;
    final cats = f['categories'] as List<String>;
    return cats.isNotEmpty ? cats.join(',').toLowerCase() : null;
  }

  String? _mapOrdering(Map<String, dynamic>? f) {
    if (f == null) return null;
    final dMin = f['discountMin'] as double;
    if (dMin > 0) return '-discount_percentage';
    return null;
  }

  // â”€â”€ Search input â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _onSearchChanged(String _) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchListings();
    });
  }

  void _onSearchSubmitted(String _) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _fetchListings();
  }

  // â”€â”€ Filter sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSheet(initialFilters: _activeFilters),
    );
    if (result != null) {
      setState(() => _activeFilters = result);
      _fetchListings();
    }
  }

  void _clearFilters() {
    setState(() => _activeFilters = null);
    _fetchListings();
  }

  bool get _hasActiveFilters =>
      _activeFilters != null &&
      ((_activeFilters!['categories'] as List).isNotEmpty ||
          (_activeFilters!['dietary'] as List).isNotEmpty ||
          (_activeFilters!['minRating'] as double) > 0 ||
          (_activeFilters!['radius'] as double) != 5.0 ||
          (_activeFilters!['discountMin'] as double) != 0 ||
          (_activeFilters!['discountMax'] as double) != 100);

  // â”€â”€ Notifications â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationPanel(),
    );
  }

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favorites = context.watch<FavoritesProvider>();

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
          if (_hasActiveFilters)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear',
                  style: TextStyle(color: AppTheme.primary, fontSize: 13)),
            ),
          const NotificationBellButton(),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // â”€â”€ Search & Filter bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onSubmitted: _onSearchSubmitted,
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
                                _fetchListings();
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

          // â”€â”€ Active filter chips â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (_hasActiveFilters) _buildFilterChips(),

          // â”€â”€ Tabs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

          // â”€â”€ Tab content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Map View â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                MapView(
                  onListingTap: (listing) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingDetailScreen(listing: listing),
                    ),
                  ),
                  category: _mapCategory(_activeFilters),
                  // minRating: _activeFilters != null ? (_activeFilters!['minRating'] as double) : null,
                ),

                // List View â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _hasError
                        ? _buildErrorView()
                        : RefreshIndicator(
                            color: AppTheme.primary,
                            onRefresh: _fetchListings,
                            child: _listings.isEmpty
                                ? const EmptyState(
                                    type: EmptyStateType.noResults)
                                : ListView.builder(
                                    padding: const EdgeInsets.only(
                                        top: 8, bottom: 80),
                                    itemCount: _listings.length,
                                    itemBuilder: (context, i) {
                                      final l = _listings[i];
                                      return ListingCard(
                                        listing: l,
                                        isFavorite: favorites.isFavorite(l.id),
                                        onFavoriteToggle: (next) {
                                          favorites.toggleFavorite(
                                            l.id,
                                            desiredState: next,
                                          );
                                        },
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ListingDetailScreen(
                                                    listing: l),
                                          ),
                                        ),
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

  // â”€â”€ Filter chips strip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildFilterChips() {
    final f = _activeFilters!;
    final chips = <Widget>[];

    for (final cat in (f['categories'] as List<String>)) {
      chips.add(_FilterChip(
        label: cat,
        onRemove: () {
          final updated = Map<String, dynamic>.from(f);
          (updated['categories'] as List<String>).remove(cat);
          setState(() => _activeFilters = updated);
          _fetchListings();
        },
      ));
    }

    final radius = f['radius'] as double;
    if (radius != 5.0) {
      chips.add(_FilterChip(
        label: 'â‰¤ ${radius.toStringAsFixed(0)} km',
        onRemove: () {
          final updated = Map<String, dynamic>.from(f);
          updated['radius'] = 5.0;
          setState(() => _activeFilters = updated);
          _fetchListings();
        },
      ));
    }

    final dMin = f['discountMin'] as double;
    final dMax = f['discountMax'] as double;
    if (dMin != 0 || dMax != 100) {
      chips.add(_FilterChip(
        label:
            '${dMin.toStringAsFixed(0)}-${dMax.toStringAsFixed(0)}% off',
        onRemove: () {
          final updated = Map<String, dynamic>.from(f);
          updated['discountMin'] = 0.0;
          updated['discountMax'] = 100.0;
          setState(() => _activeFilters = updated);
          _fetchListings();
        },
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: chips,
      ),
    );
  }

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€



  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(_errorMessage ?? 'Could not load listings.',
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _fetchListings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Retry',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Filter chip widget â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close,
                size: 14, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }
}






