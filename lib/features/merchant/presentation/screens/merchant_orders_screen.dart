import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_order.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_order_detail_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_qr_scanner_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/widgets/merchant_order_card.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/widgets/merchant_status_badge.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MerchantOrdersScreen extends StatefulWidget {
  const MerchantOrdersScreen({super.key});

  @override
  State<MerchantOrdersScreen> createState() => _MerchantOrdersScreenState();
}

class _MerchantOrdersScreenState extends State<MerchantOrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MerchantCubit, MerchantState>(
      builder: (context, state) {
        if (state is MerchantLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              AppLocalizations.of(context)!.orders_label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code_scanner,
                    color: Color(0xFF2D8659), size: 26),
                onPressed: () => _openScanner(context),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF2D8659),
              indicatorWeight: 3,
              labelColor: const Color(0xFF2D8659),
              unselectedLabelColor: const Color(0xFF6B7280),
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14),
              tabs: [
                Tab(
                  text: state.pendingOrders.isNotEmpty
                      ? '${AppLocalizations.of(context)!.pending_orders} (${state.pendingOrders.length})'
                      : AppLocalizations.of(context)!.pending_orders,
                ),
                Tab(text: AppLocalizations.of(context)!.completed_orders),
                Tab(text: AppLocalizations.of(context)!.history_orders),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _PendingOrdersTab(
                orders: state.pendingOrders,
                onScanTap: (order) => _openScanner(context, order: order),
                onCallTap: _callCustomer,
                onOrderTap: (order) => _openDetail(context, order),
              ),
              _CompletedOrdersTab(
                orders: state.completedOrders,
                onOrderTap: (order) => _openDetail(context, order),
              ),
              _HistoryTab(
                pendingOrders: state.pendingOrders,
                completedOrders: state.completedOrders,
                onOrderTap: (order) => _openDetail(context, order),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openScanner(BuildContext context, {MerchantOrder? order}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BlocProvider.value(
          value: context.read<MerchantCubit>(),
          child: MerchantQrScannerScreen(preloadedOrder: order),
        ),
      ),
    );
  }

  void _callCustomer(MerchantOrder order) async {
    final uri = Uri(scheme: 'tel', path: order.customerPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openDetail(BuildContext context, MerchantOrder order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MerchantCubit>(),
          child: MerchantOrderDetailScreen(order: order),
        ),
      ),
    );
  }
}

// ── Pending Tab ───────────────────────────────────────────────────────────────

enum _PendingFilter { all, urgent, donation, cash }

class _PendingOrdersTab extends StatefulWidget {
  final List<MerchantOrder> orders;
  final Function(MerchantOrder) onScanTap;
  final Function(MerchantOrder) onCallTap;
  final Function(MerchantOrder) onOrderTap;

  const _PendingOrdersTab({
    required this.orders,
    required this.onScanTap,
    required this.onCallTap,
    required this.onOrderTap,
  });

  @override
  State<_PendingOrdersTab> createState() => _PendingOrdersTabState();
}

class _PendingOrdersTabState extends State<_PendingOrdersTab> {
  _PendingFilter _activeFilter = _PendingFilter.all;

  List<MerchantOrder> get _filtered {
    List<MerchantOrder> list;
    switch (_activeFilter) {
      case _PendingFilter.urgent:
        list = widget.orders.where((o) => o.isUrgent || o.isCritical).toList();
        break;
      case _PendingFilter.donation:
        list = widget.orders.where((o) => o.isDonation).toList();
        break;
      case _PendingFilter.cash:
        list = widget.orders
            .where((o) => o.paymentMethod == PaymentMethod.cashOnPickup)
            .toList();
        break;
      case _PendingFilter.all:
      default:
        list = List.from(widget.orders);
    }
    // Sort by urgency: critical first, then urgent, then normal
    list.sort((a, b) {
      int score(MerchantOrder o) {
        if (o.isCritical) return 0;
        if (o.isUrgent) return 1;
        return 2;
      }
      return score(a).compareTo(score(b));
    });
    return list;
  }

  double get _pendingRevenue => widget.orders
      .where((o) => !o.isDonation)
      .fold(0.0, (sum, o) => sum + o.netEarnings);

  int get _urgentCount =>
      widget.orders.where((o) => o.isUrgent || o.isCritical).length;

  @override
  Widget build(BuildContext context) {
    if (widget.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 72, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.no_pending_orders,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151)),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.orders_appear_here,
              style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      );
    }

    final filtered = _filtered;

    return Column(
      children: [
        // ── Summary header ─────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              _SummaryChip(
                icon: Icons.receipt_long,
                label: '${widget.orders.length} ${AppLocalizations.of(context)!.orders_label}',
                color: const Color(0xFF2D8659),
              ),
              const SizedBox(width: 10),
              _SummaryChip(
                icon: Icons.attach_money,
                label: '${_pendingRevenue.toStringAsFixed(0)} ${AppLocalizations.of(context)!.dzd}',
                color: const Color(0xFF10B981),
              ),
              if (_urgentCount > 0) ...[
                const SizedBox(width: 10),
                _SummaryChip(
                  icon: Icons.warning_amber_rounded,
                  label: '$_urgentCount urgent',
                  color: const Color(0xFFEF4444),
                ),
              ],
            ],
          ),
        ),

        // ── Filter chips ───────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: AppLocalizations.of(context)!.clear_all,
                  isActive: _activeFilter == _PendingFilter.all,
                  onTap: () =>
                      setState(() => _activeFilter = _PendingFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: AppLocalizations.of(context)!.urgent_filter,
                  isActive: _activeFilter == _PendingFilter.urgent,
                  onTap: () =>
                      setState(() => _activeFilter = _PendingFilter.urgent),
                  dotColor: const Color(0xFFEF4444),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: AppLocalizations.of(context)!.charity,
                  isActive: _activeFilter == _PendingFilter.donation,
                  onTap: () =>
                      setState(() => _activeFilter = _PendingFilter.donation),
                  dotColor: const Color(0xFF10B981),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Cash',
                  isActive: _activeFilter == _PendingFilter.cash,
                  onTap: () =>
                      setState(() => _activeFilter = _PendingFilter.cash),
                  dotColor: const Color(0xFFF97316),
                ),
              ],
            ),
          ),
        ),

        // ── Divider ────────────────────────────────────────────
        const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

        // ── List ───────────────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_list_off,
                          size: 56, color: const Color(0xFFD1D5DB)),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.no_results_filters,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final order = filtered[i];
                    return MerchantOrderCard(
                      order: order,
                      onTap: () => widget.onOrderTap(order),
                      onScanTap: () => widget.onScanTap(order),
                      onCallTap: () => widget.onCallTap(order),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? dotColor;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2D8659) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFF2D8659)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null && !isActive) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Completed Tab ─────────────────────────────────────────────────────────────

class _CompletedOrdersTab extends StatelessWidget {
  final List<MerchantOrder> orders;
  final Function(MerchantOrder) onOrderTap;

  const _CompletedOrdersTab(
      {required this.orders, required this.onOrderTap});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 72, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.no_completed_orders,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151)),
            ),
          ],
        ),
      );
    }

    // Summary header
    final totalEarned =
        orders.fold(0.0, (sum, o) => sum + o.netEarnings);

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _SummaryChip(
                icon: Icons.check_circle_outline,
                label: '${orders.length} completed',
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 10),
              _SummaryChip(
                icon: Icons.savings_outlined,
                label: '${totalEarned.toStringAsFixed(0)} DZD earned',
                color: const Color(0xFF2D8659),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final order = orders[i];
              return GestureDetector(
                onTap: () => onOrderTap(order),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.check_circle_outline,
                            color: Color(0xFF10B981), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    order.customerName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OrderStatusBadge(status: order.status),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${order.quantity}x ${order.listingTitle}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+${order.netEarnings.toStringAsFixed(0)} DZD',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          Text(
                            _timeAgo(order.orderedAt),
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

// ── History Tab ────────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  final List<MerchantOrder> pendingOrders;
  final List<MerchantOrder> completedOrders;
  final Function(MerchantOrder) onOrderTap;

  const _HistoryTab({
    required this.pendingOrders,
    required this.completedOrders,
    required this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    final all = [...completedOrders, ...pendingOrders]
      ..sort((a, b) => b.orderedAt.compareTo(a.orderedAt));

    if (all.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_outlined, size: 72, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.no_history_orders,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151))),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.orders_appear_here,
              style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
          ],
        ),
      );
    }

    final totalRevenue =
        completedOrders.fold(0.0, (sum, o) => sum + o.netEarnings);
    final donationCount = all.where((o) => o.isDonation).length;

    return Column(
      children: [
        // Stats bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: _HistoryStatCell(
                  label: 'Total',
                  value: '${all.length}',
                  color: const Color(0xFF2D8659),
                ),
              ),
              _VDiv(),
              Expanded(
                child: _HistoryStatCell(
                  label: 'Done',
                  value: '${completedOrders.length}',
                  color: const Color(0xFF10B981),
                ),
              ),
              _VDiv(),
              Expanded(
                child: _HistoryStatCell(
                  label: 'Earned',
                  value: '${totalRevenue.toStringAsFixed(0)} DZD',
                  color: const Color(0xFF6366F1),
                ),
              ),
              _VDiv(),
              Expanded(
                child: _HistoryStatCell(
                  label: 'Donated',
                  value: '$donationCount',
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: all.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final order = all[i];
              return GestureDetector(
                onTap: () => onOrderTap(order),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _statusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _statusIcon(order.status),
                          color: _statusColor(order.status),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    order.customerName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                OrderStatusBadge(status: order.status),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '#${order.orderNumber} · ${order.quantity}x ${order.listingTitle}',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF6B7280)),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatDate(order.orderedAt),
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            order.isDonation
                                ? 'Donation'
                                : '${order.netEarnings.toStringAsFixed(0)} DZD',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: order.isDonation
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF111827),
                            ),
                          ),
                          Text(
                            order.paymentMethod == PaymentMethod.cashOnPickup
                                ? 'Cash'
                                : 'Online',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.completed:
        return const Color(0xFF10B981);
      case OrderStatus.pending:
        return const Color(0xFFF59E0B);
      case OrderStatus.cancelled:
        return const Color(0xFFEF4444);
      case OrderStatus.noShow:
        return const Color(0xFF9CA3AF);
    }
  }

  IconData _statusIcon(OrderStatus s) {
    switch (s) {
      case OrderStatus.completed:
        return Icons.check_circle_outline;
      case OrderStatus.pending:
        return Icons.hourglass_empty_outlined;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      case OrderStatus.noShow:
        return Icons.person_off_outlined;
    }
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _HistoryStatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _HistoryStatCell(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
      ],
    );
  }
}

class _VDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: const Color(0xFFE5E7EB));
  }
}
