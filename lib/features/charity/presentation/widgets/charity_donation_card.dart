import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';

// ─── Urgency colour helper ────────────────────────────────────────────────────
Color _urgencyColor(UrgencyLevel u) {
  switch (u) {
    case UrgencyLevel.critical:
      return AppTheme.accent;
    case UrgencyLevel.urgent:
      return AppTheme.warning;
    case UrgencyLevel.normal:
      return AppTheme.primary;
  }
}

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

// ─────────────────────────────────────────────────────────────────────────────
/// A card that displays a single [CharityDonation].
// ─────────────────────────────────────────────────────────────────────────────
class CharityDonationCard extends StatelessWidget {
  final CharityDonation donation;
  final VoidCallback onTap;

  const CharityDonationCard({
    super.key,
    required this.donation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _urgencyColor(donation.urgency);
    final bool claimed = donation.status != DonationStatus.available;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: claimed ? 0.55 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar: urgency accent ──────────────────────────────────
              if (donation.urgency != UrgencyLevel.normal)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: urgencyColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_filled_rounded,
                          size: 13, color: urgencyColor),
                      const SizedBox(width: 5),
                      Text(
                        donation.urgency == UrgencyLevel.critical
                            ? 'Expires in < 1 hour — Act now!'
                            : 'Expires in < 3 hours — Urgent',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: urgencyColor,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Main content ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category icon box
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _categoryIcon(donation.category),
                        color: AppTheme.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title + merchant + tags
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            donation.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            donation.merchantName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Diet chips
                          Wrap(
                            spacing: 5,
                            children: donation.dietaryTags
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.07),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color:
                                              AppTheme.primary.withOpacity(0.2),
                                          width: 0.8),
                                    ),
                                    child: Text(
                                      tag,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    // Right: category label
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        donation.categoryLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Footer bar ───────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    _FooterChip(
                      icon: Icons.scale_outlined,
                      label: '${donation.quantityKg} kg',
                    ),
                    const SizedBox(width: 12),
                    _FooterChip(
                      icon: Icons.people_outline,
                      label: '~${donation.estimatedServings} servings',
                    ),
                    const SizedBox(width: 12),
                    _FooterChip(
                      icon: Icons.location_on_outlined,
                      label: '${donation.distanceKm} km',
                    ),
                    const Spacer(),
                    // Pickup window
                    Text(
                      '${donation.pickupWindowStart}–${donation.pickupWindowEnd}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
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
}

class _FooterChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FooterChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
