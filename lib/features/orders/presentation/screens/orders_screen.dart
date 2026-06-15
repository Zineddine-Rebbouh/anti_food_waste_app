import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import 'package:anti_food_waste_app/features/orders/presentation/cubits/orders_cubit.dart';
import 'package:anti_food_waste_app/features/orders/presentation/screens/route_plan_screen.dart';
import 'package:anti_food_waste_app/features/orders/presentation/screens/order_detail_screen.dart';

export 'package:anti_food_waste_app/features/orders/presentation/cubits/orders_cubit.dart'
    show Order, OrderStatus;

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final OrdersCubit _ordersCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _ordersCubit = context.read<OrdersCubit>();
    if (_ordersCubit.state is OrdersInitial) {
      _ordersCubit.loadOrders();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _ordersCubit,
      child: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          final List<Order> pendingOrders;
          final List<Order> activeOrders;
          final List<Order> historyOrders;
          final bool isLoading;

          if (state is OrdersLoaded) {
            pendingOrders = state.pendingOrders;
            activeOrders = state.activeOrders;
            historyOrders = state.historyOrders;
            isLoading = false;
          } else {
            pendingOrders = [];
            activeOrders = [];
            historyOrders = [];
            isLoading = state is OrdersLoading || state is OrdersInitial;
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(l10n.my_orders,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, color: Colors.black)),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              bottom: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primary,
                unselectedLabelColor: Colors.grey.shade400,
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.hourglass_empty_rounded, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          l10n.pending_orders,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            size: 16),
                        const SizedBox(width: 6),
                        Text(
                          l10n.active_orders,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history_rounded, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          l10n.history_orders,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                if (activeOrders.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        final orderIds = activeOrders.map((o) => o.id).toList();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RoutePlanScreen(orderIds: orderIds),
                          ),
                        );
                      },
                      icon: const Icon(Icons.route_rounded,
                          color: AppTheme.primary),
                      tooltip: l10n.plan_routes,
                    ),
                  ),
              ],
            ),
            body: isLoading
                ? _buildShimmer()
                : RefreshIndicator(
                    onRefresh: () => _ordersCubit.loadOrders(),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOrderList(l10n, pendingOrders),
                        _buildOrderList(l10n, activeOrders),
                        _buildOrderList(l10n, historyOrders),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildOrderList(AppLocalizations l10n, List<Order> orders) {
    if (orders.isEmpty) {
      return FadeIn(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.03), blurRadius: 20)
                    ]),
                child:
                    Icon(CupertinoIcons.bag, size: 64, color: Colors.grey[200]),
              ),
              const SizedBox(height: 24),
              Text(l10n.no_orders_yet,
                  style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return FadeInUp(
          duration: Duration(milliseconds: 400 + (index * 100)),
          child: _buildOrderCard(l10n, orders[index]),
        );
      },
    );
  }

  Widget _buildOrderCard(AppLocalizations l10n, Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: _ordersCubit,
                child: OrderDetailScreen(order: order),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Merchant & Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: order.merchantImage.isNotEmpty
                          ? Image.network(
                              order.merchantImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.storefront_rounded,
                                  color: Colors.grey),
                            )
                          : const Icon(Icons.storefront_rounded,
                              color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.merchantName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order.items,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(l10n, order.status),
                ],
              ),
              const SizedBox(height: 20),

              // Summary Info Row
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoItem(
                              CupertinoIcons.calendar, order.pickupDate),
                          const SizedBox(height: 8),
                          _buildInfoItem(CupertinoIcons.time, order.pickupTime),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${order.price.round()} DZD',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '#${order.orderNumber}',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              if (order.status == OrderStatus.accepted) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _showQrBottomSheet(context, order);
                    },
                    icon: const Icon(CupertinoIcons.qrcode, size: 20),
                    label: Text(
                      l10n.view_pickup_qr,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      foregroundColor: AppTheme.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(AppLocalizations l10n, OrderStatus status) {
    final (color, label, icon) = switch (status) {
      OrderStatus.pending => (
          const Color(0xFF3B82F6),
          l10n.status_pending,
          Icons.hourglass_empty
        ),
      OrderStatus.accepted => (
          const Color(0xFFF59E0B),
          l10n.status_accepted,
          Icons.thumb_up_alt_outlined
        ),
      OrderStatus.collected => (
          const Color(0xFF10B981),
          l10n.status_collected,
          Icons.check_circle
        ),
      OrderStatus.canceled => (
          const Color(0xFFEF4444),
          l10n.status_canceled,
          Icons.cancel_outlined
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(
            3,
            (index) => Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28)),
                )),
      ),
    );
  }

  Future<void> _showQrBottomSheet(BuildContext context, Order order) async {
    final l10n = AppLocalizations.of(context)!;
    Map<String, dynamic>? qrData;
    try {
      qrData = await _ordersCubit.fetchOrderQr(order.id);
    } catch (_) {}

    if (!context.mounted) return;

    final qrContent = qrData != null
        ? jsonEncode({
            'order_id': qrData['order_id'] ?? order.id,
            'qr_hash': qrData['qr_hash'] ?? '',
            'pickup_code': qrData['pickup_code'] ?? '',
          })
        : jsonEncode({'order_id': order.id});

    final pickupCode = qrData?['pickup_code'] as String? ?? '------';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 24),
            Text(
              l10n.show_qr_at_pickup,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            Text(order.merchantName,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 20)
                ],
              ),
              child: QrImageView(
                  data: qrContent,
                  size: 200,
                  errorCorrectionLevel: QrErrorCorrectLevel.H),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  color: const Color(0xFFF9FBFB),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Text(
                    l10n.pickup_code_label.toUpperCase(),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade400,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(pickupCode,
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 8,
                          color: AppTheme.primary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(order.orderNumber,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
