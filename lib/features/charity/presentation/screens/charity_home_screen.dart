import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';
import 'package:anti_food_waste_app/features/charity/presentation/widgets/charity_donation_card.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_donation_detail_screen.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_cubit.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_donations_screen.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_requests_screen.dart';
import 'package:anti_food_waste_app/features/notifications/presentation/cubits/notifications_cubit.dart';
import 'package:anti_food_waste_app/features/notifications/presentation/cubits/notifications_state.dart';
import 'package:anti_food_waste_app/shared/widgets/notification_panel.dart';

class CharityHomeScreen extends StatefulWidget {
  const CharityHomeScreen({super.key});

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color accentBeige = Colors.white;

  @override
  State<CharityHomeScreen> createState() => _CharityHomeScreenState();
}

class _CharityHomeScreenState extends State<CharityHomeScreen> {
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

  int get _totalMeals => 1250;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: CharityHomeScreen.accentBeige,
      body: BlocBuilder<CharityCubit, CharityState>(
        builder: (context, state) {
          var donations = <CharityDonation>[];
          var requests = <CharityPickupRequest>[];

          if (state is CharityLoading) {
            return const Center(child: CircularProgressIndicator(color: CharityHomeScreen.primaryGreen));
          } else if (state is CharityLoaded) {
            donations = state.donations;
            requests = state.myRequests;
          }

          return RefreshIndicator(
            onRefresh: () async => context.read<CharityCubit>().fetchCharityData(),
            color: CharityHomeScreen.primaryGreen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(duration: const Duration(milliseconds: 600), child: _buildHeader(context, l10n)),
                  FadeInUp(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 600), child: _StatsRow(
                    availableCount: _availableCount(donations),
                    urgentCount: _urgentCount(donations),
                    pendingPickupsCount: _pendingPickupsCount(requests),
                    totalMeals: _totalMeals,
                  )),
                  FadeInUp(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 600), child: _buildQuickActions(context, l10n)),
                  const SizedBox(height: 32),
                  FadeInUp(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 600), child: _buildSectionHeader(l10n.expiring_soon, Icons.bolt_rounded, l10n.view_all, () {})),
                  const SizedBox(height: 16),
                  FadeInUp(delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 600), child: _buildExpiringList(donations, requests, l10n)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CharityHomeScreen.primaryGreen, Color(0xFF0D2119)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(width: 150, height: 150, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle)),
          ),
          Positioned(
            bottom: 20,
            left: -40,
            child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), shape: BoxShape.circle)),
          ),
          SafeArea(
            bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.apartment_rounded, size: 28, color: CharityHomeScreen.primaryGreen),
                        ),
                        const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.charity_name_placeholder, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_rounded, size: 12, color: Colors.white.withOpacity(0.5)),
                                    const SizedBox(width: 4),
                                    Text(l10n.location_algiers, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified_rounded, color: Color(0xFF2D8659), size: 12),
                                      const SizedBox(width: 4),
                                      Text(l10n.status_verified, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        BlocBuilder<NotificationsCubit, NotificationsState>(
                          builder: (context, state) {
                            var unreadCount = 0;
                            if (state is NotificationsLoaded) {
                              unreadCount = state.unreadCount;
                            }
                            return InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) => const NotificationPanel(),
                                );
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Badge(
                                    isLabelVisible: unreadCount > 0,
                                    label: Text(unreadCount.toString()),
                                    backgroundColor: Colors.red,
                                    child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  l10n.today,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.charity_overview,
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
                ),
                Text(
                  l10n.your_impact_summary,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15, fontWeight: FontWeight.w500),
                ),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.quick_actions, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  title: l10n.browse_donations,
                  subtitle: l10n.browse_donations_desc,
                  icon: Icons.search_rounded,
                  color: CharityHomeScreen.primaryGreen,
                  onTap: () {
                    final cubit = context.read<CharityCubit>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child: const CharityDonationsScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  title: l10n.active_pickups,
                  subtitle: l10n.active_pickups_desc,
                  icon: Icons.local_shipping_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () {
                    final cubit = context.read<CharityCubit>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child: const CharityRequestsScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, String actionLabel, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: CharityHomeScreen.primaryGreen),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
            ],
          ),
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel, style: const TextStyle(color: CharityHomeScreen.primaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringList(List<CharityDonation> donations, List<CharityPickupRequest> requests, AppLocalizations l10n) {
    final expiring = donations.take(3).toList();
    if (expiring.isEmpty) return const SizedBox.shrink();

    return Column(
      children: expiring.map((d) {
        final isRequested = requests.any((r) => r.donationId == d.id);
        return CharityDonationCard(
          donation: d,
          isRequested: isRequested,
          prominentImage: true,
          onTap: () {
            final cubit = context.read<CharityCubit>();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: CharityDonationDetailScreen(donation: d),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int availableCount;
  final int urgentCount;
  final int pendingPickupsCount;
  final int totalMeals;

  const _StatsRow({required this.availableCount, required this.urgentCount, required this.pendingPickupsCount, required this.totalMeals});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _StatCard(label: l10n.available_stat, value: '$availableCount', icon: Icons.volunteer_activism_rounded, color: const Color(0xFF2D8659), delta: l10n.today)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: l10n.urgent_stat, value: '$urgentCount', icon: Icons.bolt_rounded, color: const Color(0xFFEF4444), delta: l10n.today)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: l10n.pending_pickup_stat, value: '$pendingPickupsCount', icon: Icons.local_shipping_rounded, color: const Color(0xFF3B82F6), delta: l10n.today)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? delta;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color, this.delta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade500, height: 1.2)),
          if (delta != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFF2D8659).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(delta!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF2D8659))),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }
}

