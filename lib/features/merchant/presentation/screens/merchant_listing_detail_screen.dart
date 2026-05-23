import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_listing.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/widgets/merchant_status_badge.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MerchantListingDetailScreen extends StatelessWidget {
  final MerchantListing listing;

  const MerchantListingDetailScreen({super.key, required this.listing});

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color backgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainInfo(l10n),
                  const SizedBox(height: 20),
                  _buildStatsSection(l10n),
                  const SizedBox(height: 20),
                  _buildInventorySection(l10n),
                  const SizedBox(height: 20),
                  _buildDetailsSection(l10n),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: primaryGreen,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.3),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (listing.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: listing.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: primaryGreen.withOpacity(0.1)),
              )
            else
              _buildPlaceholder(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black26, Colors.transparent, Colors.black45],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Icon(Icons.fastfood, size: 64, color: Color(0xFF9CA3AF)),
    );
  }

  Widget _buildMainInfo(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusBadge(status: listing.status),
              if (listing.isDonation)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.volunteer_activism, size: 14, color: primaryGreen),
                      const SizedBox(width: 6),
                      Text(l10n.donation_label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryGreen)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            listing.title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            listing.description,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.6, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.price_label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade400)),
                  const SizedBox(height: 4),
                  Text(
                    '${listing.discountedPrice.toStringAsFixed(0)} DZD',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryGreen),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${listing.originalPrice.toStringAsFixed(0)} DZD',
                  style: TextStyle(fontSize: 16, decoration: TextDecoration.lineThrough, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '-${listing.discountPercent.toInt()}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.visibility_outlined,
            label: l10n.views_label.toUpperCase(),
            value: '${listing.views}',
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.shopping_bag_outlined,
            label: l10n.reserved_label.toUpperCase(),
            value: '${listing.reservedQuantity}',
            color: const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.eco_outlined,
            label: l10n.grade_label.toUpperCase(),
            value: listing.grade.name.toUpperCase(),
            color: primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildInventorySection(AppLocalizations l10n) {
    final available = listing.totalQuantity - listing.reservedQuantity;
    final percentage = listing.totalQuantity > 0 ? (available / listing.totalQuantity) : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.inventory_status_label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              Text(l10n.items_left_label(available), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: primaryGreen)),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(100)),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: percentage > 0.3 ? primaryGreen : const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InventoryItem(label: l10n.total_label.toUpperCase(), value: '${listing.totalQuantity}'),
              _InventoryItem(label: l10n.reserved_label.toUpperCase(), value: '${listing.reservedQuantity}', color: const Color(0xFFF59E0B)),
              _InventoryItem(label: l10n.available_label.toUpperCase(), value: '$available', color: primaryGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(AppLocalizations l10n) {
    final timeFmt = DateFormat('HH:mm');
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.listing_details_label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.category_outlined, l10n.category_label, listing.categoryLabel),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFF3F4F6))),
          _buildInfoRow(Icons.access_time_rounded, l10n.pickup_window_label, '${timeFmt.format(listing.pickupStart)} - ${timeFmt.format(listing.pickupEnd)}'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFF3F4F6))),
          _buildInfoRow(Icons.calendar_today_rounded, l10n.date_posted_label, DateFormat('MMM dd, yyyy').format(listing.createdAt)),
          if (listing.dietaryTags.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFF3F4F6))),
            _buildDietaryRow(l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: primaryGreen),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade400)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          ],
        ),
      ],
    );
  }

  Widget _buildDietaryRow(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dietary_options_label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade400)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: listing.dietaryTags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100), border: Border.all(color: primaryGreen.withOpacity(0.1))),
            child: Text(tag.name.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: primaryGreen)),
          )).toList(),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

class _InventoryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InventoryItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color ?? const Color(0xFF111827))),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade400)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ListingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String text;

    switch (status) {
      case ListingStatus.active: color = const Color(0xFF16A34A); text = l10n.status_active; break;
      case ListingStatus.soldOut: color = const Color(0xFFF59E0B); text = l10n.status_sold_out; break;
      case ListingStatus.expired: color = const Color(0xFFEF4444); text = l10n.status_expired; break;
      case ListingStatus.draft: color = const Color(0xFF6B7280); text = l10n.status_draft; break;
      case ListingStatus.paused: color = const Color(0xFF6B7280); text = l10n.status_paused; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
      child: Text(text.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
    );
  }
}



