import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/core/navigation/app_router.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_business_profile_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_earnings_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_help_support_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_notification_settings_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_performance_analytics_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_settings_screen.dart';

class MerchantProfileScreen extends StatelessWidget {
  const MerchantProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MerchantCubit, MerchantState>(
      builder: (context, state) {
        if (state is MerchantLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (state is MerchantError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<MerchantCubit>().load(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state is! MerchantLoaded) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final profile = state.profile;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 190,
                pinned: true,
                backgroundColor: const Color(0xFF2D8659),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: Colors.white, size: 22),
                    onPressed: () => _openBusinessProfile(context),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2D8659), Color(0xFF1A5E3C)],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),
                          // Avatar
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 3),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              profile.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            profile.businessName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${profile.address}, ${profile.wilaya}',
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  profile.businessType,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_outlined,
                                        size: 12, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Trust: ${profile.trustScore.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // My Impact section (replaces Performance)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'My Impact',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ImpactCard(
                              icon: Icons.restaurant_outlined,
                              color: const Color(0xFF2D8659),
                              label: 'Meals Rescued',
                              value:
                                  '~${(profile.allTimeStats.foodSavedKg / 0.4).round()}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ImpactCard(
                              icon: Icons.cloud_outlined,
                              color: const Color(0xFF06B6D4),
                              label: 'CO² Avoided',
                              value:
                                  '${(profile.allTimeStats.foodSavedKg * 4).toStringAsFixed(0)} kg',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ImpactCard(
                              icon: Icons.volunteer_activism_outlined,
                              color: const Color(0xFF10B981),
                              label: 'Food Saved',
                              value:
                                  '${profile.allTimeStats.foodSavedKg.toStringAsFixed(0)} kg',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Menu items
                    const SizedBox(height: 20),
                    _buildMenuSection(context, state),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openBusinessProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MerchantCubit>(),
          child: const MerchantBusinessProfileScreen(),
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, MerchantLoaded state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.monetization_on_outlined,
            label: 'Earnings & Payouts',
            subtitle: 'View earnings history and payout schedule',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<MerchantCubit>(),
                  child: MerchantEarningsScreen(profile: state.profile),
                ),
              ),
            ),
          ),
          const _Divider(),
          _MenuItem(
            icon: Icons.bar_chart_outlined,
            label: 'Performance Analytics',
            subtitle: 'Detailed stats, charts and trends',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<MerchantCubit>(),
                  child: const MerchantPerformanceAnalyticsScreen(),
                ),
              ),
            ),
          ),
          const _Divider(),
          _MenuItem(
            icon: Icons.store_outlined,
            label: 'Business Profile',
            subtitle: 'Edit business info, documents, hours',
            onTap: () => _openBusinessProfile(context),
          ),
          const _Divider(),
          _MenuItem(
            icon: Icons.notifications_outlined,
            label: 'Notification Settings',
            subtitle: 'Manage alerts and preferences',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const MerchantNotificationSettingsScreen(),
              ),
            ),
          ),
          const _Divider(),
          _MenuItem(
            icon: Icons.help_outline,
            label: 'Help & Support',
            subtitle: 'FAQ, contact support, tutorials',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MerchantHelpSupportScreen(),
              ),
            ),
          ),
          const _Divider(),
          _MenuItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            subtitle: 'App preferences, language, account',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MerchantSettingsScreen(),
              ),
            ),
          ),
          const _Divider(),
          _MenuItem(
            icon: Icons.logout,
            label: 'Logout',
            subtitle: '',
            color: const Color(0xFFEF4444),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        title: const Text('Logout?',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text(
          "Are you sure? You'll need to login again.",
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppRouter.exitToRoleSelector(context);
            },
            child: const Text('Logout',
                style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Impact Card ────────────────────────────────────────────────────────────────

class _ImpactCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _ImpactCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Menu Item ─────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF374151);
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: c, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: c,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF9CA3AF)),
            )
          : null,
      trailing: Icon(Icons.chevron_right,
          color: const Color(0xFF9CA3AF), size: 20),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFF3F4F6),
        indent: 16);
  }
}
