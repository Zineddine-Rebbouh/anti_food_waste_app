import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_listing.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/widgets/merchant_status_badge.dart';

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
    final timeLeft = listing.pickupEnd.difference(DateTime.now());
    final isUrgent = timeLeft.inMinutes < 60 && timeLeft.inMinutes > 0;
    final isCritical = timeLeft.inMinutes < 10 && timeLeft.inMinutes > 0;

    Color countdown = isCritical
        ? const Color(0xFFEF4444)
        : isUrgent
            ? const Color(0xFFF97316)
            : const Color(0xFF10B981);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: listing.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: listing.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 80,
                          height: 80,
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(Icons.fastfood_outlined,
                              color: Color(0xFF9CA3AF), size: 32),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(Icons.fastfood_outlined,
                              color: Color(0xFF9CA3AF), size: 32),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: const Color(0xFFF3F4F6),
                        child: const Icon(Icons.fastfood_outlined,
                            color: Color(0xFF9CA3AF), size: 32),
                      ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        MerchantStatusBadge(status: listing.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${listing.discountedPrice.toStringAsFixed(0)} DZD',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule,
                            size: 12, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _pickupLabel(listing, countdown),
                            style: TextStyle(
                              fontSize: 12,
                              color: countdown,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined,
                            size: 13, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${listing.availableQuantity}/${listing.totalQuantity} avail.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.visibility_outlined,
                            size: 13, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${listing.views} views',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.shopping_cart_outlined,
                            size: 13, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${listing.reservedQuantity} rsv.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
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
                GestureDetector(
                  onTap: onMenuTap,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4, top: 4),
                    child: Icon(Icons.more_vert,
                        size: 20, color: Color(0xFF6B7280)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _pickupLabel(MerchantListing listing, Color countdown) {
    final now = DateTime.now();
    final diff = listing.pickupEnd.difference(now);

    final startStr =
        '${listing.pickupStart.hour.toString().padLeft(2, '0')}:${listing.pickupStart.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${listing.pickupEnd.hour.toString().padLeft(2, '0')}:${listing.pickupEnd.minute.toString().padLeft(2, '0')}';

    String base = 'Today $startStr-$endStr';

    if (diff.isNegative) {
      return '$base (Expired)';
    }

    if (diff.inHours >= 1) {
      return '$base (Closes in ${diff.inHours}h ${diff.inMinutes % 60}min)';
    } else if (diff.inMinutes > 0) {
      return '$base (Closes in ${diff.inMinutes}min)';
    }
    return base;
  }
}
