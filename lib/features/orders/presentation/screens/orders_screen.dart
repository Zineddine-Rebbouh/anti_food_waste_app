import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import 'package:anti_food_waste_app/features/orders/presentation/cubits/orders_cubit.dart';

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
    _tabController = TabController(length: 2, vsync: this);
    _ordersCubit = OrdersCubit();
    _ordersCubit.loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ordersCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _ordersCubit,
      child: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          final List<Order> currentOrders;
          final List<Order> pastOrders;
          final bool isLoading;

          if (state is OrdersLoaded) {
            currentOrders = state.activeOrders;
            pastOrders = state.pastOrders;
            isLoading = false;
          } else {
            currentOrders = [];
            pastOrders = [];
            isLoading = state is OrdersLoading || state is OrdersInitial;
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            appBar: AppBar(
              title: Text(l10n.my_orders,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              bottom: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                indicatorWeight: 3,
                tabs: [
                  Tab(text: l10n.current),
                  Tab(text: l10n.past),
                ],
              ),
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _ordersCubit.loadOrders(),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOrderList(l10n, currentOrders),
                        _buildOrderList(l10n, pastOrders),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(l10n.no_orders_yet,
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return FadeInUp(
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: _buildOrderCard(l10n, orders[index]),
        );
      },
    );
  }

  Widget _buildOrderCard(AppLocalizations l10n, Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      surfaceTintColor:
          Colors.transparent, // Ensures pure white without M3 tinting
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to Order Details natively
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: order.merchantImage.isNotEmpty
                        ? Image.network(
                            order.merchantImage,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 64,
                                  height: 64,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                          )
                        : Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.items,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF111827))),
                        const SizedBox(height: 4),
                        Text(order.merchantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(l10n, order.status),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              '${order.pickupDate} • ${order.pickupTime}',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(order.orderNumber,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[500])),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Total',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500])),
                        const SizedBox(height: 4),
                        Text('${order.price.round()} DZD',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary)),
                      ],
                    ),
                  ],
                ),
              ),
              if (order.status == OrderStatus.reserved) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showQrBottomSheet(context, order),
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: const Text('Show QR Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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

  Future<void> _showQrBottomSheet(
      BuildContext context, Order order) async {
    // Fetch QR data from backend
    Map<String, dynamic>? qrData;
    try {
      qrData =
          await context.read<OrdersCubit>().fetchOrderQr(order.id);
    } catch (_) {}

    if (!context.mounted) return;

    final String qrContent = qrData != null
        ? jsonEncode({
            'order_id': qrData['order_id'] ?? order.id,
            'qr_hash': qrData['qr_hash'] ?? '',
            'pickup_code': qrData['pickup_code'] ?? '',
          })
        : jsonEncode({'order_id': order.id});

    final pickupCode =
        qrData?['pickup_code'] as String? ?? '------';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Show this QR at pickup',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              order.merchantName,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: qrContent,
              size: 220,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('Pickup Code',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    pickupCode,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              order.orderNumber,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppLocalizations l10n, OrderStatus status) {
    Color color;
    String label;

    switch (status) {
      case OrderStatus.reserved:
        color = Colors.orange;
        label = l10n.status_reserved;
      case OrderStatus.paid:
        color = Colors.green;
        label = l10n.status_paid;
      case OrderStatus.collected:
        color = Colors.grey;
        label = l10n.status_collected;
      case OrderStatus.canceled:
        color = Colors.red;
        label = l10n.status_canceled;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
