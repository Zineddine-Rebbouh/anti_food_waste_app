import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/shared/widgets/notification_bell_button.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
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

          // Determine greeting name and listing data from cubit state
          final String userName;
          final List<FoodListing> recommended;
          final List<FoodListing> nearBy;
          final String locationLabel;
          final bool isLoading;

          if (state is HomeLoaded) {
            userName = state.userName;
            recommended = state.recommended;
            nearBy = state.nearBy;
            locationLabel = state.locationLabel;
            isLoading = false;
          } else {
            userName = '';
            recommended = [];
            nearBy = [];
            locationLabel = 'Current Location';
            isLoading = state is HomeLoading || state is HomeInitial;
          }

          final offers = nearBy.isNotEmpty ? nearBy : recommended;

          return Scaffold(
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
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName.isNotEmpty
                                  ? l10n.welcome_back(userName)
                                  : l10n.find_deals_near_you,
                              style: TextStyle(
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

                      // Search Bar
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
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: SizedBox(
                                    height: 220,
                                    child: const ConsumerMapScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
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
                                      '${offers.length} offers',
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
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    l10n.no_deals_nearby,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              ...offers.map(
                                (listing) => ListingCard(
                                  listing: listing,
                                  isFavorite: favorites.isFavorite(listing.id),
                                  onFavoriteToggle: (next) {
                                    favorites.toggleFavorite(
                                      listing.id,
                                      desiredState: next,
                                    );
                                  },
                                  onTap: () {
                                    if (listing.id.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Invalid offer ID.'),
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ListingDetailScreen(listing: listing),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
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
                subtitle: const Text('Use Current Location (Default)'),
                onTap: () async {
                  Navigator.pop(context);
                  await _cubit.useCurrentLocation();
                },
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Select Saved Address'),
                onTap: () async {
                  Navigator.pop(context);
                  await _showSavedAddressesModal();
                },
              ),
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: const Text('Choose on Map'),
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
    List<UserAddress> addresses = [];
    try {
      addresses = await _repository.fetchAddresses();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load saved addresses.')),
      );
      return;
    }

    if (!mounted) return;
    if (addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved addresses found.')),
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
        const SnackBar(content: Text('Could not resolve this address location.')),
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


