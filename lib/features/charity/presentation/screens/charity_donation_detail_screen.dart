import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_pickup_request_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CharityDonationDetailScreen
// ─────────────────────────────────────────────────────────────────────────────
class CharityDonationDetailScreen extends StatelessWidget {
  final CharityDonation donation;

  const CharityDonationDetailScreen({
    super.key,
    required this.donation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDonationHeader(),
                    if (donation.urgency != UrgencyLevel.normal)
                      _buildUrgencyBanner(),
                    _buildKeyFacts(),
                    _buildDescriptionCard(),
                    _buildDietaryTagsCard(),
                    _buildPickupWindowCard(),
                    _buildMerchantCard(),
                    // Bottom padding so the sticky button does not cover content
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          _buildStickyButton(context),
        ],
      ),
    );
  }

  // ── SliverAppBar ────────────────────────────────────────────────────────────
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.9),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: Text(
        donation.title,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A2E),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: IconButton(
              icon: const Icon(Icons.share_outlined,
                  color: Colors.black87, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Link copied to clipboard')),
                );
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildSliverBackground(),
      ),
    );
  }

  Widget _buildSliverBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, Color(0xFF1B5E38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Large faint category icon as background texture
          Center(
            child: Icon(
              _categoryIcon(donation.category),
              size: 140,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          // Centered foreground icon inside a translucent white circle
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.40), width: 1.5),
              ),
              child: Icon(
                _categoryIcon(donation.category),
                size: 38,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card 1: Donation Header ─────────────────────────────────────────────────
  Widget _buildDonationHeader() {
    final diff = DateTime.now().difference(donation.postedAt);
    final postedText = diff.inMinutes < 60
        ? 'Posted ${diff.inMinutes} min ago'
        : 'Posted ${diff.inHours} h ago';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            donation.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.storefront_outlined,
                  color: AppTheme.primary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  donation.merchantName,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF1A1A2E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppTheme.mutedForeground, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  donation.merchantAddress,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.mutedForeground),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            postedText,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.mutedForeground),
          ),
        ],
      ),
    );
  }

  // ── Urgency Banner ──────────────────────────────────────────────────────────
  Widget _buildUrgencyBanner() {
    final Color color = donation.urgency == UrgencyLevel.critical
        ? AppTheme.accent
        : AppTheme.warning;
    final int hoursLeft =
        donation.expiresAt.difference(DateTime.now()).inHours;
    final String label = donation.urgency == UrgencyLevel.critical
        ? 'Expiring very soon — Act now!'
        : 'Expiring in $hoursLeft hour${hoursLeft == 1 ? '' : 's'}';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_filled_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card 2: Key Facts (2x2 grid) ───────────────────────────────────────────
  Widget _buildKeyFacts() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _FactCell(
                  icon: Icons.scale_outlined,
                  label: 'Quantity',
                  value: '${donation.quantityKg} kg',
                ),
              ),
              Expanded(
                child: _FactCell(
                  icon: Icons.people_outline,
                  label: 'Servings',
                  value: '~${donation.estimatedServings}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FactCell(
                  icon: _categoryIcon(donation.category),
                  label: 'Category',
                  value: donation.categoryLabel,
                ),
              ),
              Expanded(
                child: _FactCell(
                  icon: Icons.near_me_outlined,
                  label: 'Distance',
                  value: '${donation.distanceKm} km away',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Card 3: Description ─────────────────────────────────────────────────────
  Widget _buildDescriptionCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About This Donation',
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            donation.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Card 4: Dietary Tags ────────────────────────────────────────────────────
  Widget _buildDietaryTagsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dietary Information',
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: donation.dietaryTags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.primary.withOpacity(0.25)),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
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
    );
  }

  // ── Card 5: Pickup Window ───────────────────────────────────────────────────
  Widget _buildPickupWindowCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.schedule_outlined,
                  color: AppTheme.primary, size: 18),
              SizedBox(width: 6),
              Text(
                'Pickup Window',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${donation.pickupWindowStart} – ${donation.pickupWindowEnd}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Today',
            style: TextStyle(
                fontSize: 13, color: AppTheme.mutedForeground),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.inputBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline,
                    size: 14, color: AppTheme.mutedForeground),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Please arrive within the pickup window. '
                    'Late arrivals may miss the donation.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.mutedForeground),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Card 6: Merchant Info ───────────────────────────────────────────────────
  Widget _buildMerchantCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About the Merchant',
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront_outlined,
                    color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donation.merchantName,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      donation.merchantAddress,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.mutedForeground),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.verified_outlined,
                  color: AppTheme.primary, size: 16),
              SizedBox(width: 6),
              Text('Verified Merchant',
                  style: TextStyle(fontSize: 13)),
              SizedBox(width: 20),
              Icon(Icons.star_rounded,
                  color: Colors.amber, size: 16),
              SizedBox(width: 4),
              Text('4.8 rating', style: TextStyle(fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Sticky bottom button ────────────────────────────────────────────────────
  Widget _buildStickyButton(BuildContext context) {
    final bool isAvailable =
        donation.status == DonationStatus.available;

    final String buttonLabel;
    if (donation.status == DonationStatus.claimed) {
      buttonLabel = 'Already Claimed';
    } else if (donation.status == DonationStatus.expired) {
      buttonLabel = 'Expired';
    } else if (donation.status == DonationStatus.collected) {
      buttonLabel = 'Already Collected';
    } else {
      buttonLabel = 'Request Pickup';
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: isAvailable
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CharityPickupRequestScreen(
                            donation: donation),
                      ),
                    )
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isAvailable ? AppTheme.primary : AppTheme.muted,
              foregroundColor: isAvailable
                  ? Colors.white
                  : AppTheme.mutedForeground,
              disabledBackgroundColor: AppTheme.muted,
              disabledForegroundColor: AppTheme.mutedForeground,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Fact Cell ────────────────────────────────────────────────────────────────
class _FactCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FactCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
              fontSize: 11, color: AppTheme.mutedForeground),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Category icon helper ─────────────────────────────────────────────────────
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
