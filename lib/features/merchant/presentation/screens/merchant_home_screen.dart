import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_stats.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/create_listing/merchant_create_listing_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_qr_scanner_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_order_detail_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/widgets/merchant_metric_card.dart';

class MerchantHomeScreen extends StatelessWidget {
  const MerchantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MerchantCubit, MerchantState>(
      builder: (context, state) {
        if (state is MerchantLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is! MerchantLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildHeader(context, state),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildMetricCards(context, state),
                    _buildQuickActions(context),
                    _buildActivityFeed(context, state),
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

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, MerchantLoaded state) {
    final now = DateTime.now();
    final dateStr = _formatDate(now);

    return SliverAppBar(
      expandedHeight: 90,
      pinned: true,
      backgroundColor: const Color(0xFF2D8659),
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
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      state.profile.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.profile.businessName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification Bell
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined,
                            color: Colors.white, size: 26),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
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
    );
  }

  // ── Metric Cards ─────────────────────────────────────────────────────────────

  Widget _buildMetricCards(BuildContext context, MerchantLoaded state) {
    final stats = state.profile.dailyStats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            "Today's Overview",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              MerchantMetricCard(
                icon: Icons.inventory_2_outlined,
                number: '${stats.ordersToday}',
                label: 'Orders',
                sublabel:
                    '${stats.ordersDelta >= 0 ? '+' : ''}${stats.ordersDelta} vs yesterday',
                gradientColors: const [Color(0xFF2D8659), Color(0xFF1A5E3C)],
                onTap: () {},
              ),
              const SizedBox(width: 12),
              MerchantMetricCard(
                icon: Icons.monetization_on_outlined,
                number: '${stats.revenueToday.toStringAsFixed(0)} DZD',
                label: 'Revenue',
                sublabel:
                    '${stats.netRevenueToday.toStringAsFixed(0)} DZD net',
                gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                onTap: () {},
              ),
              const SizedBox(width: 12),
              MerchantMetricCard(
                icon: Icons.eco_outlined,
                number: '${stats.foodSavedKgToday.toStringAsFixed(0)} kg',
                label: 'Food Saved',
                sublabel:
                    '${stats.co2AvoidedKgToday.toStringAsFixed(0)} kg CO₂ avoided',
                gradientColors: const [Color(0xFF059669), Color(0xFF047857)],
                onTap: () {},
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Add New Listing — primary CTA
          _PrimaryActionButton(
            icon: Icons.add_circle_outline,
            title: 'Add New Listing',
            subtitle: 'List surplus food in under 2 minutes',
            backgroundColor: const Color(0xFF2D8659),
            textColor: Colors.white,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => BlocProvider.value(
                    value: context.read<MerchantCubit>(),
                    child: const MerchantCreateListingScreen(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          // Scan QR Code — secondary CTA
          _PrimaryActionButton(
            icon: Icons.qr_code_scanner,
            title: 'Scan QR Code',
            subtitle: 'Fulfill customer pickup',
            backgroundColor: Colors.white,
            textColor: const Color(0xFF374151),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => BlocProvider.value(
                    value: context.read<MerchantCubit>(),
                    child: const MerchantQrScannerScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Activity Feed ─────────────────────────────────────────────────────────────

  Widget _buildActivityFeed(BuildContext context, MerchantLoaded state) {
    final feed = state.activityFeed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ),
        if (feed.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 56, color: Color(0xFFD1D5DB)),
                  SizedBox(height: 12),
                  Text(
                    'No activity yet today',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your orders will appear here',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: feed.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final item = feed[i];
              return _ActivityCard(
                item: item,
                onTap: item.orderId != null
                    ? () {
                        // Find order by id from pending or completed
                        final s = context.read<MerchantCubit>().state;
                        if (s is MerchantLoaded) {
                          final allOrders = [
                            ...s.pendingOrders,
                            ...s.completedOrders
                          ];
                          final order = allOrders.where(
                              (o) => o.id == item.orderId).toList();
                          if (order.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<MerchantCubit>(),
                                  child: MerchantOrderDetailScreen(
                                      order: order.first),
                                ),
                              ),
                            );
                          }
                        }
                      }
                    : null,
              );
            },
          ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
      'Sunday'
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct',
      'Nov', 'Dec'
    ];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }
}

// ── Supporting Widgets ────────────────────────────────────────────────────────

class _PrimaryActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color textColor;
  final BoxBorder? border;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: border,
          boxShadow: backgroundColor == Colors.white
              ? null
              : [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: textColor.withOpacity(0.6), size: 22),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityItem item;
  final VoidCallback? onTap;

  const _ActivityCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (item.type) {
      case 'new_order':
        icon = Icons.shopping_cart_outlined;
        iconColor = const Color(0xFF3B82F6);
        break;
      case 'completed':
        icon = Icons.check_circle_outline;
        iconColor = const Color(0xFF10B981);
        break;
      case 'donation':
        icon = Icons.volunteer_activism_outlined;
        iconColor = const Color(0xFF2D8659);
        break;
      case 'cancelled':
        icon = Icons.cancel_outlined;
        iconColor = const Color(0xFFEF4444);
        break;
      default:
        icon = Icons.circle_outlined;
        iconColor = const Color(0xFF6B7280);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.primaryText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    item.secondaryText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _timeAgo(item.timestamp),
              style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
