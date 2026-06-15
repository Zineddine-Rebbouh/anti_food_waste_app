import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/utils/l10n_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:anti_food_waste_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:anti_food_waste_app/core/navigation/app_router.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_business_profile_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_earnings_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_help_support_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_notification_settings_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_performance_analytics_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_settings_screen.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/billing/presentation/cubits/billing_cubit.dart';
import 'package:anti_food_waste_app/features/billing/presentation/screens/subscription_screen.dart';
import 'package:anti_food_waste_app/features/billing/presentation/screens/commission_summary_screen.dart';
import 'package:anti_food_waste_app/features/billing/presentation/screens/sponsored_listings_screen.dart';


class MerchantProfileScreen extends StatelessWidget {
  const MerchantProfileScreen({super.key});

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
                    const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(L10nUtils.translateError(state.message, l10n), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<MerchantCubit>().load(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

        final profile = state.profile;

        return Scaffold(
          backgroundColor: accentBeige,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, profile, l10n),
                _buildStats(state, l10n),
                _buildMenu(context, state, l10n),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, dynamic profile, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, Color(0xFF0D2119)],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(48), bottomRight: Radius.circular(48)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), shape: BoxShape.circle),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 60),
              child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.profile.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  IconButton(
                    icon: const Icon(Icons.settings_suggest_rounded, color: Colors.white),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MerchantSettingsScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: profile.avatarUrl.isNotEmpty
                          ? CachedNetworkImage(imageUrl: profile.avatarUrl, fit: BoxFit.cover)
                          : Center(child: Text(profile.initials, style: const TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w900))),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded, color: primaryGreen, size: 14),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                profile.businessName,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
                child: Text(
                  profile.businessType.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildStats(MerchantLoaded state, AppLocalizations l10n) {
    final stats = state.profile.allTimeStats;
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ImpactCard(
                  icon: Icons.auto_awesome_rounded,
                  color: const Color(0xFFF59E0B),
                  value: '${(stats.foodSavedKg / 0.4).round()}',
                  label: l10n.meals_saved_label,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ImpactCard(
                  icon: Icons.eco_rounded,
                  color: const Color(0xFF2D8659),
                  value: '${stats.foodSavedKg.toInt()}kg',
                  label: l10n.co2_avoided,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ImpactCard(
                  icon: Icons.workspace_premium_rounded,
                  color: const Color(0xFF3B82F6),
                  value: l10n.eco_rank_value("5"),
                  label: l10n.eco_rank,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context, MerchantLoaded state, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(l10n.management_section),
          const SizedBox(height: 16),
          _MenuTile(
            icon: Icons.monetization_on_rounded,
            title: l10n.earnings_revenue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: context.read<MerchantCubit>(), child: MerchantEarningsScreen(profile: state.profile)))),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.analytics_rounded,
            title: l10n.performance_analytics_title,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: context.read<MerchantCubit>(), child: const MerchantPerformanceAnalyticsScreen()))),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.business_center_rounded,
            title: l10n.business_details,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: context.read<MerchantCubit>(), child: const MerchantBusinessProfileScreen()))),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.receipt_long_rounded,
            title: 'Billing & Subscription',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => BillingCubit(),
                  child: const SubscriptionScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.account_balance_wallet_rounded,
            title: 'My Commissions',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => BillingCubit()..load(),
                  child: const CommissionSummaryScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.star_rounded,
            title: 'Sponsored Listings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => BillingCubit()..load(),
                  child: const SponsoredListingsScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _SectionLabel(l10n.support_legal_section),
          const SizedBox(height: 16),
          _MenuTile(
            icon: Icons.help_outline_rounded,
            title: l10n.help_center,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.logout_rounded,
            title: l10n.logout,
            isDestructive: true,
            onTap: () => _confirmLogout(context, l10n),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text("${l10n.logout}?", style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(l10n.logout_confirm_message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w900))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
              AppRouter.exitToLogin(context);
            },
            child: Text(l10n.logout.toUpperCase(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5));
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuTile({required this.icon, required this.title, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : const Color(0xFF2D8659);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isDestructive ? Colors.red : const Color(0xFF111827)))),
            if (!isDestructive) const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _ImpactCard({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.grey.shade400), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}



