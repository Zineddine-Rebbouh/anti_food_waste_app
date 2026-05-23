import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_listing.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/widgets/merchant_status_badge.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MerchantListingCard extends StatelessWidget {
  final MerchantListing listing;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  const MerchantListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeLeft = listing.pickupEnd.difference(DateTime.now());
    final isUrgent = timeLeft.inMinutes < 60 && timeLeft.inMinutes > 0;
    final isCritical = timeLeft.inMinutes < 10 && timeLeft.inMinutes > 0;

    var countdown = isCritical
        ? const Color(0xFFEF4444)
        : isUrgent
            ? const Color(0xFFF97316)
            : const Color(0xFF2D8659);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: listing.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: listing.imageUrl,
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 84,
                            height: 84,
                            color: Colors.white,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2D8659))),
                          ),
                        )
                      : Container(
                          width: 84,
                          height: 84,
                          color: Colors.white,
                          child: const Icon(Icons.fastfood_outlined, color: Color(0xFF2D8659), size: 32),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${listing.discountedPrice.toStringAsFixed(0)} DZD',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2D8659),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            _statusLabel(listing.status, l10n).toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          l10n.count_left(listing.availableQuantity),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.schedule_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _pickupLabel(listing, countdown, l10n),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: countdown),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu button
              if (onMenuTap != null)
                IconButton(
                  onPressed: onMenuTap,
                  icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFFD1D5DB)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _pickupLabel(MerchantListing listing, Color countdown, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = listing.pickupEnd.difference(now);

    final startStr =
        '${listing.pickupStart.hour.toString().padLeft(2, '0')}:${listing.pickupStart.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${listing.pickupEnd.hour.toString().padLeft(2, '0')}:${listing.pickupEnd.minute.toString().padLeft(2, '0')}';

    var base = l10n.pickup_today(startStr, endStr);

    if (diff.isNegative) {
      return '$base ${l10n.pickup_expired_label}';
    }

    if (diff.inHours >= 1) {
      return '$base ${l10n.closes_in('${diff.inHours}${l10n.h_short} ${diff.inMinutes % 60}${l10n.m_short}')}';
    } else if (diff.inMinutes > 0) {
      return '$base ${l10n.closes_in('${diff.inMinutes}${l10n.m_short}')}';
    }
    return base;
  }

  String _statusLabel(ListingStatus status, AppLocalizations l10n) {
    switch (status) {
      case ListingStatus.active: return l10n.status_active;
      case ListingStatus.draft: return l10n.status_draft;
      case ListingStatus.soldOut: return l10n.status_sold_out;
      case ListingStatus.expired: return l10n.status_expired;
      case ListingStatus.paused: return l10n.status_paused;
    }
  }
}



