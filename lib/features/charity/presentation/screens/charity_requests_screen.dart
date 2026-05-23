import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_cubit.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_state.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';
import 'package:anti_food_waste_app/features/charity/presentation/widgets/charity_status_badge.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_confirm_collection_screen.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_pickup_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CharityRequestsScreen extends StatefulWidget {
  const CharityRequestsScreen({super.key});

  @override
  State<CharityRequestsScreen> createState() => _CharityRequestsScreenState();
}

class _CharityRequestsScreenState extends State<CharityRequestsScreen> {
  static const Color _green = Color(0xFF2D8659);
  static const Color _beige = Colors.white;

  int _selectedTab = 0;

  List<CharityPickupRequest> _getPendingRequests(List<CharityPickupRequest> r) =>
      r.where((x) => x.status == PickupRequestStatus.pending).toList();

  List<CharityPickupRequest> _getActiveRequests(List<CharityPickupRequest> r) => r
      .where((x) =>
          x.status == PickupRequestStatus.approved ||
          x.status == PickupRequestStatus.enRoute)
      .toList();

  List<CharityPickupRequest> _getCompletedRequests(List<CharityPickupRequest> r) => r
      .where((x) =>
          x.status == PickupRequestStatus.collected ||
          x.status == PickupRequestStatus.cancelled)
      .toList();

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
        final requests =
            state is CharityLoaded ? state.myRequests : <CharityPickupRequest>[];
        final pending = _getPendingRequests(requests);
        final active = _getActiveRequests(requests);
        final completed = _getCompletedRequests(requests);

        final currentList = _selectedTab == 0
            ? pending
            : _selectedTab == 1
                ? active
                : completed;

        return Scaffold(
          backgroundColor: _beige,
          body: Column(
            children: [
              // ── Premium green header ────────────────────────────────────
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
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.my_pickups_title.toUpperCase(),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.my_pickups_title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 24),
                        // ── Tabs embedded in header ─────────────────────
                        Row(
                          children: List.generate(3, (i) {
                            final labels = [
                              l10n.status_pending,
                              l10n.active_tab,
                              l10n.completed_tab,
                            ];
                            final counts = [
                              pending.length,
                              active.length,
                              completed.length,
                            ];
                            final isSelected = _selectedTab == i;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTab = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsetsDirectional.only(
                                      end: i < 2 ? 12 : 0, bottom: 0),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${counts[i]}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: isSelected
                                              ? _green
                                              : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        labels[i],
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? _green.withOpacity(0.7)
                                              : Colors.white.withOpacity(0.6),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Request list ────────────────────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  color: _green,
                  onRefresh: () async =>
                      context.read<CharityCubit>().fetchCharityData(),
                  child: currentList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                l10n.no_requests_here,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: currentList.length,
                          itemBuilder: (_, i) {
                            final req = currentList[i];
                            return _PickupRequestCard(
                              request: req,
                              l10n: l10n,
                              onActionTap:
                                  req.status == PickupRequestStatus.approved
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BlocProvider.value(
                                                value: context
                                                    .read<CharityCubit>(),
                                                child:
                                                    CharityConfirmCollectionScreen(
                                                        request: req),
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pickup request card
// ─────────────────────────────────────────────────────────────────────────────
class _PickupRequestCard extends StatelessWidget {
  const _PickupRequestCard({
    required this.request,
    this.onActionTap,
    required this.l10n,
  });

  final CharityPickupRequest request;
  final VoidCallback? onActionTap;
  final AppLocalizations l10n;

  static const Color _green = Color(0xFF2D8659);

  Color get _statusColor {
    switch (request.status) {
      case PickupRequestStatus.pending:
        return Colors.amber.shade700;
      case PickupRequestStatus.approved:
        return Colors.blue.shade600;
      case PickupRequestStatus.enRoute:
        return Colors.purple.shade600;
      case PickupRequestStatus.collected:
        return _green;
      case PickupRequestStatus.cancelled:
        return AppTheme.accent;
    }
  }

  IconData get _statusIcon {
    switch (request.status) {
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

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$d/$mo  $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<CharityCubit>(),
              child: CharityPickupDetailScreen(requestId: request.id),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: icon + title + badge ─────────────────────────
            Row(
              children: [
                // Listing Photo
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: request.listingPhoto.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: request.listingPhoto,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: _statusColor,
                                strokeWidth: 2,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(_statusIcon, size: 20, color: _statusColor),
                          )
                        : Icon(_statusIcon, size: 20, color: _statusColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    request.donationTitle,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                CharityStatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: 12),

            // ── Merchant name ──────────────────────────────────────────
            Text(
              request.merchantName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // ── Schedule + chips ───────────────────────────────────────
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _formatDateTime(request.scheduledPickupTime),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SmallChip(
                  icon: Icons.scale_rounded,
                  label: '${request.quantityKg} kg',
                  color: _green,
                ),
                _SmallChip(
                  icon: Icons.restaurant_rounded,
                  label: '${request.estimatedServings} ${l10n.servings_label(request.estimatedServings)}',
                  color: Colors.orange.shade700,
                ),
              ],
            ),

            // ── Merchant note ──────────────────────────────────────────
            if (request.merchantNote != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14, color: Colors.amber.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.merchantNote!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // ── Footer: tap hint or action button ─────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.touch_app_rounded,
                        size: 13, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      l10n.tap_for_details,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                if (onActionTap != null)
                  GestureDetector(
                    onTap: onActionTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        l10n.confirm_collection,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small chip ───────────────────────────────────────────────────────────────
class _SmallChip extends StatelessWidget {
  const _SmallChip(
      {required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}



