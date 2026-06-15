import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:anti_food_waste_app/features/billing/presentation/cubits/billing_cubit.dart';
import 'package:anti_food_waste_app/features/billing/domain/models/billing_models.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

/// Merchant screen for managing sponsored listing slots and active sponsorships.
/// Read + soft-cancel only (promoting a listing requires a SponsoredSlot).
class SponsoredListingsScreen extends StatefulWidget {
  const SponsoredListingsScreen({super.key});

  @override
  State<SponsoredListingsScreen> createState() => _SponsoredListingsScreenState();
}

class _SponsoredListingsScreenState extends State<SponsoredListingsScreen>
    with SingleTickerProviderStateMixin {
  static const _gold = Color(0xFFF59E0B);
  static const _green = AppTheme.primary;
  static const _blue = Color(0xFF3B82F6);
  static const _red = Color(0xFFEF4444);

  late TabController _tabController;
  final _dateFmt = DateFormat('d MMM yyyy');
  final _currencyFmt = NumberFormat('#,##0', 'fr_DZ');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final cubit = context.read<BillingCubit>();
    if (cubit.state is BillingInitial) {
      cubit.load();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillingCubit, BillingState>(
      builder: (context, state) {
        if (state is BillingLoading || state is BillingInitial) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FA),
            body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        }
        if (state is BillingError) {
          return _ErrorScaffold(message: state.message);
        }
        if (state is BillingLoaded) {
          return _buildScaffold(context, state);
        }
        return const Scaffold(
          backgroundColor: Color(0xFFF8F9FA),
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, BillingLoaded state) {
    final slots = state.sponsoredSlots;
    final active = state.sponsoredListings.where((l) => l.isCurrentlyActive).toList();
    final totalSlots = slots.fold<int>(0, (s, slot) => s + slot.quantity);
    final usedSlots = slots.fold<int>(0, (s, slot) => s + slot.slotsUsed);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          _buildSliverAppBar(context, totalSlots, usedSlots),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildSlotSummary(state),
                _buildTabBar(),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _SlotsTab(slots: slots, dateFmt: _dateFmt, currencyFmt: _currencyFmt),
            _ActiveSponsorshipsTab(
              listings: active,
              dateFmt: _dateFmt,
              onRemove: (id) => _confirmRemoveSponsorship(context, id),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sliver AppBar ─────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(BuildContext context, int totalSlots, int usedSlots) {
    return SliverAppBar(
      expandedHeight: 190,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A2E),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => context.read<BillingCubit>().load(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            ),
          ),
          child: Stack(
            children: [
              // Decorative stars
              Positioned(
                top: 30,
                right: 30,
                child: _StarDot(size: 6, color: _gold.withOpacity(0.8)),
              ),
              Positioned(
                top: 80,
                right: 100,
                child: _StarDot(size: 4, color: _gold.withOpacity(0.5)),
              ),
              Positioned(
                top: 120,
                right: 50,
                child: _StarDot(size: 3, color: Colors.white.withOpacity(0.3)),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _gold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.star_rounded, color: _gold, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'SPONSORED LISTINGS',
                            style: TextStyle(
                              color: _gold,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Boost Your Reach',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$usedSlots / $totalSlots slots active',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: const Text(
          'Sponsored Listings',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  // ── Slot summary strip ────────────────────────────────────────────────────

  Widget _buildSlotSummary(BillingLoaded state) {
    final slots = state.sponsoredSlots;
    final active = state.sponsoredListings.where((l) => l.isCurrentlyActive).length;
    final totalSlots = slots.fold<int>(0, (s, sl) => s + sl.quantity);
    final totalInvested = slots.fold<double>(0, (s, sl) => s + sl.totalAmountDzd);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _gold.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: _gold, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sponsored listings appear at the top of consumer feeds with a ⭐ Featured badge, boosting your order rate.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _MiniStatCard(icon: Icons.layers_rounded, label: 'Total Slots', value: '$totalSlots', color: _blue)),
              const SizedBox(width: 10),
              Expanded(child: _MiniStatCard(icon: Icons.star_rounded, label: 'Active Now', value: '$active', color: _gold)),
              const SizedBox(width: 10),
              Expanded(child: _MiniStatCard(icon: Icons.payments_rounded, label: 'Invested', value: '${_currencyFmt.format(totalInvested)} DZD', color: _green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(14),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.all(4),
          tabs: const [
            Tab(text: 'My Slot Packages'),
            Tab(text: 'Active Sponsorships'),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveSponsorship(BuildContext context, String sponsoredListingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Remove Sponsorship?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('This will deactivate the sponsored boost for this listing. The slot will be freed up for reuse.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BillingCubit>().removeSponsorship(sponsoredListingId);
            },
            child: const Text('REMOVE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

// ── Slots Tab ─────────────────────────────────────────────────────────────────

class _SlotsTab extends StatelessWidget {
  final List<SponsoredSlot> slots;
  final DateFormat dateFmt;
  final NumberFormat currencyFmt;

  const _SlotsTab({required this.slots, required this.dateFmt, required this.currencyFmt});

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return _EmptyState(
        icon: Icons.layers_outlined,
        title: 'No slot packages yet',
        subtitle: 'Contact Tawfir to purchase sponsored listing slots and boost your listings.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: slots.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _SlotCard(slot: slots[i], dateFmt: dateFmt, currencyFmt: currencyFmt),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final SponsoredSlot slot;
  final DateFormat dateFmt;
  final NumberFormat currencyFmt;

  const _SlotCard({required this.slot, required this.dateFmt, required this.currencyFmt});

  static const _statusColors = {
    'active': Color(0xFF2D8659),
    'expired': Color(0xFF6B7280),
    'cancelled': Color(0xFFEF4444),
  };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[slot.status] ?? Colors.grey;
    final usedRatio = slot.quantity > 0 ? slot.slotsUsed / slot.quantity : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${slot.quantity} Sponsored Slot${slot.quantity > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                    ),
                    Text(
                      '${dateFmt.format(slot.periodStart)} → ${dateFmt.format(slot.periodEnd)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  slot.status.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Usage bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Slots used', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                        Text('${slot.slotsUsed} / ${slot.quantity}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: usedRatio.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          usedRatio >= 1.0 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${currencyFmt.format(slot.pricePerSlotDzd)} DZD / slot  •  Total: ${currencyFmt.format(slot.totalAmountDzd)} DZD',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ── Active Sponsorships Tab ───────────────────────────────────────────────────

class _ActiveSponsorshipsTab extends StatelessWidget {
  final List<SponsoredListing> listings;
  final DateFormat dateFmt;
  final void Function(String id) onRemove;

  const _ActiveSponsorshipsTab({
    required this.listings,
    required this.dateFmt,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return _EmptyState(
        icon: Icons.star_border_rounded,
        title: 'No active sponsorships',
        subtitle: 'Once you assign a listing to a slot, it will appear here with its boost status.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: listings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _SponsoredListingCard(
        entry: listings[i],
        dateFmt: dateFmt,
        onRemove: () => onRemove(listings[i].id),
      ),
    );
  }
}

class _SponsoredListingCard extends StatelessWidget {
  final SponsoredListing entry;
  final DateFormat dateFmt;
  final VoidCallback onRemove;

  const _SponsoredListingCard({
    required this.entry,
    required this.dateFmt,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = entry.expiresAt.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysLeft <= 3 && daysLeft >= 0;
    final expiredColor = isExpiringSoon ? const Color(0xFFEF4444) : const Color(0xFF2D8659);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isExpiringSoon
              ? const Color(0xFFEF4444).withOpacity(0.3)
              : Colors.grey.shade200,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Star badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFED8936)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text('SPONSORED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.cancel_outlined, color: Colors.grey, size: 20),
                onPressed: onRemove,
                tooltip: 'Remove sponsorship',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.listingTitle.isNotEmpty ? entry.listingTitle : 'Listing',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: expiredColor),
              const SizedBox(width: 4),
              Text(
                isExpiringSoon
                    ? 'Expires in $daysLeft day${daysLeft == 1 ? '' : 's'}!'
                    : 'Expires ${dateFmt.format(entry.expiresAt)}',
                style: TextStyle(fontSize: 12, color: expiredColor, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 16),
              Icon(Icons.leaderboard_rounded, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                'Position #${entry.positionPriority}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827)), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 52, color: const Color(0xFFF59E0B).withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            const SizedBox(height: 10),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.6)),
          ],
        ),
      ),
    );
  }
}

class _StarDot extends StatelessWidget {
  final double size;
  final Color color;
  const _StarDot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String message;
  const _ErrorScaffold({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 16),
              const Text('Failed to load sponsored listings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.read<BillingCubit>().load(),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
