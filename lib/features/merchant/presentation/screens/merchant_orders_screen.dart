import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:anti_food_waste_app/features/merchant/domain/models/merchant_order.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_order_detail_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_qr_scanner_screen.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/widgets/merchant_order_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/utils/l10n_utils.dart';

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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color accentBeige = Colors.white;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<MerchantCubit, MerchantState>(
      builder: (context, state) {
        if (state is MerchantLoading) {
          return const Scaffold(backgroundColor: accentBeige, body: Center(child: CircularProgressIndicator(color: primaryGreen)));
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
                    ElevatedButton(onPressed: () => context.read<MerchantCubit>().load(), child: Text(l10n.retry)),
                  ],
                ),
              ),
            ),
          );
        }
        if (state is! MerchantLoaded) {
          return const Scaffold(backgroundColor: accentBeige, body: Center(child: CircularProgressIndicator(color: primaryGreen)));
        }

        return Scaffold(
          backgroundColor: accentBeige,
          body: Column(
            children: [
              _buildEditorialHeader(context, state, l10n),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OrdersTab(
                      orders: state.pendingOrders,
                      emptyTitle: l10n.no_pending_orders,
                      emptySubtitle: l10n.no_pending_orders_desc,
                      onCall: _callCustomer,
                      onOrderTap: (order) => _openDetail(context, order),
                    ),
                    _OrdersTab(
                      orders: state.activeOrders,
                      emptyTitle: l10n.no_active_orders,
                      emptySubtitle: l10n.no_active_orders_desc,
                      onCall: _callCustomer,
                      onScan: (order) => _openScanner(context, order: order),
                      onOrderTap: (order) => _openDetail(context, order),
                    ),
                    _OrdersTab(
                      orders: state.completedOrders,
                      emptyTitle: l10n.no_completed_orders,
                      emptySubtitle: l10n.no_completed_orders_desc,
                      onOrderTap: (order) => _openDetail(context, order),
                    ),
                    _OrdersTab(
                      orders: [...state.pendingOrders, ...state.activeOrders, ...state.completedOrders]..sort((a, b) => b.orderedAt.compareTo(a.orderedAt)),
                      emptyTitle: l10n.no_history,
                      emptySubtitle: l10n.no_history_desc,
                      onOrderTap: (order) => _openDetail(context, order),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditorialHeader(BuildContext context, MerchantLoaded state, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.orders_label.toUpperCase(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
                    onPressed: () => _openScanner(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                l10n.orders_label,
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.only(left: 12, bottom: 12),
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Color(0xFFFFD54F), width: 4),
                insets: EdgeInsets.symmetric(horizontal: 16),
              ),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.4),
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
              tabs: [
                Tab(text: l10n.pending_with_count(state.pendingOrders.length).toUpperCase()),
                Tab(text: l10n.active_with_count(state.activeOrders.length).toUpperCase()),
                Tab(text: l10n.completed_label.toUpperCase()),
                Tab(text: l10n.history_label.toUpperCase()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openScanner(BuildContext context, {MerchantOrder? order}) {
    Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => BlocProvider.value(value: context.read<MerchantCubit>(), child: MerchantQrScannerScreen(preloadedOrder: order))));
  }

  void _callCustomer(MerchantOrder order) async {
    final uri = Uri(scheme: 'tel', path: order.customerPhone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _openDetail(BuildContext context, MerchantOrder order) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: context.read<MerchantCubit>(), child: MerchantOrderDetailScreen(order: order))));
  }
}

class _OrdersTab extends StatelessWidget {
  final List<MerchantOrder> orders;
  final String emptyTitle;
  final String emptySubtitle;
  final Function(MerchantOrder)? onCall;
  final Function(MerchantOrder)? onScan;
  final Function(MerchantOrder) onOrderTap;

  const _OrdersTab({required this.orders, required this.emptyTitle, required this.emptySubtitle, this.onCall, this.onScan, required this.onOrderTap});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey.shade100),
              const SizedBox(height: 24),
              Text(emptyTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              const SizedBox(height: 8),
              Text(emptySubtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (ctx, i) {
        final order = orders[i];
        return MerchantOrderCard(
          order: order,
          onTap: () => onOrderTap(order),
          onCallTap: onCall != null ? () => onCall!(order) : null,
          onScanTap: onScan != null ? () => onScan!(order) : null,
        );
      },
    );
  }
}



