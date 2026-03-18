import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/consumer/data/repositories/consumer_repository.dart';
import 'package:anti_food_waste_app/features/consumer/domain/models/consumer_order.dart';

// ─── UI model ──────────────────────────────────────────────────────────────
// These types were previously defined locally inside orders_screen.dart.
// They are now the canonical definitions; the screen imports them from here.

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

  /// Builds an [Order] UI model from a [ConsumerOrder] domain model.
  factory Order.fromConsumerOrder(ConsumerOrder co) {
    // Map backend order_status → UI OrderStatus
    final OrderStatus uiStatus;
    switch (co.orderStatus) {
      case 'collected':
        uiStatus = OrderStatus.collected;
      case 'cancelled':
      case 'no_show':
        uiStatus = OrderStatus.canceled;
      default: // 'pending', 'reserved', and any unknown
        uiStatus = OrderStatus.reserved;
    }

    // Pickup time string
    final pickupTime = (co.pickupStart.isNotEmpty && co.pickupEnd.isNotEmpty)
        ? '${co.pickupStart} - ${co.pickupEnd}'
        : '';

    // Pickup date: active orders → "Today", past → formatted date
    String pickupDate = 'Today';
    if (!co.isActive && co.createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(co.createdAt).toLocal();
        pickupDate = '${dt.day.toString().padLeft(2, '0')} '
            '${_month(dt.month)} ${dt.year}';
      } catch (_) {}
    }

    return Order(
      id: co.id,
      merchantName: co.merchantName,
      merchantImage: co.merchantImage,
      items: co.listingTitle,
      price: co.totalPrice,
      pickupTime: pickupTime,
      pickupDate: pickupDate,
      status: uiStatus,
      orderNumber: co.orderNumber,
      address: co.merchantAddress,
    );
  }
}

String _month(int m) {
  const names = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return m >= 1 && m <= 12 ? names[m] : '';
}

// ─── States ────────────────────────────────────────────────────────────────

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  final List<Order> activeOrders;
  final List<Order> pastOrders;

  const OrdersLoaded({
    required this.activeOrders,
    required this.pastOrders,
  });

  @override
  List<Object?> get props => [activeOrders, pastOrders];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Cubit ─────────────────────────────────────────────────────────────────

/// Manages the consumer orders list.
class OrdersCubit extends Cubit<OrdersState> {
  final ConsumerRepository _repository;

  OrdersCubit({ConsumerRepository? repository})
      : _repository = repository ?? ConsumerRepository(),
        super(const OrdersInitial());

  Future<void> loadOrders() async {
    emit(const OrdersLoading());
    try {
      final consumersOrders = await _repository.fetchOrders();
      final uiOrders = consumersOrders.map(Order.fromConsumerOrder).toList();

      // Active: pending + reserved; Past: everything else
      final active = uiOrders
          .where((o) =>
              o.status == OrderStatus.reserved || o.status == OrderStatus.paid)
          .toList();
      final past = uiOrders
          .where((o) =>
              o.status == OrderStatus.collected ||
              o.status == OrderStatus.canceled)
          .toList();

      emit(OrdersLoaded(activeOrders: active, pastOrders: past));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _repository.cancelOrder(orderId);
      await loadOrders();
    } catch (_) {
      // Silently ignore cancel errors; UI stays in previous state.
    }
  }

  /// Fetches the QR code data (qr_hash + pickup_code) for an active order.
  /// Returns a map with keys: 'order_id', 'qr_hash', 'pickup_code'.
  Future<Map<String, dynamic>> fetchOrderQr(String orderId) async {
    return _repository.fetchOrderQr(orderId);
  }
}
