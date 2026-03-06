import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListingCard extends StatefulWidget {
  final FoodListing listing;
  final VoidCallback onTap;
  final bool isFavorite;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.isFavorite = false,
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        color: Colors.white, // Pure white background, no tint
        surfaceTintColor:
            Colors.transparent, // Ensures pure white without M3 tinting
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Image section
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      widget.listing.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Monochromatic Badges
                  Positioned(
                    top: 10,
                    left: isRtl ? null : 10,
                    right: isRtl ? 10 : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            Colors.red[600], // Kept red for discount visibility
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-${widget.listing.discountPercent}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Grade Badge (White/Glass effect instead of green)
                  Positioned(
                    bottom: 10,
                    left: isRtl ? null : 10,
                    right: isRtl ? 10 : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        '${l10n.grade.toUpperCase()} ${widget.listing.freshness.name}',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Favorite
                  Positioned(
                    top: 10,
                    right: isRtl ? null : 10,
                    left: isRtl ? 10 : null,
                    child: GestureDetector(
                      onTap: () => setState(() => isFavorite = !isFavorite),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey[400],
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  // Merchant Logo (Bottom Right)
                  Positioned(
                    bottom: 10,
                    right: isRtl ? null : 10,
                    left: isRtl ? 10 : null,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.storefront_outlined,
                            size: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),

              // 2. Info Section (Refined & Compact)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: Logo + Title (Left) | Discounted Price (Right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.listing.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF222222),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.listing.discountedPrice.toInt()} ${l10n.dzd}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222222),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Row 2: Merchant Name (Left) | Original Price (Right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.listing.merchantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500]),
                          ),
                        ),
                        Text(
                          '${widget.listing.originalPrice.toInt()} ${l10n.dzd}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Row 3: Pickup Time (Left) | Meta info (Right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Pickup Window
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 11, color: Colors.grey[400]),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.listing.pickupStart} - ${widget.listing.pickupEnd}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Distance & Rating
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 11, color: Colors.grey[400]),
                                const SizedBox(width: 2),
                                Text(
                                  '${widget.listing.distance} ${l10n.km}',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    size: 11, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(
                                  '${widget.listing.rating}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (widget.listing.quantityLeft < 5) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.only_left(widget.listing.quantityLeft),
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
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

  Color _getFreshnessColor(FreshnessGrade grade) {
    switch (grade) {
      case FreshnessGrade.A:
        return const Color(0xFF2D8659);
      case FreshnessGrade.B:
        return Colors.amber[700]!;
      case FreshnessGrade.C:
        return Colors.orange[700]!;
    }
  }
}
