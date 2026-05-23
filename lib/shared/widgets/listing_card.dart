import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/core/services/wilaya_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ListingCard extends StatefulWidget {
  final FoodListing listing;
  final VoidCallback onTap;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteToggle;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(covariant ListingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      isFavorite = widget.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image section with overlays
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: widget.listing.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.listing.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                _buildImageFallback(),
                            placeholder: (context, url) =>
                                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : _buildImageFallback(),
                  ),
                  // Gradient Overlay for better contrast
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Glassmorphic Discount Badge
                  Positioned(
                    top: 12,
                    left: isRtl ? null : 12,
                    right: isRtl ? 12 : null,
                    child: _GlassBadge(
                      color: const Color(0xFFEF4444),
                      child: Text(
                        '-${widget.listing.discountPercent}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 12,
                    right: isRtl ? null : 12,
                    left: isRtl ? 12 : null,
                    child: GestureDetector(
                      onTap: () {
                        final next = !isFavorite;
                        setState(() => isFavorite = next);
                        widget.onFavoriteToggle?.call(next);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? const Color(0xFFEF4444) : Colors.grey[600],
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  // Freshness Grade (Bottom Left)
                  Positioned(
                    bottom: 12,
                    left: isRtl ? null : 12,
                    right: isRtl ? 12 : null,
                    child: _GlassBadge(
                      color: Colors.white.withOpacity(0.2),
                      blur: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: _getFreshnessColor(widget.listing.freshness), size: 10),
                          const SizedBox(width: 4),
                          Text(
                            'GRADE ${widget.listing.freshness.name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Urgency Badge (Bottom Right)
                  if (widget.listing.urgencyLabel != 'normal')
                    Positioned(
                      bottom: 12,
                      right: isRtl ? null : 12,
                      left: isRtl ? 12 : null,
                      child: _GlassBadge(
                        color: widget.listing.urgencyLabel == 'critical' 
                            ? const Color(0xFFEF4444) 
                            : const Color(0xFFF59E0B),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.flash_on, color: Colors.white, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              widget.listing.urgencyLabel.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // 2. Info Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Merchant & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: widget.listing.merchantLogoUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: widget.listing.merchantLogoUrl,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.store, size: 12, color: Colors.grey),
                                        )
                                      : const Icon(Icons.store, size: 12, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.listing.merchantName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.listing.rating}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      widget.listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Price & Meta
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${widget.listing.discountedPrice.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  l10n.dzd,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.listing.originalPrice.toInt()} ${l10n.dzd}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[400]),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.listing.pickupStart} - ${widget.listing.pickupEnd}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 12, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Text(
                                widget.listing.distance > 0 
                                    ? WilayaService.formatDistance(widget.listing.distance)
                                    : l10n.nearby,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (widget.listing.quantityLeft < 5) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department, color: Color(0xFFDC2626), size: 14),
                            const SizedBox(width: 6),
                            Text(
                              l10n.only_left(widget.listing.quantityLeft),
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(Icons.restaurant_outlined, size: 40, color: Colors.grey[300]),
      ),
    );
  }

  Widget _buildImageLoading(ImageChunkEvent loadingProgress) {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
          color: AppTheme.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Color _getFreshnessColor(FreshnessGrade grade) {
    switch (grade) {
      case FreshnessGrade.A:
        return AppTheme.primary;
      case FreshnessGrade.B:
        return const Color(0xFFF59E0B);
      case FreshnessGrade.C:
        return const Color(0xFFEF4444);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _GlassBadge extends StatelessWidget {
  final Widget child;
  final Color color;
  final double blur;

  const _GlassBadge({
    required this.child,
    required this.color,
    this.blur = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: color.withOpacity(0.8),
          child: child,
        ),
      ),
    );
  }
}
