import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/create_listing/merchant_create_listing_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_qr_scanner_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/utils/l10n_utils.dart';
import 'package:anti_food_waste_app/core/navigation/app_router.dart';
import 'package:anti_food_waste_app/features/billing/presentation/cubits/billing_cubit.dart';
import 'package:anti_food_waste_app/features/billing/presentation/widgets/subscription_banner.dart';
import 'package:anti_food_waste_app/features/billing/presentation/screens/subscription_gate_screen.dart';



class MerchantHomeScreen extends StatelessWidget {
  const MerchantHomeScreen({super.key});

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color accentBeige = Colors.white;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<MerchantCubit, MerchantState>(
      builder: (context, state) {
        if (state is MerchantLoading) {
          return const Scaffold(
            backgroundColor: accentBeige,
            body: Center(child: CircularProgressIndicator(color: primaryGreen)),
          );
        }
        if (state is MerchantError) {
          return Scaffold(
            backgroundColor: accentBeige,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(L10nUtils.translateError(state.message, l10n),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<MerchantCubit>().load(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state is! MerchantLoaded) {
          return const Scaffold(
            backgroundColor: accentBeige,
            body: Center(child: CircularProgressIndicator(color: primaryGreen)),
          );
        }

        return Scaffold(
          backgroundColor: accentBeige,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SubscriptionBanner(),
                _buildHeader(context, state, l10n),
                _buildStats(context, state, l10n),
                _buildQuickActions(context, l10n),
                _buildRecentActivity(context, state, l10n),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, MerchantLoaded state, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, Color(0xFF0D2119)],
        ),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(48), bottomRight: Radius.circular(48)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  shape: BoxShape.circle),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFFD54F),
                                  borderRadius: BorderRadius.circular(16)),
                              alignment: Alignment.center,
                              child: Text(state.profile.initials,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.profile.businessName,
                                    softWrap: true,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildVerifiedBadge(l10n),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.notifications),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.notifications_none_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.merchant_overview,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1),
                  ),
                  Text(
                    l10n.your_impact,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedBadge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded, color: primaryGreen, size: 15),
          const SizedBox(width: 5),
          Text(
            l10n.verified_label,
            style: const TextStyle(
              color: primaryGreen,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
      BuildContext context, MerchantLoaded state, AppLocalizations l10n) {
    final stats = state.profile.dailyStats;
    return Transform.translate(
      offset: const Offset(0, -25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child: _StatCard(
                      icon: Icons.shopping_bag_rounded,
                      color: const Color(0xFF2D8659),
                      value: "${stats.ordersToday}",
                      label: l10n.orders_label,
                      delta: l10n.today)),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatCard(
                      icon: Icons.payments_rounded,
                      color: const Color(0xFF3B82F6),
                      value: "${stats.revenueToday.toInt()}",
                      label: l10n.merchant_revenue,
                      badge: l10n.net_label)),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatCard(
                      icon: Icons.eco_rounded,
                      color: AppTheme.primary,
                      value: "${stats.foodSavedKgToday.toInt()} kg",
                      label: l10n.merchant_food_saved,
                      delta: l10n.co2_avoided)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.quick_actions.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade400,
                  letterSpacing: 1.5)),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ActionCard(
                    title: l10n.add_listing,
                    subtitle: l10n.add_listing_desc,
                    icon: Icons.add_rounded,
                    color: Colors.white.withOpacity(0.4),
                    onTap: () {
                      final billingState = context.read<BillingCubit>().state;
                      if (billingState is BillingLoaded && !billingState.subscription.isBillingActive) {
                        SubscriptionGateScreen.show(context);
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => BlocProvider.value(
                                value: context.read<MerchantCubit>(),
                                child: const MerchantCreateListingScreen())));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    title: l10n.scan_qr,
                    subtitle: l10n.scan_qr_desc,
                    icon: Icons.qr_code_scanner_rounded,
                    color: const Color(0xFF2D8659).withOpacity(0.08),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => BlocProvider.value(
                            value: context.read<MerchantCubit>(),
                            child: const MerchantQrScannerScreen()))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(
      BuildContext context, MerchantLoaded state, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.recent_activity.toUpperCase(),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey.shade400,
                      letterSpacing: 1.5)),
              Text(l10n.see_all,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: primaryGreen)),
            ],
          ),
          const SizedBox(height: 20),
          _ActivityTile(
              title: "Plat Chorba Frik",
              status: "Picked up",
              quantity: "1x",
              price: "150 DZD",
              time: "Just now",
              color: const Color(0xFF2D8659)),
          const SizedBox(height: 12),
          _ActivityTile(
              title: "Traditional Bread Basket",
              status: "Reserved",
              quantity: "1x",
              price: "350 DZD",
              time: "13h ago",
              color: const Color(0xFFF59E0B)),
          const SizedBox(height: 12),
          _ActivityTile(
              title: "Menu Loubia / Adas",
              status: "Completed",
              quantity: "1x",
              price: "150 DZD",
              time: "17d ago",
              color: Colors.grey.shade200),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String? delta;
  final String? badge;

  const _StatCard(
      {required this.icon,
      required this.color,
      required this.value,
      required this.label,
      this.delta,
      this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 16),
          Text(value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827))),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade400),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          if (delta != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(100)),
              child: Text(delta!,
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF16A34A))),
            ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(100)),
              child: Text(badge!,
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3B82F6))),
            ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: const Color(0xFF2D8659), size: 22),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827))),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String status;
  final String quantity;
  final String price;
  final String time;
  final Color color;

  const _ActivityTile(
      {required this.title,
      required this.status,
      required this.quantity,
      required this.price,
      required this.time,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.shopping_bag_rounded,
                color: color == Colors.grey.shade200 ? Colors.grey : color,
                size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.circle,
                        color:
                            color == Colors.grey.shade200 ? Colors.grey : color,
                        size: 8),
                    const SizedBox(width: 6),
                    Text("$status · $quantity",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827))),
              Text(time,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }
}
