import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/core/providers/favorites_provider.dart';
import 'package:anti_food_waste_app/features/consumer/data/repositories/consumer_repository.dart';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';
import 'package:anti_food_waste_app/shared/models/listing_extra_details.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingDetailScreen extends StatefulWidget {
  final FoodListing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  int? _expandedFaqIndex;
  final int _viewingCount = 12;
  Timer? _countdownTimer;

  ListingExtraDetails? _details;
  bool _isLoadingDetail = true;
  bool _isReserving = false;
  bool _isNotFound = false;
  String? _detailErrorMessage;

  final _repository = ConsumerRepository();

  String get _listingId => widget.listing.id.trim();

  @override
  void initState() {
    super.initState();
    _loadDetail();
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }
  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    if (_listingId.isEmpty) {
      setState(() {
        _isLoadingDetail = false;
        _isNotFound = false;
        _detailErrorMessage =
            'Could not load this offer right now. Please try again.';
      });
      return;
    }

    setState(() {
      _isLoadingDetail = true;
      _isNotFound = false;
      _detailErrorMessage = null;
    });

    try {
        final details = await _repository.fetchListingExtraDetails(_listingId);
      if (mounted) {
        setState(() {
          _details = details;
          _isLoadingDetail = false;
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final status = e.response?.statusCode;
      setState(() {
        _isLoadingDetail = false;
        _isNotFound = status == 404;
        _detailErrorMessage = status == 404
            ? null
            : 'Could not load this offer right now. Please try again.';
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingDetail = false;
          _isNotFound = false;
          _detailErrorMessage =
              'Could not load this offer right now. Please try again.';
        });
      }
    }
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

  Future<void> _handleReserve() async {
    if (_isReserving) return;
    setState(() => _isReserving = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    try {
      await _repository.createOrder(
        listingId: _listingId,
        quantity: _quantity,
      );
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.added_to_cart),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Could not place order. Please try again.';
        if (e is DioException && e.response?.data != null) {
          try {
            msg = e.response!.data['error']['message'] as String;
          } catch (_) {
            if (e.response?.statusCode == 409) msg = 'Not enough stock available.';
          }
        } else if (e.toString().contains('409')) {
          msg = 'Not enough stock available.';
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isReserving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavorite(_listingId);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // Show spinner while loading from API
    if (_isLoadingDetail) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_details == null && _isNotFound) {
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

    if (_details == null && _detailErrorMessage != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_outlined,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _detailErrorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadDetail,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(l10n, isRtl, favorites, isFavorite),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildHeaderSection(l10n),
                      const SizedBox(height: 32),
                      _buildPricingCard(l10n),
                      const SizedBox(height: 32),
                      _buildPickupWindowCard(l10n),
                      const SizedBox(height: 24),
                      _buildLocationCard(l10n),
                      const SizedBox(height: 24),
                      _buildWhatYouGetCard(l10n),
                      const SizedBox(height: 32),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1)),
                      const SizedBox(height: 32),
                      _buildMerchantCard(l10n),
                      const SizedBox(height: 32),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1)),
                      const SizedBox(height: 32),
                      _buildAvailabilityCard(l10n),
                      const SizedBox(height: 32),
                      if (_details!.reviews.isNotEmpty) ...[
                        _buildReviewsCard(l10n),
                        const SizedBox(height: 32),
                      ],
                      if (_details!.faqs.isNotEmpty) ...[
                        _buildFaqCard(l10n),
                        const SizedBox(height: 32),
                      ],
                      const SizedBox(height: 140), // More bottom padding for footer
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

  Widget _buildSliverAppBar(
    AppLocalizations l10n,
    bool isRtl,
    FavoritesProvider favorites,
    bool isFavorite,
  ) {
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
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.black,
              ),
              onPressed: () async {
                final target = !isFavorite;
                try {
                  await favorites.toggleFavorite(
                    _listingId,
                    desiredState: target,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(target
                          ? l10n.added_to_favorites
                          : l10n.removed_from_favorites),
                    ),
                  );
                } catch (_) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not update favorites. Please try again.'),
                    ),
                  );
                }
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
                final imageUrl = _details!.images[index];
                if (imageUrl.isEmpty) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  );
                }
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            color: const Color(0xFFF5F5F7),
                            child: const Icon(Icons.broken_image_outlined, size: 50, color: Color(0xFFC7C7CC)),
                          ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black26,
                            Colors.transparent,
                            Colors.black38,
                          ],
                          stops: [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ],
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
                        _getFreshnessIndicator(widget.listing.freshness),
                        const SizedBox(width: 6),
                        Text(
                          _getFreshnessLabel(widget.listing.freshness, l10n),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11),
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

  Widget _buildSectionHeader(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getSectionIcon(label),
              size: 14,
              color: const Color(0xFF8E8E93),
            ),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8E8E93),
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildHeaderSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getCategoryIcon(widget.listing.category),
              size: 16,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              _getCategoryLabel(widget.listing.category, l10n).toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.listing.title,
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.foreground,
              height: 1.2),
        ),
        const SizedBox(height: 8),
        Text(
          _details!.description,
          style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF636366),
              height: 1.5,
              fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _buildPricingCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E5EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(l10n.pricing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${widget.listing.discountedPrice.toInt()} ${l10n.dzd}',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${widget.listing.originalPrice.toInt()} ${l10n.dzd}',
                style: const TextStyle(
                  color: Color(0xFFC7C7CC),
                  decoration: TextDecoration.lineThrough,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${l10n.you_save}: ${widget.listing.savings.toInt()} ${l10n.dzd} (${widget.listing.discountPercent}% ${l10n.off})',
              style: const TextStyle(
                color: Color(0xFF2D8659),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCountdownText(AppLocalizations l10n) {
    if (widget.listing.pickupEnd.isEmpty) return ' 2h 15m';
    try {
      final parts = widget.listing.pickupEnd.split(':');
      if (parts.length < 2) return '';
      final hour = int.parse(parts[0]);
      final min = int.parse(parts[1]);
      final now = DateTime.now();
      var target = DateTime(now.year, now.month, now.day, hour, min);
      if (now.isAfter(target)) {
        return 'Pickup ended';
      }
      final diff = target.difference(now);
      if (diff.inHours > 0) {
        return ' h m';
      } else {
        return ' m';
      }
    } catch (_) {
      return '';
    }
  }
  Widget _buildPickupWindowCard(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.pickup_window),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E5EA).withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.today}, ${widget.listing.pickupStart} - ${widget.listing.pickupEnd}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Color(0xFF8E8E93)),
                  const SizedBox(width: 6),
                  Text(
                    _getCountdownText(l10n),
                    style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.pickup_location),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _details!.address,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.4),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.listing.distance} km ${l10n.from_you}',
                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.map_outlined, size: 16),
                      label: Text(l10n.view_map),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        side: BorderSide(color: AppTheme.primary.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handleGetDirections,
                      icon: const Icon(Icons.navigation_outlined, size: 16),
                      label: Text(l10n.get_directions),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWhatYouGetCard(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.what_you_get),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F1F1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._details!.whatYouGet.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(Icons.check_circle_outline, size: 16, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(item,
                                style: const TextStyle(color: Color(0xFF3A3A3C), fontSize: 15, height: 1.4))),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
              if (widget.listing.dietary.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.listing.dietary.map((diet) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getDietaryIcon(diet), size: 14, color: const Color(0xFF48484A)),
                          const SizedBox(width: 6),
                          Text(_getDietaryLabel(diet, l10n),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF48484A))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMerchantCard(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.about_merchant),
        Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: _details!.merchant.logoUrl != null && _details!.merchant.logoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(_details!.merchant.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.store, color: Color(0xFF8E8E93), size: 32),
                            ))
                    : Text(
                        _details!.merchant.name.substring(0, 1),
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary),
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
                          fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFCC00), size: 20),
                      const SizedBox(width: 4),
                      Text(widget.listing.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(width: 4),
                      Text('(${widget.listing.reviewCount} ${l10n.results})',
                          style: const TextStyle(
                              color: Color(0xFF8E8E93), fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          _details!.merchant.bio,
          style: const TextStyle(color: Color(0xFF48484A), fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMerchantStat(
                  _details!.merchant.mealsSaved.toString(), l10n.repas),
              Container(width: 1, height: 30, color: const Color(0xFFE5E5EA)),
              _buildMerchantStat('${_details!.merchant.fulfillmentRate}%',
                  l10n.fulfillment_rate),
              Container(width: 1, height: 30, color: const Color(0xFFE5E5EA)),
              _buildMerchantStat('2023', l10n.member_since),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
                child: ElevatedButton.icon(
                    onPressed: _handleCall,
                    icon: const Icon(Icons.phone_rounded, size: 16),
                    label: Text(l10n.call),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      elevation: 0,
                      side: BorderSide(color: AppTheme.primary.withOpacity(0.3), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(0, 48),
                    ))),
            const SizedBox(width: 12),
            Expanded(
                child: ElevatedButton(
                    onPressed: () {}, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C1C1E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(0, 48),
                    ),
                    child: Text(l10n.view_profile))),
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
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
                fontSize: 20)),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: Color(0xFF8E8E93), fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildAvailabilityCard(AppLocalizations l10n) {
    final isLowStock = widget.listing.quantityLeft < 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.availability),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isLowStock ? const Color(0xFFFFF2F2) : const Color(0xFFF2F9F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isLowStock ? const Color(0xFFFFD6D6) : const Color(0xFFD6EBD6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Icon(
                    isLowStock ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                    color: isLowStock ? const Color(0xFFFF3B30) : const Color(0xFF34C759),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isLowStock
                        ? '${l10n.only} ${widget.listing.quantityLeft} ${l10n.left}'
                        : '${widget.listing.quantityLeft} ${l10n.bags_available}',
                    style: TextStyle(
                        color: isLowStock ? const Color(0xFFFF3B30) : const Color(0xFF248A3D),
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
                  Text(
                    l10n.people_viewing(_viewingCount),
                    style: TextStyle(
                      color: isLowStock ? const Color(0xFFB03129) : const Color(0xFF3E7A4A),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsCard(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.reviews),
        Row(
          children: [
            Text(widget.listing.rating.toString(),
                style:
                    const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E))),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                      5,
                      (index) => Icon(
                            Icons.star_rounded,
                            size: 20,
                            color: index < widget.listing.rating.floor()
                                ? const Color(0xFFFFCC00)
                                : const Color(0xFFE5E5EA),
                          )),
                ),
                const SizedBox(height: 4),
                Text('${widget.listing.reviewCount} ${l10n.results}',
                    style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        ..._details!.reviews
            .take(2)
            .map((review) => _buildReviewItem(review, l10n)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2F2F7),
                foregroundColor: const Color(0xFF1C1C1E),
                elevation: 0,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                  '${l10n.see_all_reviews} (${widget.listing.reviewCount})')),
        ),
      ],
    );
  }

  Widget _buildReviewItem(ListingReview review, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review.userName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1C1C1E))),
              Text(review.date,
                  style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
                5,
                (index) => Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: index < review.rating
                          ? const Color(0xFFFFCC00)
                          : const Color(0xFFE5E5EA),
                    )),
          ),
          const SizedBox(height: 12),
          Text(review.comment,
              style: const TextStyle(color: Color(0xFF48484A), fontSize: 14, height: 1.4)),
          if (review.merchantReply != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E5EA))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.reply_all_rounded, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(l10n.merchant_replied.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(review.merchantReply!,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF48484A), height: 1.4)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFaqCard(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.faqs),
        ..._details!.faqs.asMap().entries.map((entry) {
          final index = entry.key;
          final faq = entry.value;
          final isExpanded = _expandedFaqIndex == index;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFF1F1F1)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(faq.question,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1C1C1E))),
                  trailing: Icon(
                    isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
                    color: isExpanded ? AppTheme.primary : const Color(0xFFC7C7CC),
                    size: 20,
                  ),
                  onTap: () => setState(
                      () => _expandedFaqIndex = isExpanded ? null : index),
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(faq.answer,
                        style:
                            const TextStyle(color: Color(0xFF48484A), fontSize: 14, height: 1.5)),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
              onPressed: () {},
              child: Text(l10n.still_have_questions,
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600))),
        ),
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
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        l10n.quantity,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildQuantityBtn(
                                Icons.remove,
                                _quantity > 1
                                    ? () => setState(() => _quantity--)
                                    : null),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(_quantity.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15)),
                              ),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (canReserve && !_isReserving && !_details!.userHasReserved) ? _handleReserve : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _details!.userHasReserved ? Color(0xFFC7C7CC) : AppTheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: _isReserving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _details!.userHasReserved
                                    ? l10n.already_reserved
                                    : canReserve
                                        ? '${l10n.reserve_for} ${totalPrice.toInt()} ${l10n.dzd}'
                                        : l10n.sold_out,
                                maxLines: 1,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF34C759)),
                const SizedBox(width: 6),
                Text(l10n.payment_after_reservation,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityBtn(IconData icon, VoidCallback? onPressed) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      color: onPressed == null ? const Color(0xFFC7C7CC) : AppTheme.primary,
    );
  }

  IconData _getSectionIcon(String label) {
    if (label.toLowerCase().contains('pricing')) return Icons.payments_outlined;
    if (label.toLowerCase().contains('pickup window')) return Icons.access_time_rounded;
    if (label.toLowerCase().contains('pickup location')) return Icons.location_on_outlined;
    if (label.toLowerCase().contains('what you get')) return Icons.inventory_2_outlined;
    if (label.toLowerCase().contains('about merchant')) return Icons.storefront_rounded;
    if (label.toLowerCase().contains('faqs')) return Icons.help_outline_rounded;
    return Icons.info_outline;
  }

  IconData _getCategoryIcon(FoodCategory category) {
    switch (category) {
      case FoodCategory.bakery:
        return Icons.bakery_dining_rounded;
      case FoodCategory.restaurant:
        return Icons.restaurant_rounded;
      case FoodCategory.supermarket:
        return Icons.shopping_basket_rounded;
      case FoodCategory.cafe:
        return Icons.local_cafe_rounded;
    }
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

  Widget _getFreshnessIndicator(FreshnessGrade grade) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
          )
        ],
      ),
    );
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

  IconData _getDietaryIcon(String diet) {
    switch (diet.toLowerCase()) {
      case 'halal':
        return Icons.verified_rounded;
      case 'vegan':
        return Icons.eco_rounded;
      case 'vegetarian':
        return Icons.spa_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  String _getDietaryLabel(String diet, AppLocalizations l10n) {
    switch (diet.toLowerCase()) {
      case 'halal':
        return l10n.halal;
      case 'vegan':
        return l10n.vegan;
      default:
        return diet;
    }
  }
}


