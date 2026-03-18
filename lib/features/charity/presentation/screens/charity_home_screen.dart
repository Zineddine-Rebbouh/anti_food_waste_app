import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';
import 'package:anti_food_waste_app/features/charity/data/mock_charity_data.dart';
import 'package:anti_food_waste_app/features/charity/presentation/widgets/charity_donation_card.dart';
import 'package:anti_food_waste_app/features/charity/presentation/widgets/charity_status_badge.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_donation_detail_screen.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_cubit.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

IconData _categoryIcon(DonationCategory c) {
  switch (c) {
    case DonationCategory.bakery:
      return Icons.breakfast_dining_outlined;
    case DonationCategory.restaurant:
      return Icons.restaurant_outlined;
    case DonationCategory.grocery:
      return Icons.local_grocery_store_outlined;
    case DonationCategory.cafe:
      return Icons.local_cafe_outlined;
    case DonationCategory.hotel:
      return Icons.hotel_outlined;
  }
}

IconData _statusIcon(PickupRequestStatus s) {
  switch (s) {
    case PickupRequestStatus.pending:
      return Icons.hourglass_top_rounded;
    case PickupRequestStatus.approved:
      return Icons.check_circle_outline_rounded;
    case PickupRequestStatus.enRoute:
      return Icons.local_shipping_outlined;
    case PickupRequestStatus.collected:
      return Icons.task_alt_rounded;
    case PickupRequestStatus.cancelled:
      return Icons.cancel_outlined;
  }
}

Color _statusColor(PickupRequestStatus s) {
  switch (s) {
    case PickupRequestStatus.pending:
      return Colors.amber.shade600;
    case PickupRequestStatus.approved:
      return Colors.blue.shade600;
    case PickupRequestStatus.enRoute:
      return Colors.purple.shade600;
    case PickupRequestStatus.collected:
      return AppTheme.primary;
    case PickupRequestStatus.cancelled:
      return Colors.red.shade600;
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'just now';
}

String _timeUntil(DateTime dt) {
  final diff = dt.difference(DateTime.now());
  if (diff.isNegative) return 'expired';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m left';
  return '${diff.inHours}h left';
}

// ─────────────────────────────────────────────────────────────────────────────
// CharityHomeScreen
// Note: implemented as StatefulWidget to support the dynamic SliverAppBar
// colour transition between its expanded (green gradient) and collapsed
// (white) states via a ScrollController.  The public constructor is `const`
// and the widget is otherwise fully read-only (all data from mock sources).
// ─────────────────────────────────────────────────────────────────────────────
class CharityHomeScreen extends StatefulWidget {
  const CharityHomeScreen({super.key});

  @override
  State<CharityHomeScreen> createState() => _CharityHomeScreenState();
}

class _CharityHomeScreenState extends State<CharityHomeScreen> {
  late final ScrollController _scrollController;
  bool _isCollapsed = false;

  // Threshold: expandedHeight(160) - kToolbarHeight(56) = 104
  static const double _collapseThreshold = 104.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final collapsed = _scrollController.offset > _collapseThreshold;
    if (collapsed != _isCollapsed) {
      setState(() => _isCollapsed = collapsed);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ── Derived data ────────────────────────────────────────────────────────────
  // We'll pass the state into these helper methods now.
  int _availableCount(List<CharityDonation> donations) =>
      donations.where((d) => d.status == DonationStatus.available).length;
  int _urgentCount(List<CharityDonation> donations) => donations
      .where((d) =>
          d.urgency == UrgencyLevel.critical ||
          d.urgency == UrgencyLevel.urgent)
      .length;
  int _pendingPickupsCount(List<CharityPickupRequest> requests) => requests
      .where((r) =>
          r.status == PickupRequestStatus.pending ||
          r.status == PickupRequestStatus.approved)
      .length;
  int get _totalMeals =>
      mockImpactReports.fold(0, (sum, r) => sum + r.mealsServed);
  int get _totalBeneficiaries =>
      mockImpactReports.fold(0, (sum, r) => sum + r.beneficiaries);
  double get _totalKg =>
      mockImpactReports.fold(0.0, (sum, r) => sum + r.actualWeightKg);
  List<CharityDonation> _urgentDonations(List<CharityDonation> donations) =>
      donations.where((d) => d.urgency != UrgencyLevel.normal).toList();
  List<CharityDonation> _availableDonations(List<CharityDonation> donations) => donations
      .where((d) => d.status == DonationStatus.available)
      .take(3)
      .toList();
  List<CharityPickupRequest> _recentRequests(List<CharityPickupRequest> requests) =>
      requests.take(3).toList();

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool collapsed = _isCollapsed;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: collapsed
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: BlocBuilder<CharityCubit, CharityState>(
          builder: (context, state) {
            List<CharityDonation> parsedDonations = [];
            List<CharityPickupRequest> parsedRequests = [];
            if (state is CharityLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CharityLoaded) {
              parsedDonations = state.donations;
              parsedRequests = state.myRequests;
            } else {
              parsedDonations = mockDonations;
              parsedRequests = mockPickupRequests;
            }
            return CustomScrollView(
              controller: _scrollController,
          slivers: [
            // ── SliverAppBar ──────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              elevation: 0,
              backgroundColor:
                  collapsed ? Colors.white : AppTheme.primary,
              foregroundColor:
                  collapsed ? Colors.black87 : Colors.white,
              surfaceTintColor: Colors.transparent,
              title: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: collapsed ? Colors.black87 : Colors.white,
                ),
                child: const Text('SAA Dashboard'),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: collapsed ? Colors.black87 : Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2D8659), Color(0xFF1B5E38)],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 72, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Good morning,',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.70),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Secours Alimentaire Algérie',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Verified Charity',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Algiers',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── All content below AppBar ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Section 1: Stats Row ────────────────────────────────────
                  const SizedBox(height: 16),
                  _StatsRow(
                    availableCount: _availableCount(parsedDonations),
                    urgentCount: _urgentCount(parsedDonations),
                    pendingPickupsCount: _pendingPickupsCount(parsedRequests),
                    totalMeals: _totalMeals,
                  ),

                  // ── Section 2: Expiring Soon ────────────────────────────────
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'Expiring Soon',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.access_time_rounded,
                              size: 15,
                              color: AppTheme.warning,
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'View all',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 175,
                    child: _urgentDonations(parsedDonations).isEmpty
                        ? const Center(
                            child: Text(
                              'No urgent donations right now.',
                              style: TextStyle(
                                  color: AppTheme.mutedForeground, fontSize: 13),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _urgentDonations(parsedDonations).length,
                            itemBuilder: (_, i) => _ExpiringSoonCard(
                              donation: _urgentDonations(parsedDonations)[i],
                            ),
                          ),
                  ),

                  // ── Section 3: Recent Activity ──────────────────────────────
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: Colors.grey.shade100, width: 1.2),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      itemCount: _recentRequests(parsedRequests).length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.grey.shade100,
                      ),
                      itemBuilder: (_, i) =>
                          _ActivityItem(request: _recentRequests(parsedRequests)[i]),
                    ),
                  ),

                  // ── Section 4: Available Now ────────────────────────────────
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Available Now',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'See all',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ..._availableDonations(parsedDonations).map(
                    (d) => CharityDonationCard(
                      donation: d,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CharityDonationDetailScreen(donation: d),
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Section 5: Impact Summary ───────────────────────────────
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ImpactCard(
                      totalMeals: _totalMeals,
                      totalBeneficiaries: _totalBeneficiaries,
                      totalKg: _totalKg,
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        );
        },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 1 — Stats Row
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int availableCount;
  final int urgentCount;
  final int pendingPickupsCount;
  final int totalMeals;

  const _StatsRow({
    required this.availableCount,
    required this.urgentCount,
    required this.pendingPickupsCount,
    required this.totalMeals,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatCard(
            label: 'Available',
            value: '$availableCount',
            icon: Icons.volunteer_activism_outlined,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Urgent',
            value: '$urgentCount',
            icon: Icons.priority_high_rounded,
            color: AppTheme.warning,
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Pending Pickup',
            value: '$pendingPickupsCount',
            icon: Icons.local_shipping_outlined,
            color: Colors.blue.shade600,
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'This Week',
            value: '$totalMeals',
            icon: Icons.people_alt_outlined,
            color: Colors.purple.shade600,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 106,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 2 — Expiring Soon Card
// ─────────────────────────────────────────────────────────────────────────────

class _ExpiringSoonCard extends StatelessWidget {
  final CharityDonation donation;

  const _ExpiringSoonCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    final Color urgencyColor = donation.urgency == UrgencyLevel.critical
        ? AppTheme.accent
        : AppTheme.warning;

    final String timeLeft = _timeUntil(donation.expiresAt);

    return Container(
      width: 165,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _categoryIcon(donation.category),
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: 9),
          // Title
          Text(
            donation.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          // Merchant
          Text(
            donation.merchantName,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          // Bottom row: time left + qty badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 12, color: urgencyColor),
                  const SizedBox(width: 3),
                  Text(
                    timeLeft,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: urgencyColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${donation.quantityKg}kg',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 3 — Activity Item
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityItem extends StatelessWidget {
  final CharityPickupRequest request;

  const _ActivityItem({required this.request});

  @override
  Widget build(BuildContext context) {
    final Color color = _statusColor(request.status);
    final String timeAgo = _timeAgo(request.requestedAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Status icon circle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusIcon(request.status),
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          // Title + merchant
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.donationTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  request.merchantName,
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Badge + time ago
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CharityStatusBadge(status: request.status),
              const SizedBox(height: 3),
              Text(
                timeAgo,
                style:
                    TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 5 — Impact Summary Card
// ─────────────────────────────────────────────────────────────────────────────

class _ImpactCard extends StatelessWidget {
  final int totalMeals;
  final int totalBeneficiaries;
  final double totalKg;

  const _ImpactCard({
    required this.totalMeals,
    required this.totalBeneficiaries,
    required this.totalKg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D8659), Color(0xFF1B5E38)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Total Impact This Week',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          // Big meal count
          Text(
            '$totalMeals',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const Text(
            'meals served',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          // Stats row
          Row(
            children: [
              _ImpactStat(
                value: '$totalBeneficiaries',
                label: 'Beneficiaries',
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 28,
                color: Colors.white24,
              ),
              const SizedBox(width: 8),
              _ImpactStat(
                value: '${totalKg.toStringAsFixed(1)} kg',
                label: 'Food rescued',
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Report button
          GestureDetector(
            onTap: () {},
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View Full Report',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  final String value;
  final String label;

  const _ImpactStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }
}




