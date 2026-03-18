import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_listing.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/create_listing/merchant_create_listing_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/widgets/merchant_listing_card.dart';

class MerchantListingsScreen extends StatefulWidget {
  const MerchantListingsScreen({super.key});

  @override
  State<MerchantListingsScreen> createState() => _MerchantListingsScreenState();
}

class _MerchantListingsScreenState extends State<MerchantListingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MerchantCubit, MerchantState>(
      builder: (context, state) {
        if (state is MerchantLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is MerchantError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<MerchantCubit>().load(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state is! MerchantLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'My Listings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF2D8659), size: 28),
                onPressed: () => _openCreateListing(context),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: const Color(0xFF2D8659),
              indicatorWeight: 3,
              labelColor: const Color(0xFF2D8659),
              unselectedLabelColor: const Color(0xFF6B7280),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 13,
              ),
              tabs: [
                Tab(text: 'Active (${state.activeListings.length})'),
                Tab(text: 'Sold Out (${state.soldOutListings.length})'),
                Tab(text: 'Expired'),
                Tab(
                    text: state.draftListings.isNotEmpty
                        ? 'Drafts (${state.draftListings.length})'
                        : 'Drafts'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _ListingsTab(
                listings: state.activeListings,
                emptyTitle: 'No Active Listings',
                emptySubtitle:
                    'Create your first listing to start selling surplus food!',
                onMenuTap: (listing) =>
                    _showListingMenu(context, listing, state),
              ),
              _ListingsTab(
                listings: state.soldOutListings,
                emptyTitle: 'No Sold Out Listings',
                emptySubtitle: 'All items are still available.',
                onMenuTap: (listing) =>
                    _showListingMenu(context, listing, state),
              ),
              _ListingsTab(
                listings: state.expiredListings,
                emptyTitle: 'No Expired Listings',
                emptySubtitle: 'Any expired listings will appear here.',
                onMenuTap: (listing) =>
                    _showListingMenu(context, listing, state),
              ),
              _ListingsTab(
                listings: state.draftListings,
                emptyTitle: 'No Drafts',
                emptySubtitle: 'Unfinished listings will be saved here.',
                onMenuTap: (listing) =>
                    _showListingMenu(context, listing, state),
              ),
            ],
          ),

        );
      },
    );
  }

  void _openCreateListing(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BlocProvider.value(
          value: context.read<MerchantCubit>(),
          child: const MerchantCreateListingScreen(),
        ),
      ),
    );
  }

  void _showListingMenu(
      BuildContext context, MerchantListing listing, MerchantLoaded state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (listing.status == ListingStatus.active) ...[
                _MenuOption(
                  icon: Icons.edit_outlined,
                  label: 'Edit Listing',
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _openCreateListing(context);
                  },
                ),
                _MenuOption(
                  icon: Icons.pause_circle_outline,
                  label: 'Pause Listing',
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    context.read<MerchantCubit>().pauseListing(listing.id);
                    _showToast(context, 'Listing paused');
                  },
                ),
                _MenuOption(
                  icon: Icons.volunteer_activism_outlined,
                  label: 'Mark as Donation',
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _confirmDonation(context, listing);
                  },
                ),
                _MenuOption(
                  icon: Icons.copy_outlined,
                  label: 'Duplicate Listing',
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _showToast(context, 'Listing duplicated as draft');
                  },
                ),
              ] else if (listing.status == ListingStatus.soldOut ||
                  listing.status == ListingStatus.expired) ...[
                _MenuOption(
                  icon: Icons.refresh_outlined,
                  label: 'Relist',
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _openCreateListing(context);
                  },
                ),
              ],
              _MenuOption(
                icon: Icons.delete_outline,
                label: 'Delete Listing',
                color: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _confirmDelete(context, listing);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, MerchantListing listing) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete Listing?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "This will permanently delete '${listing.title}'. This action cannot be undone.",
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MerchantCubit>().deleteListing(listing.id);
              _showToast(context, 'Listing deleted');
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  void _confirmDonation(BuildContext context, MerchantListing listing) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Mark as Donation?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Mark ${listing.availableQuantity} remaining items of "${listing.title}" as donation? Nearby charities will be notified.',
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MerchantCubit>().markAsDonation(listing.id);
              _showToast(context, 'Charities notified of your donation!');
            },
            child: const Text('Confirm',
                style: TextStyle(
                    color: Color(0xFF2D8659), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1F2937),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ── Tab Content ───────────────────────────────────────────────────────────────

class _ListingsTab extends StatelessWidget {
  final List<MerchantListing> listings;
  final String emptyTitle;
  final String emptySubtitle;
  final VoidCallback? onAddTap;
  final Function(MerchantListing)? onMenuTap;

  const _ListingsTab({
    required this.listings,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.onAddTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory_2_outlined,
                  size: 72, color: Color(0xFFD1D5DB)),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                textAlign: TextAlign.center,
              ),
              if (onAddTap != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: onAddTap,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add New Listing'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 48),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: listings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final listing = listings[i];
        return MerchantListingCard(
          listing: listing,
          onTap: () {},
          onMenuTap:
              onMenuTap != null ? () => onMenuTap!(listing) : null,
        );
      },
    );
  }
}

// ── Menu Option ────────────────────────────────────────────────────────────────

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? const Color(0xFF374151);
    return ListTile(
      leading: Icon(icon, color: textColor, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          color: textColor,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      visualDensity: VisualDensity.compact,
    );
  }
}
