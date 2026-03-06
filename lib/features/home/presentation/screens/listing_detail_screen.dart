import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';
import 'package:anti_food_waste_app/shared/models/listing_extra_details.dart';
import 'package:anti_food_waste_app/shared/data/mock_listing_details.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingDetailScreen extends StatefulWidget {
  final FoodListing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  int _quantity = 1;
  int? _expandedFaqIndex;
  final int _viewingCount = 12;

  ListingExtraDetails? _details;

  @override
  void initState() {
    super.initState();
    _details = mockListingExtraDetails[widget.listing.id];
  }

  void _handleShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.link_copied)),
    );
  }

  Future<void> _handleGetDirections() async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${widget.listing.lat},${widget.listing.lng}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _handleCall() async {
    if (_details == null) return;
    final url = Uri.parse('tel:${_details!.phone}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _handleReserve() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.added_to_cart)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (_details == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(l10n.listing_not_found,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.listing_not_found_desc),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.back_to_home),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(l10n, isRtl),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(l10n),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildPricingCard(l10n),
                      const SizedBox(height: 16),
                      _buildPickupWindowCard(l10n),
                      const SizedBox(height: 16),
                      _buildLocationCard(l10n),
                      const SizedBox(height: 16),
                      _buildWhatYouGetCard(l10n),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildMerchantCard(l10n),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildAvailabilityCard(l10n),
                      const SizedBox(height: 16),
                      _buildReviewsCard(l10n),
                      const SizedBox(height: 16),
                      _buildFaqCard(l10n),
                      const SizedBox(height: 100), // Bottom padding for footer
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildStickyFooter(l10n),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(AppLocalizations l10n, bool isRtl) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.9),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.black,
              ),
              onPressed: () {
                setState(() => _isFavorite = !_isFavorite);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(_isFavorite
                          ? l10n.added_to_favorites
                          : l10n.removed_from_favorites)),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.black),
              onPressed: _handleShare,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: _details!.images.length,
              onPageChanged: (index) =>
                  setState(() => _currentImageIndex = index),
              itemBuilder: (context, index) {
                return Image.network(
                  _details!.images[index],
                  fit: BoxFit.cover,
                );
              },
            ),
            // Freshness Badge
            Positioned(
              top: 100,
              right: 16,
              child: FadeInRight(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getFreshnessColor(widget.listing.freshness),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getFreshnessEmoji(widget.listing.freshness)),
                      const SizedBox(width: 4),
                      Text(
                        _getFreshnessLabel(widget.listing.freshness, l10n),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Pagination Dots
            if (_details!.images.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_details!.images.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentImageIndex == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(_getCategoryEmoji(widget.listing.category),
                style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              _getCategoryLabel(widget.listing.category, l10n),
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.listing.title,
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.foreground),
        ),
        const SizedBox(height: 8),
        Text(
          _details!.description,
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
        ),
      ],
    );
  }

  Widget _buildPricingCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💰', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(l10n.pricing,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${widget.listing.originalPrice.toInt()} ${l10n.dzd}',
                style: TextStyle(
                    color: Colors.grey[400],
                    decoration: TextDecoration.lineThrough,
                    fontSize: 16),
              ),
              const SizedBox(width: 12),
              Text(
                '${widget.listing.discountedPrice.toInt()} ${l10n.dzd}',
                style: const TextStyle(
                    color: Color(0xFF2D8659),
                    fontWeight: FontWeight.bold,
                    fontSize: 32),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.you_save}: ${widget.listing.savings.toInt()} ${l10n.dzd} (${widget.listing.discountPercent}% ${l10n.off})',
            style: const TextStyle(
                color: Color(0xFF2D8659), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupWindowCard(AppLocalizations l10n) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFF2D8659)),
                const SizedBox(width: 8),
                Text(l10n.pickup_window,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${l10n.today}, ${widget.listing.pickupStart} - ${widget.listing.pickupEnd}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (widget.listing.pickupEnd
                    .contains(':')) // Simple check for time
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${l10n.closes_in} 2h 15m', // Mocked remaining time
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(AppLocalizations l10n) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Color(0xFF2D8659)),
                const SizedBox(width: 8),
                Text(l10n.pickup_location,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(_details!.address, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              '${widget.listing.distance} km ${l10n.from_you}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: Text(l10n.view_map),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _handleGetDirections,
                    icon: const Icon(Icons.navigation_outlined, size: 18),
                    label: Text(l10n.get_directions),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatYouGetCard(AppLocalizations l10n) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📦', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(l10n.what_you_get,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ..._details!.whatYouGet.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•',
                          style: TextStyle(
                              color: Color(0xFF2D8659),
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(item,
                              style: TextStyle(color: Colors.grey[700]))),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.listing.dietary.map((diet) {
                return Chip(
                  label: Text(_getDietaryLabel(diet, l10n),
                      style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.grey[100],
                  padding: EdgeInsets.zero,
                  avatar: Text(_getDietaryEmoji(diet)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantCard(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.storefront, color: Color(0xFF2D8659)),
            const SizedBox(width: 8),
            Text(l10n.about_merchant,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF2D8659).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _details!.merchant.logoUrl != null
                    ? ClipOval(
                        child: Image.network(_details!.merchant.logoUrl!,
                            fit: BoxFit.cover))
                    : Text(
                        _details!.merchant.name.substring(0, 1),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D8659)),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_details!.merchant.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(widget.listing.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(' (${widget.listing.reviewCount} ${l10n.results})',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(_details!.merchant.bio, style: TextStyle(color: Colors.grey[700])),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMerchantStat(
                  _details!.merchant.mealsSaved.toString(), l10n.repas),
              _buildMerchantStat('${_details!.merchant.fulfillmentRate}%',
                  l10n.fulfillment_rate),
              _buildMerchantStat('2023', l10n.member_since),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: _handleCall,
                    icon: const Icon(Icons.phone_outlined, size: 18),
                    label: Text(l10n.call))),
            const SizedBox(width: 12),
            Expanded(
                child: OutlinedButton(
                    onPressed: () {}, child: Text(l10n.view_profile))),
          ],
        ),
      ],
    );
  }

  Widget _buildMerchantStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D8659),
                fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAvailabilityCard(AppLocalizations l10n) {
    final isLowStock = widget.listing.quantityLeft < 5;
    return Card(
      elevation: 0,
      color: isLowStock ? Colors.red[50] : Colors.green[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: isLowStock ? Colors.red[100]! : Colors.green[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📊', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(l10n.availability,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (isLowStock)
              Text(
                '⚠️ ${l10n.only} ${widget.listing.quantityLeft} ${l10n.left} — ${l10n.reserve_now}!',
                style: TextStyle(
                    color: Colors.red[700], fontWeight: FontWeight.bold),
              )
            else
              Text(
                '🟢 ${widget.listing.quantityLeft} ${l10n.bags_available}',
                style: TextStyle(
                    color: Colors.green[700], fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 4),
            Text('👥 $_viewingCount ${l10n.people_viewing}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsCard(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text('${l10n.reviews} (${widget.listing.reviewCount})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(widget.listing.rating.toString(),
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text('/ 5.0',
                style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: widget.listing.rating / 5,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF2D8659),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.recommended_percent(96),
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 16),
        ..._details!.reviews
            .take(2)
            .map((review) => _buildReviewItem(review, l10n)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
              onPressed: () {},
              child: Text(
                  '${l10n.see_all_reviews} (${widget.listing.reviewCount})')),
        ),
      ],
    );
  }

  Widget _buildReviewItem(ListingReview review, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(
                    5,
                    (index) => Icon(
                          Icons.star,
                          size: 14,
                          color: index < review.rating
                              ? Colors.amber
                              : Colors.grey[300],
                        )),
              ),
              const SizedBox(width: 8),
              Text(review.userName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 4),
              Text('• ${review.date}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text(review.comment,
              style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          if (review.merchantReply != null)
            Container(
              margin: const EdgeInsets.only(top: 8, left: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.merchant_replied}:',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(review.merchantReply!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(Icons.thumb_up_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${l10n.helpful} (${review.helpfulCount})',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(Icons.mode_comment_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(l10n.reply,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildFaqCard(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('❓', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(l10n.faqs,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        ..._details!.faqs.asMap().entries.map((entry) {
          final index = entry.key;
          final faq = entry.value;
          final isExpanded = _expandedFaqIndex == index;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  title: Text(faq.question,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  trailing: Icon(isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                  onTap: () => setState(
                      () => _expandedFaqIndex = isExpanded ? null : index),
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(faq.answer,
                        style:
                            TextStyle(color: Colors.grey[700], fontSize: 13)),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        TextButton(
            onPressed: () {},
            child: Text('${l10n.still_have_questions} →',
                style: const TextStyle(color: Color(0xFF2D8659)))),
      ],
    );
  }

  Widget _buildStickyFooter(AppLocalizations l10n) {
    final canReserve = widget.listing.quantityLeft > 0;
    final totalPrice = widget.listing.discountedPrice * _quantity;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.quantity,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        _buildQuantityBtn(
                            Icons.remove,
                            _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null),
                        SizedBox(
                            width: 40,
                            child: Center(
                                child: Text(_quantity.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)))),
                        _buildQuantityBtn(
                            Icons.add,
                            _quantity < widget.listing.quantityLeft
                                ? () => setState(() => _quantity++)
                                : null),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: canReserve ? _handleReserve : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D8659),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text(
                  canReserve
                      ? '${l10n.reserve_for} ${totalPrice.toInt()} ${l10n.dzd}'
                      : l10n.sold_out,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(l10n.payment_after_reservation,
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityBtn(IconData icon, VoidCallback? onPressed) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      color: onPressed == null ? Colors.grey[300] : const Color(0xFF2D8659),
    );
  }

  Color _getFreshnessColor(FreshnessGrade grade) {
    switch (grade) {
      case FreshnessGrade.A:
        return Colors.green[500]!;
      case FreshnessGrade.B:
        return Colors.yellow[700]!;
      case FreshnessGrade.C:
        return Colors.orange[700]!;
    }
  }

  String _getFreshnessLabel(FreshnessGrade grade, AppLocalizations l10n) {
    switch (grade) {
      case FreshnessGrade.A:
        return l10n.grade_a;
      case FreshnessGrade.B:
        return l10n.grade_b;
      case FreshnessGrade.C:
        return l10n.grade_c;
    }
  }

  String _getFreshnessEmoji(FreshnessGrade grade) {
    switch (grade) {
      case FreshnessGrade.A:
        return '🟢';
      case FreshnessGrade.B:
        return '🟡';
      case FreshnessGrade.C:
        return '🟠';
    }
  }

  String _getCategoryEmoji(FoodCategory category) {
    switch (category) {
      case FoodCategory.bakery:
        return '🍞';
      case FoodCategory.restaurant:
        return '🍽️';
      case FoodCategory.supermarket:
        return '🛒';
      case FoodCategory.cafe:
        return '☕';
    }
  }

  String _getCategoryLabel(FoodCategory category, AppLocalizations l10n) {
    switch (category) {
      case FoodCategory.bakery:
        return l10n.bakery;
      case FoodCategory.restaurant:
        return l10n.restaurant;
      case FoodCategory.supermarket:
        return l10n.supermarket;
      case FoodCategory.cafe:
        return l10n.cafe;
    }
  }

  String _getDietaryEmoji(String diet) {
    switch (diet) {
      case 'halal':
        return '✅';
      case 'vegan':
        return '🌱';
      default:
        return '📍';
    }
  }

  String _getDietaryLabel(String diet, AppLocalizations l10n) {
    switch (diet) {
      case 'halal':
        return l10n.halal;
      case 'vegan':
        return l10n.vegan;
      default:
        return diet;
    }
  }
}
