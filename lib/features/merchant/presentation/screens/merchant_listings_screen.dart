import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_listing.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/create_listing/merchant_create_listing_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/widgets/merchant_listing_card.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_listing_detail_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/utils/l10n_utils.dart';

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
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color accentBeige = Colors.white;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<MerchantCubit, MerchantState>(
      builder: (context, state) {
        if (state is MerchantLoading) {
          return const Scaffold(
            backgroundColor: accentBeige,
            body: Center(child: CircularProgressIndicator(color: primaryGreen)),
          );
        }
        if (state is MerchantError) {
          return Scaffold(
            backgroundColor: accentBeige,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(L10nUtils.translateError(state.message, l10n), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<MerchantCubit>().load(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state is! MerchantLoaded) {
          return const Scaffold(backgroundColor: accentBeige, body: Center(child: CircularProgressIndicator(color: primaryGreen)));
        }

        return Scaffold(
          backgroundColor: accentBeige,
          body: Column(
            children: [
              _buildEditorialHeader(context, l10n, state),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ListingsTab(
                      listings: state.activeListings,
                      emptyTitle: l10n.no_active_listings,
                      emptySubtitle: l10n.no_active_listings_desc,
                      onMenuTap: (listing) => _showListingMenu(context, listing, state, l10n),
                    ),
                    _ListingsTab(
                      listings: state.donationsListings,
                      emptyTitle: l10n.no_donations,
                      emptySubtitle: l10n.no_donations_desc,
                      onMenuTap: (listing) => _showListingMenu(context, listing, state, l10n),
                    ),
                    _ListingsTab(
                      listings: state.soldOutListings,
                      emptyTitle: l10n.nothing_sold_out,
                      emptySubtitle: l10n.nothing_sold_out_desc,
                      onMenuTap: (listing) => _showListingMenu(context, listing, state, l10n),
                    ),
                    _ListingsTab(
                      listings: state.expiredListings,
                      emptyTitle: l10n.no_expired_items,
                      emptySubtitle: l10n.no_expired_items_desc,
                      onMenuTap: (listing) => _showListingMenu(context, listing, state, l10n),
                    ),
                    _ListingsTab(
                      listings: state.draftListings,
                      emptyTitle: l10n.no_drafts,
                      emptySubtitle: l10n.no_drafts_desc,
                      onMenuTap: (listing) => _showListingMenu(context, listing, state, l10n),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditorialHeader(BuildContext context, AppLocalizations l10n, MerchantLoaded state) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.listings_label.toUpperCase(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: IconButton(
                      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                      onPressed: () => _openCreateListing(context),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                l10n.inventory_label,
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.only(left: 12, bottom: 12),
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Color(0xFFFFD54F), width: 4),
                insets: EdgeInsets.symmetric(horizontal: 16),
              ),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.4),
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
              tabs: [
                Tab(text: l10n.active_with_count(state.activeListings.length).toUpperCase()),
                Tab(text: l10n.donations_with_count(state.donationsListings.length).toUpperCase()),
                Tab(text: l10n.sold_out_label.toUpperCase()),
                Tab(text: l10n.expired_label.toUpperCase()),
                Tab(text: l10n.drafts_label.toUpperCase()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openCreateListing(BuildContext context, {MerchantListing? existingListing}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BlocProvider.value(
          value: context.read<MerchantCubit>(),
          child: MerchantCreateListingScreen(existingListing: existingListing),
        ),
      ),
    );
  }

  void _showListingMenu(BuildContext context, MerchantListing listing, MerchantLoaded state, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 24),
                Text(listing.title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.grey)),
                const SizedBox(height: 16),
                _MenuAction(
                  icon: Icons.edit_rounded,
                  label: l10n.edit_listing,
                  onTap: () { Navigator.pop(sheetCtx); _openCreateListing(context, existingListing: listing); },
                ),
                if (listing.status == ListingStatus.active)
                  _MenuAction(
                    icon: Icons.pause_rounded,
                    label: l10n.move_to_drafts,
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      context.read<MerchantCubit>().toggleListingStatusAsync(listing.id, ListingStatus.draft);
                    },
                  )
                else if (listing.status == ListingStatus.draft)
                  _MenuAction(
                    icon: Icons.play_arrow_rounded,
                    label: l10n.publish_now,
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      context.read<MerchantCubit>().toggleListingStatusAsync(listing.id, ListingStatus.active);
                    },
                  ),
                _MenuAction(
                  icon: Icons.delete_outline_rounded,
                  label: l10n.delete_listing,
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _confirmDelete(context, listing, l10n);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, MerchantListing listing, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.delete_listing_confirm_title, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(l10n.delete_listing_confirm_msg(listing.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w900))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MerchantCubit>().deleteListing(listing.id);
            },
            child: Text(l10n.delete_label.toUpperCase(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _ListingsTab extends StatelessWidget {
  final List<MerchantListing> listings;
  final String emptyTitle;
  final String emptySubtitle;
  final Function(MerchantListing)? onMenuTap;

  const _ListingsTab({required this.listings, required this.emptyTitle, required this.emptySubtitle, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_rounded, size: 64, color: Colors.grey.shade100),
              const SizedBox(height: 24),
              Text(emptyTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              const SizedBox(height: 8),
              Text(emptySubtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      itemCount: listings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (ctx, i) {
        final listing = listings[i];
        return MerchantListingCard(
          listing: listing,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MerchantListingDetailScreen(listing: listing))),
          onMenuTap: onMenuTap != null ? () => onMenuTap!(listing) : null,
        );
      },
    );
  }
}

class _MenuAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuAction({required this.icon, required this.label, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (isDestructive ? Colors.red : const Color(0xFF2D8659)).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF2D8659), size: 20),
      ),
      title: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDestructive ? Colors.red : const Color(0xFF111827))),
    );
  }
}



