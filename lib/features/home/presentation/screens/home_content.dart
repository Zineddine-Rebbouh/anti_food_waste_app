import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/shared/widgets/notification_bell_button.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/core/providers/favorites_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';
import 'package:anti_food_waste_app/shared/widgets/listing_card.dart';
import 'package:anti_food_waste_app/shared/widgets/notification_panel.dart';
import 'package:anti_food_waste_app/features/consumer/data/repositories/consumer_repository.dart';
import 'package:anti_food_waste_app/features/profile/domain/models/user_address.dart';
import 'package:anti_food_waste_app/features/home/presentation/cubits/home_cubit.dart';
import 'package:anti_food_waste_app/features/home/presentation/screens/listing_detail_screen.dart';
import 'package:anti_food_waste_app/features/home/presentation/screens/consumer_map_screen.dart';
import 'package:anti_food_waste_app/features/home/presentation/screens/location_picker_map_screen.dart';
import 'package:anti_food_waste_app/features/search/presentation/screens/search_screen.dart' as anti_search;
import 'package:anti_food_waste_app/core/services/wilaya_service.dart';
import 'package:anti_food_waste_app/shared/widgets/tawfir_loading_indicator.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late final HomeCubit _cubit;
  final _repository = ConsumerRepository();

  @override
  void initState() {
    super.initState();
    _cubit = HomeCubit();
    _cubit.load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          final favorites = context.watch<FavoritesProvider>();

          final String userName;
          final List<FoodListing> recommended;
          final List<FoodListing> nearBy;
          final List<FoodListing> borderListings;
          final String locationLabel;
          final String? wilayaName;
          final bool isExpanded;
          final bool isLoading;

          if (state is HomeLoaded) {
            userName = state.userName;
            recommended = state.recommended;
            nearBy = state.nearBy;
            borderListings = state.borderListings;
            locationLabel = state.locationLabel;
            wilayaName = state.wilayaName;
            isExpanded = state.isExpanded;
            isLoading = false;
          } else {
            userName = '';
            recommended = [];
            nearBy = [];
            borderListings = [];
            locationLabel = _cubit.currentLocationLabel;
            wilayaName = null;
            isExpanded = false;
            isLoading = state is HomeLoading || state is HomeInitial;
          }

          final offers = nearBy;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.choose_location,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: _showLocationSelectionModal,
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppTheme.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          locationLabel,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down,
                            color: Colors.grey[400], size: 18),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(CupertinoIcons.bell,
                      size: 22, color: Colors.black87),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const NotificationPanel(),
                    );
                  },
                  tooltip: l10n.notifications,
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: isLoading
                ? const Center(child: TawfirLoadingIndicator(message: 'Loading deals...'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName.isNotEmpty
                                  ? l10n.welcome_back(userName)
                                  : l10n.find_deals_near_you,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.foreground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.find_deals_near_you,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const anti_search.SearchScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 0),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              enabled: false,
                              decoration: InputDecoration(
                                hintText: l10n.search_placeholder,
                                hintStyle: TextStyle(
                                    color: Colors.grey[500], fontSize: 14),
                                prefixIcon: Icon(Icons.search,
                                    color: Colors.grey[600], size: 22),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => _cubit.load(),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              if (isExpanded)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                  color: AppTheme.primary.withOpacity(0.1),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline, size: 16, color: AppTheme.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          l10n.showing_national_results,
                                          style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => _cubit.resetToMyArea(),
                                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                        child: Text(l10n.back_to_my_area),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: SizedBox(
                                    height: 220,
                                    child: ConsumerMapScreen(
                                      initialLat: state is HomeLoaded ? (state).userLat : null,
                                      initialLng: state is HomeLoaded ? (state).userLng : null,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (wilayaName != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.location_city, size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 6),
                                        Text(
                                          "WILAYA: $wilayaName".toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.0,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if (recommended.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.recommended_for_you,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                SizedBox(
                                  height: 380,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 0),
                                    itemCount: recommended.length,
                                    itemBuilder: (context, index) {
                                      final listing = recommended[index];
                                      return SizedBox(
                                        width: 310,
                                        child: ListingCard(
                                          listing: listing,
                                          isFavorite: favorites.isFavorite(listing.id),
                                          onFavoriteToggle: (next) => favorites.toggleFavorite(listing.id, desiredState: next),
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing)),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.near_you,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      l10n.offers_count(offers.length),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (offers.isEmpty)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.storefront_outlined,
                                          size: 48,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        l10n.no_deals_nearby,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ...offers.map(
                                (listing) => ListingCard(
                                  listing: listing,
                                  isFavorite: favorites.isFavorite(listing.id),
                                  onFavoriteToggle: (next) => favorites.toggleFavorite(listing.id, desiredState: next),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const SizedBox(height: 32),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primary.withOpacity(0.08),
                                        AppTheme.primary.withOpacity(0.01),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: AppTheme.primary.withOpacity(0.15), width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withOpacity(0.02),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.explore_outlined, size: 36, color: AppTheme.primary),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        l10n.want_to_see_more,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        l10n.explore_listings_other_wilayas,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.3),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed: () => _showExploreSheet(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            l10n.explore_national_feed,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
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

  void _showExploreSheet() {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.explore_algeria,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text(
                    l10n.quick_radius_search,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [10, 25, 50, 100].map((km) => ActionChip(
                      label: Text("$km km"),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary),
                      backgroundColor: AppTheme.primary.withOpacity(0.06),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: () {
                        Navigator.pop(context);
                        _cubit.expandToRadius(km);
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l10n.search_by_wilaya,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _repository.fetchWilayas(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: TawfirLoadingIndicator(size: 40, strokeWidth: 2.5));
                      final wilayas = snapshot.data!;
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: wilayas.length,
                        separatorBuilder: (context, index) => Divider(color: Colors.grey[100], height: 1),
                        itemBuilder: (context, i) {
                          final w = wilayas[i];
                          final displayName = isArabic 
                              ? (w['name_ar'] ?? w['name_fr'] ?? '') 
                              : (w['name_fr'] ?? w['name_ar'] ?? '');
                          
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            title: Text(
                              "${w['code']} - $displayName",
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[400]),
                            onTap: () {
                              Navigator.pop(context);
                              _cubit.expandToWilaya(w['code'], displayName);
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLocationSelectionModal() async {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.my_location),
                title: Text(l10n.enable_location_btn),
                subtitle: Text(l10n.use_current_location),
                onTap: () async {
                  Navigator.pop(context);
                  await _cubit.useCurrentLocation();
                },
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: Text(l10n.select_saved_address),
                onTap: () async {
                  Navigator.pop(context);
                  await _showSavedAddressesModal();
                },
              ),
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: Text(l10n.choose_on_map),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickLocationOnMap();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSavedAddressesModal() async {
    final l10n = AppLocalizations.of(context)!;
    var addresses = <UserAddress>[];
    try {
      addresses = await _repository.fetchAddresses();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.could_not_load_addresses)),
      );
      return;
    }

    if (!mounted) return;
    if (addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.no_saved_addresses)),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return ListTile(
                leading: const Icon(Icons.place_outlined),
                title: Text(address.label),
                subtitle: Text(address.fullAddress),
                onTap: () async {
                  Navigator.pop(context);
                  await _setAddressAsSelectedLocation(address);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _setAddressAsSelectedLocation(UserAddress address) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final results = await locationFromAddress(address.fullAddress);
      if (results.isEmpty) {
        throw Exception('No coordinates found');
      }

      final first = results.first;
      await _cubit.setSelectedLocation(
        lat: first.latitude,
        lng: first.longitude,
        label: '${address.label} - ${address.city}',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.could_not_resolve_address)),
      );
    }
  }

  Future<void> _pickLocationOnMap() async {
    final currentState = _cubit.state;
    double? lat;
    double? lng;
    if (currentState is HomeLoaded) {
      lat = currentState.userLat;
      lng = currentState.userLng;
    }

    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerMapScreen(
          initialLat: lat,
          initialLng: lng,
        ),
      ),
    );

    if (selected == null || !mounted) return;
    await _cubit.setSelectedLocation(
      lat: selected.latitude,
      lng: selected.longitude,
      label: 'Custom Location',
    );
  }
}
