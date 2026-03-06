import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:animate_do/animate_do.dart';

enum OrderStatus { reserved, paid, collected, canceled }

class Order {
  final String id;
  final String merchantName;
  final String merchantImage;
  final String items;
  final double price;
  final String pickupTime;
  final String pickupDate;
  final OrderStatus status;
  final String orderNumber;
  final String address;

  Order({
    required this.id,
    required this.merchantName,
    required this.merchantImage,
    required this.items,
    required this.price,
    required this.pickupTime,
    required this.pickupDate,
    required this.status,
    required this.orderNumber,
    required this.address,
  });
}

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Order> _currentOrders = [
    Order(
      id: '1',
      merchantName: 'Boulangerie El Khobz',
      merchantImage:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop',
      items: 'Fresh Baguettes & Pastries',
      price: 250,
      pickupTime: '18:00 - 20:00',
      pickupDate: 'Today',
      status: OrderStatus.reserved,
      orderNumber: '#SF-2026-123',
      address: 'Rue Didouche Mourad, Alger Centre',
    ),
    Order(
      id: '2',
      merchantName: 'Restaurant El Bahia',
      merchantImage:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=200&h=200&fit=crop',
      items: 'Mixed Grill Surprise Box',
      price: 500,
      pickupTime: '19:00 - 21:00',
      pickupDate: 'Today',
      status: OrderStatus.paid,
      orderNumber: '#SF-2026-124',
      address: 'Boulevard Mohamed V, Oran',
    ),
    Order(
      id: '3',
      merchantName: 'Pizzeria Napoli',
      merchantImage:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200&h=200&fit=crop',
      items: '2 Pizza Margherita (Surplus)',
      price: 400,
      pickupTime: '21:30 - 22:30',
      pickupDate: 'Today',
      status: OrderStatus.paid,
      orderNumber: '#SF-2026-125',
      address: 'Sidi Yahia, Hydra',
    ),
  ];

  final List<Order> _pastOrders = [
    Order(
      id: '4',
      merchantName: 'Café de la Poste',
      merchantImage:
          'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=200&h=200&fit=crop',
      items: 'Viennoiseries assorties',
      price: 150,
      pickupTime: '16:00 - 17:00',
      pickupDate: '24 Feb 2026',
      status: OrderStatus.collected,
      orderNumber: '#SF-2026-089',
      address: 'Place Audin, Alger',
    ),
    Order(
      id: '5',
      merchantName: 'Superéette Benali',
      merchantImage:
          'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=200&h=200&fit=crop',
      items: 'Mélange de fruits (près de la date limite)',
      price: 350,
      pickupTime: '20:00 - 21:00',
      pickupDate: '23 Feb 2026',
      status: OrderStatus.collected,
      orderNumber: '#SF-2026-072',
      address: 'Bir Mourad Raïs',
    ),
    Order(
      id: '6',
      merchantName: 'Fast Food Le Régal',
      merchantImage:
          'https://images.unsplash.com/photo-1550547660-d9450f859349?w=200&h=200&fit=crop',
      items: 'Burgers invendus',
      price: 450,
      pickupTime: '22:00 - 23:30',
      pickupDate: '20 Feb 2026',
      status: OrderStatus.canceled,
      orderNumber: '#SF-2026-054',
      address: 'Kouba',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(l10n, _currentOrders),
          _buildOrderList(l10n, _pastOrders),
        ],
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
                    child: Image.network(order.merchantImage,
                        width: 64, height: 64, fit: BoxFit.cover),
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
            ],
          ),
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
