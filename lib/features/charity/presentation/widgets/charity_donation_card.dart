import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ─────────────────────────────────────────────────────────────────────────────
/// A card that displays a single [CharityDonation].
// ─────────────────────────────────────────────────────────────────────────────
class CharityDonationCard extends StatelessWidget {
  final CharityDonation donation;
  final VoidCallback onTap;
  final bool isRequested;

  const CharityDonationCard({
    super.key,
    required this.donation,
    required this.onTap,
    this.isRequested = false,
  });

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _urgencyColor(donation.urgency);
    final claimed = donation.status != DonationStatus.available || isRequested;
    const Color forestGreen = Color(0xFF2D8659);
    const Color textNavy = Color(0xFF1A1A2E);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: claimed ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: forestGreen.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Urgency Bar ──────────────────────────────────────────────
              if (donation.urgency != UrgencyLevel.normal)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: urgencyColor.withOpacity(0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bolt_rounded, size: 14, color: urgencyColor),
                      const SizedBox(width: 6),
                      Text(
                        donation.urgency == UrgencyLevel.critical
                            ? 'CRITICAL — Expires very soon'
                            : 'URGENT — Limited time left',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: urgencyColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Main Content ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced Listing Image
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: forestGreen.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: donation.imageUrl != null && donation.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: donation.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    color: forestGreen,
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(_categoryIcon(donation.category), color: forestGreen, size: 28),
                              )
                            : Icon(_categoryIcon(donation.category), color: forestGreen, size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Info Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isRequested ? const Color(0xFF3B82F6).withOpacity(0.1) : forestGreen.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isRequested ? 'REQUESTED' : donation.categoryLabel.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: isRequested ? const Color(0xFF1D4ED8) : forestGreen,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            donation.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textNavy,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.storefront_rounded, size: 12, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  donation.merchantName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[500],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Footer Bar ───────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  border: Border(top: BorderSide(color: Colors.grey.shade100)),
                ),
                child: Row(
                  children: [
                    _FooterChip(
                      icon: Icons.scale_rounded,
                      label: '${donation.quantityKg} kg',
                      color: forestGreen,
                    ),
                    const SizedBox(width: 16),
                    _FooterChip(
                      icon: Icons.group_rounded,
                      label: '${donation.estimatedServings}',
                      color: const Color(0xFFF59E0B),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_filled_rounded, size: 12, color: forestGreen.withOpacity(0.6)),
                          const SizedBox(width: 6),
                          Text(
                            '${donation.pickupWindowStart}–${donation.pickupWindowEnd}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: textNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Helpers
  // ───────────────────────────────────────────────────────────────────────────

  IconData _categoryIcon(DonationCategory category) {
    switch (category) {
      case DonationCategory.bakery:
        return Icons.bakery_dining_rounded;
      case DonationCategory.grocery:
        return Icons.local_grocery_store_rounded;
      case DonationCategory.restaurant:
        return Icons.restaurant_rounded;
      case DonationCategory.cafe:
        return Icons.egg_alt_rounded;
      case DonationCategory.hotel:
        return Icons.eco_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  Color _urgencyColor(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.critical:
        return const Color(0xFFEF4444);
      case UrgencyLevel.urgent:
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF2D8659);
    }
  }
}

class _FooterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FooterChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 11, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}



