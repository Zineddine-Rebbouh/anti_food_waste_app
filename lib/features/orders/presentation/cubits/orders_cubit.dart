import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/consumer/data/repositories/consumer_repository.dart';
import 'package:anti_food_waste_app/features/consumer/domain/models/consumer_order.dart';

// ─── UI model ──────────────────────────────────────────────────────────────
// These types were previously defined locally inside orders_screen.dart.
// They are now the canonical definitions; the screen imports them from here.

enum OrderStatus { pending, accepted, collected, canceled }

class Order {
  final String id;
  final String merchantName;
  final String merchantImage;
  final String items;
  final double price;
  final double unitPrice;
  final int quantity;
  final String currency;
  final String pickupTime;
  final String pickupDate;
  final OrderStatus status;
  final String orderNumber;
  final String address;
  final String merchantPhone;
  final double? merchantLatitude;
  final double? merchantLongitude;
  final String merchantLogoUrl;
  final String merchantCoverUrl;
  final String paymentMethod;
  final String paymentStatus;
  final String pickupCode;
  final String createdAt;
  final String pickupStartRaw;
  final String pickupEndRaw;
  final String orderStatusRaw;
  final String cancellationReason;
  final String notes;
  final String? collectedAt;

  Order({
    required this.id,
    required this.merchantName,
    required this.merchantImage,
    required this.items,
    required this.price,
    required this.unitPrice,
    required this.quantity,
    required this.currency,
    required this.pickupTime,
    required this.pickupDate,
    required this.status,
    required this.orderNumber,
    required this.address,
    required this.merchantPhone,
    this.merchantLatitude,
    this.merchantLongitude,
    required this.merchantLogoUrl,
    required this.merchantCoverUrl,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.pickupCode,
    required this.createdAt,
    required this.pickupStartRaw,
    required this.pickupEndRaw,
    required this.orderStatusRaw,
    required this.cancellationReason,
    required this.notes,
    this.collectedAt,
  });

  bool get hasLocation => merchantLatitude != null && merchantLongitude != null;

  /// Builds an [Order] UI model from a [ConsumerOrder] domain model.
  factory Order.fromConsumerOrder(ConsumerOrder co) {
    // Map backend order_status → UI OrderStatus
    final OrderStatus uiStatus;
    uiStatus = switch (co.orderStatus) {
      'pending' || 'reserved' => OrderStatus.pending,
      'accepted' => OrderStatus.accepted,
      'collected' => OrderStatus.collected,
      'cancelled' || 'no_show' => OrderStatus.canceled,
      _ => OrderStatus.accepted,
    };

    // Pickup time string
    final pickupTime = (co.pickupStart.isNotEmpty && co.pickupEnd.isNotEmpty)
        ? '${co.pickupStart} - ${co.pickupEnd}'
        : '';

    // Pickup date: active orders → "Today", past → formatted date
    var pickupDate = 'Today';
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
      unitPrice: co.unitPrice,
      quantity: co.quantity,
      currency: co.currency,
      pickupTime: pickupTime,
      pickupDate: pickupDate,
      status: uiStatus,
      orderNumber: co.orderNumber,
      address: co.merchantAddress,
      merchantPhone: co.merchantPhone,
      merchantLatitude: co.merchantLatitude,
      merchantLongitude: co.merchantLongitude,
      merchantLogoUrl: co.merchantLogoUrl,
      merchantCoverUrl: co.merchantCoverUrl,
      paymentMethod: co.paymentMethod,
      paymentStatus: co.paymentStatus,
      pickupCode: co.pickupCode,
      createdAt: co.createdAt,
      pickupStartRaw: co.pickupStartRaw,
      pickupEndRaw: co.pickupEndRaw,
      orderStatusRaw: co.orderStatus,
      cancellationReason: co.cancellationReason,
      notes: co.notes,
      collectedAt: co.collectedAt,
    );
  }
}

String _month(int m) {
  const names = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
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
  final List<Order> pendingOrders;
  final List<Order> activeOrders;
  final List<Order> historyOrders;

  const OrdersLoaded({
    required this.pendingOrders,
    required this.activeOrders,
    required this.historyOrders,
  });

  @override
  List<Object?> get props => [pendingOrders, activeOrders, historyOrders];
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

  void addOrUpdateOrder(ConsumerOrder consumerOrder) {
    final order = Order.fromConsumerOrder(consumerOrder);
    final current = state;

    final pendingOrders = current is OrdersLoaded
        ? List<Order>.of(current.pendingOrders)
        : <Order>[];
    final activeOrders = current is OrdersLoaded
        ? List<Order>.of(current.activeOrders)
        : <Order>[];
    final historyOrders = current is OrdersLoaded
        ? List<Order>.of(current.historyOrders)
        : <Order>[];

    for (final bucket in [pendingOrders, activeOrders, historyOrders]) {
      bucket.removeWhere((existing) => existing.id == order.id);
    }

    switch (order.status) {
      case OrderStatus.pending:
        pendingOrders.insert(0, order);
      case OrderStatus.accepted:
        activeOrders.insert(0, order);
      case OrderStatus.collected:
      case OrderStatus.canceled:
        historyOrders.insert(0, order);
    }

    emit(OrdersLoaded(
      pendingOrders: pendingOrders,
      activeOrders: activeOrders,
      historyOrders: historyOrders,
    ));
  }

  Future<void> loadOrders() async {
    emit(const OrdersLoading());
    try {
      final consumersOrders = await _repository.fetchOrders();
      final uiOrders = consumersOrders.map(Order.fromConsumerOrder).toList();

      final pending =
          uiOrders.where((o) => o.status == OrderStatus.pending).toList();
      final active =
          uiOrders.where((o) => o.status == OrderStatus.accepted).toList();
      final history = uiOrders
          .where((o) =>
              o.status == OrderStatus.collected ||
              o.status == OrderStatus.canceled)
          .toList();

      emit(OrdersLoaded(
        pendingOrders: pending,
        activeOrders: active,
        historyOrders: history,
      ));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _repository.cancelOrder(orderId);
      await loadOrders();
    } catch (e) {
      // Re-throw to allow UI to show an error message
      throw Exception('Failed to cancel reservation: $e');
    }
  }

  /// Fetches the QR code data (qr_hash + pickup_code) for an active order.
  /// Returns a map with keys: 'order_id', 'qr_hash', 'pickup_code'.
  Future<Map<String, dynamic>> fetchOrderQr(String orderId) async {
    return _repository.fetchOrderQr(orderId);
  }

  Future<void> submitReview(String orderId, int rating, String? comment) async {
    await _repository.submitReview(
      orderId: orderId,
      rating: rating,
      comment: comment,
    );
  }
}
