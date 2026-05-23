import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_pickup_request_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_cubit.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_state.dart';
import 'package:animate_do/animate_do.dart';
import 'package:anti_food_waste_app/core/config/app_config.dart';

class CharityDonationDetailScreen extends StatelessWidget {
  final CharityDonation donation;

  const CharityDonationDetailScreen({super.key, required this.donation});

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color secondaryGreen = Color(0xFF2D8659);
  static const Color textDark = Color(0xFF081C15);
  static const Color accentBeige = Colors.white;
  static const Color surfaceWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: accentBeige,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, l10n),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(l10n),
                      const SizedBox(height: 24),
                      if (donation.urgency != UrgencyLevel.normal)
                        _buildUrgencyBanner(l10n),
                      const SizedBox(height: 8),
                      _buildKeyStats(l10n),
                      const SizedBox(height: 24),
                      _buildDescriptionSection(l10n),
                      const SizedBox(height: 24),
                      _buildDietarySection(l10n),
                      const SizedBox(height: 24),
                      _buildPickupWindowSection(l10n),
                      const SizedBox(height: 24),
                      _buildMerchantSection(l10n),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildStickyButton(context, l10n),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryGreen,
      surfaceTintColor: primaryGreen,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.2),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.2),
            child: IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.link_copied_msg)),
                );
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (donation.imageUrl != null && donation.imageUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: _getFullImageUrl(donation.imageUrl!),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: primaryGreen.withOpacity(0.05),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: primaryGreen,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildFallbackHeader(),
              )
            else
              _buildFallbackHeader(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackHeader() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryGreen, secondaryGreen],
            ),
          ),
        ),
        Center(
          child: FadeIn(
            duration: const Duration(seconds: 1),
            child: Icon(
              _categoryIcon(donation.category),
              size: 140,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
            ),
            child: Icon(_categoryIcon(donation.category), size: 48, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(AppLocalizations l10n) {
    final diff = DateTime.now().difference(donation.postedAt);
    final postedText = diff.inMinutes < 60
        ? l10n.posted_min_ago(diff.inMinutes)
        : l10n.posted_hours_ago(diff.inHours);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                donation.categoryLabel,
                style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
              ),
            ),
            Text(
              postedText,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade400),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          donation.title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -0.5),
        ),
      ],
    );
  }

  Widget _buildUrgencyBanner(AppLocalizations l10n) {
    final isCritical = donation.urgency == UrgencyLevel.critical;
    final color = isCritical ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
    final hoursLeft = donation.expiresAt.difference(DateTime.now()).inHours;
    final label = isCritical ? l10n.expiring_soon_act_now : l10n.expiring_in_hours(hoursLeft);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt_rounded, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyStats(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: _StatBox(icon: Icons.scale_rounded, value: '${donation.quantityKg} kg', label: l10n.quantity_label)),
        const SizedBox(width: 12),
        Expanded(child: _StatBox(icon: Icons.groups_rounded, value: '~${donation.estimatedServings}', label: l10n.servings_label(donation.estimatedServings))),
        const SizedBox(width: 12),
        Expanded(child: _StatBox(icon: Icons.near_me_rounded, value: '${donation.distanceKm} km', label: l10n.distance_label)),
      ],
    );
  }

  Widget _buildDescriptionSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.about_donation, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textDark)),
          const SizedBox(height: 12),
          Text(
            donation.description,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.6, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDietarySection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.dietary_info, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textDark)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: donation.dietaryTags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(tag, style: const TextStyle(color: primaryGreen, fontSize: 13, fontWeight: FontWeight.w800)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupWindowSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_filled_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(l10n.pickup_window, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${donation.pickupWindowStart} – ${donation.pickupWindowEnd}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
          ),
          const SizedBox(height: 4),
          Text(l10n.today, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const Icon(Icons.info_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.pickup_window_warning,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: primaryGreen.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.storefront_rounded, color: primaryGreen, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(donation.merchantName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textDark)),
                    Text(l10n.about_merchant, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _InfoRow(icon: Icons.location_on_rounded, label: l10n.pickup_location, value: donation.merchantAddress),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: Color(0xFF2D8659), size: 16),
              const SizedBox(width: 8),
              Text(l10n.verified_merchant, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF2D8659))),
              const Spacer(),
              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text('4.8', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyButton(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<CharityCubit, CharityState>(
      builder: (context, state) {
        var hasRequested = false;
        if (state is CharityLoaded) {
          hasRequested = state.myRequests.any((req) => req.donationId == donation.id);
        }

        final isAvailable = donation.status == DonationStatus.available && !hasRequested;
        String buttonLabel = hasRequested ? l10n.already_requested : l10n.request_pickup;

        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            decoration: BoxDecoration(
              color: surfaceWhite,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -8))],
            ),
            child: ElevatedButton(
              onPressed: isAvailable ? () => _handleRequest(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Text(buttonLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            ),
          ),
        );
      },
    );
  }

  void _handleRequest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CharityCubit>(),
          child: CharityPickupRequestScreen(donation: donation),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBox({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: CharityDonationDetailScreen.surfaceWhite, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: CharityDonationDetailScreen.primaryGreen.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Icon(icon, size: 20, color: CharityDonationDetailScreen.primaryGreen),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: CharityDonationDetailScreen.textDark)),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade400),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 0.5)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: CharityDonationDetailScreen.textDark)),
            ],
          ),
        ),
      ],
    );
  }
}



String _getFullImageUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  
  final uri = Uri.parse(AppConfig.baseUrl);
  final baseUrl = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
  
  final cleanPath = path.startsWith('/') ? path : '/$path';
  
  if (!cleanPath.contains('/media/') && !cleanPath.contains('/static/')) {
    return '$baseUrl/media$cleanPath';
  }
  
  return '$baseUrl$cleanPath';
}

IconData _categoryIcon(DonationCategory c) {
  switch (c) {
    case DonationCategory.bakery: return Icons.breakfast_dining_rounded;
    case DonationCategory.restaurant: return Icons.restaurant_rounded;
    case DonationCategory.grocery: return Icons.local_grocery_store_rounded;
    case DonationCategory.cafe: return Icons.local_cafe_rounded;
    case DonationCategory.hotel: return Icons.hotel_rounded;
  }
}



