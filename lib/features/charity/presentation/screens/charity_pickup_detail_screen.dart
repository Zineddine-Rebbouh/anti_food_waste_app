import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_cubit.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/features/charity/presentation/widgets/charity_status_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:anti_food_waste_app/features/orders/presentation/screens/route_plan_screen.dart';
import 'package:anti_food_waste_app/features/charity/presentation/screens/charity_confirm_collection_screen.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import 'package:anti_food_waste_app/core/config/app_config.dart';

class CharityPickupDetailScreen extends StatelessWidget {
  final String requestId;

  const CharityPickupDetailScreen({super.key, required this.requestId});

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color secondaryGreen = Color(0xFF2D8659);
  static const Color accentBeige = Colors.white;
  static const Color textDark = Color(0xFF081C15);
  static const Color surfaceWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharityCubit, CharityState>(
      builder: (context, state) {
        if (state is! CharityLoaded) {
          return const Scaffold(
            backgroundColor: accentBeige,
            body: Center(child: CircularProgressIndicator(color: primaryGreen)),
          );
        }

        final request = state.myRequests.firstWhere(
          (r) => r.id == requestId,
          orElse: () => throw Exception('Request not found'),
        );

        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          backgroundColor: accentBeige,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(request, context, l10n),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(request, l10n, context),
                      const SizedBox(height: 32),
                      _buildTimelineSection(request, l10n, context),
                      const SizedBox(height: 24),
                      _buildMerchantSection(request, l10n),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: _buildBottomAction(request, l10n, context),
        );
      },
    );
  }

  Widget _buildSliverAppBar(CharityPickupRequest request, BuildContext context, AppLocalizations l10n) {
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
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'pickup_${request.id}',
              child: request.listingPhoto.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _getFullImageUrl(request.listingPhoto),
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
                      errorWidget: (context, url, error) => Container(
                        color: primaryGreen.withOpacity(0.1),
                        child: Icon(Icons.image_not_supported_rounded, size: 48, color: primaryGreen.withOpacity(0.3)),
                      ),
                    )
                  : Container(
                      color: primaryGreen,
                      child: Icon(Icons.restaurant_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
                    ),
            ),
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
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: CharityStatusBadge(status: request.status),
            ),
          ],
        ),
      ),
      actions: [
        if (request.status != PickupRequestStatus.collected && request.status != PickupRequestStatus.cancelled)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.2),
              child: IconButton(
                icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 20),
                onPressed: () => _showQrDialog(context, request, l10n),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderSection(CharityPickupRequest request, AppLocalizations l10n, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          request.donationTitle,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.schedule_rounded, size: 16, color: primaryGreen.withOpacity(0.6)),
            const SizedBox(width: 8),
            Text(
              '${l10n.today} at ${_formatTime(request.scheduledPickupTime)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (request.status == PickupRequestStatus.approved || request.status == PickupRequestStatus.enRoute)
          ElevatedButton.icon(
            onPressed: () => _handlePlanRoute(context, request),
            icon: const Icon(Icons.directions_rounded),
            label: Text(l10n.plan_route),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
      ],
    );
  }

  Widget _buildTimelineSection(CharityPickupRequest request, AppLocalizations l10n, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: primaryGreen.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.activity_overview,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTimeline(request, l10n),
        ],
      ),
    );
  }

  Widget _buildTimeline(CharityPickupRequest request, AppLocalizations l10n) {
    final steps = [
      {'label': l10n.request_sent, 'done': true},
      {
        'label': l10n.merchant_approved,
        'done': request.status == PickupRequestStatus.approved ||
            request.status == PickupRequestStatus.enRoute ||
            request.status == PickupRequestStatus.collected,
      },
      {
        'label': l10n.en_route,
        'done': request.status == PickupRequestStatus.enRoute ||
            request.status == PickupRequestStatus.collected,
      },
      {
        'label': l10n.collected_check,
        'done': request.status == PickupRequestStatus.collected,
      },
    ];

    return Column(
      children: List.generate(steps.length, (idx) {
        final step = steps[idx];
        final isDone = step['done'] as bool;
        final isLast = idx == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDone ? primaryGreen : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: isDone
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isDone ? primaryGreen : Colors.grey.shade100,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                  child: Text(
                    step['label'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isDone ? FontWeight.w800 : FontWeight.w600,
                      color: isDone ? textDark : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMerchantSection(CharityPickupRequest request, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: primaryGreen.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.storefront_rounded, color: primaryGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.merchantName,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark),
                    ),
                    Text(
                      l10n.about_merchant,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _InfoRow(
            icon: Icons.location_on_rounded,
            label: l10n.pickup_location,
            value: request.merchantAddress,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.phone_rounded,
            label: l10n.contact_label,
            value: request.merchantPhone,
            onTap: () => launchUrl(Uri.parse('tel:${request.merchantPhone}')),
          ),
        ],
      ),
    );
  }

  void _showQrDialog(BuildContext context, CharityPickupRequest request, AppLocalizations l10n) {
    final qrContent = jsonEncode({
      'requestId': request.id,
      'type': 'donation_pickup',
      'charity': request.charityName,
    });

    showDialog(
      context: context,
      builder: (ctx) => FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: primaryGreen.withOpacity(0.08), shape: BoxShape.circle),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: primaryGreen),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.scan_qr_code,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.show_qr_at_pickup,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 32),
                QrImageView(
                  data: qrContent,
                  size: 240,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: textDark),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: textDark),
                ),
                const SizedBox(height: 24),
                Text(
                  '${l10n.request_id_label}: ${request.id}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 1),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction(CharityPickupRequest request, AppLocalizations l10n, BuildContext context) {
    if (request.status != PickupRequestStatus.approved && request.status != PickupRequestStatus.enRoute) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: primaryGreen.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -8)),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CharityCubit>(),
                child: CharityConfirmCollectionScreen(request: request),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text(
          l10n.mark_collected,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  void _handlePlanRoute(BuildContext context, CharityPickupRequest request) {
    context.read<CharityCubit>().updateRequestStatus(request.id, PickupRequestStatus.enRoute);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => BlocProvider.value(
          value: context.read<CharityCubit>(),
          child: RoutePlanScreen(orderIds: [request.id], prefix: 'donations'),
        ),
      ),
    );
  }

  String _getFullImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    
    // Extract base URL from AppConfig
    final uri = Uri.parse(AppConfig.baseUrl);
    final baseUrl = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
    
    // Ensure the path starts with /
    final cleanPath = path.startsWith('/') ? path : '/$path';
    
    // Handle Django media paths if they don't include /media/
    if (!cleanPath.contains('/media/') && !cleanPath.contains('/static/')) {
      return '$baseUrl/media$cleanPath';
    }
    
    return '$baseUrl$cleanPath';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoRow({required this.icon, required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: CharityPickupDetailScreen.primaryGreen.withOpacity(0.05), shape: BoxShape.circle),
              child: Icon(icon, size: 16, color: CharityPickupDetailScreen.primaryGreen.withOpacity(0.6)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade500)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: CharityPickupDetailScreen.textDark),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}



