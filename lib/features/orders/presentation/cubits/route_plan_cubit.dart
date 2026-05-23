import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/core/services/location_service.dart';
import 'package:anti_food_waste_app/features/orders/data/route_planning_service.dart';
import 'package:anti_food_waste_app/features/orders/domain/models/route_plan.dart';

// ─── States ────────────────────────────────────────────────────────────────

abstract class RoutePlanState extends Equatable {
  const RoutePlanState();

  @override
  List<Object?> get props => [];
}

class RoutePlanInitial extends RoutePlanState {
  const RoutePlanInitial();
}

class RoutePlanLoading extends RoutePlanState {
  const RoutePlanLoading();
}

class RoutePlanLoaded extends RoutePlanState {
  final RoutePlan plan;
  final double userLat;
  final double userLng;

  const RoutePlanLoaded({
    required this.plan,
    required this.userLat,
    required this.userLng,
  });

  @override
  List<Object?> get props => [plan.totalStops, userLat, userLng];
}

class RoutePlanError extends RoutePlanState {
  final String message;

  const RoutePlanError(this.message);

  @override
  List<Object?> get props => [message];
}

class RoutePlanLocationError extends RoutePlanState {
  const RoutePlanLocationError();
}

// ─── Cubit ─────────────────────────────────────────────────────────────────

/// Manages the route planning workflow:
///   1. Get user location
///   2. Call backend API
///   3. Emit result or error
class RoutePlanCubit extends Cubit<RoutePlanState> {
  final RoutePlanningService _service;

  RoutePlanCubit({RoutePlanningService? service})
      : _service = service ?? RoutePlanningService(),
        super(const RoutePlanInitial());

  /// Compute an optimized route for the given order IDs.
  Future<void> computeRoute(List<String> orderIds, {String prefix = 'orders'}) async {
    emit(const RoutePlanLoading());

    // Step 1: Get user location
    final position = await LocationService.getCurrentPosition();
    if (position == null) {
      emit(const RoutePlanLocationError());
      return;
    }

    // Step 2: Call the backend
    try {
      final plan = await _service.planRoute(
        userLat: position.lat,
        userLng: position.lng,
        orderIds: orderIds,
        prefix: prefix,
      );
      emit(RoutePlanLoaded(
        plan: plan,
        userLat: position.lat,
        userLng: position.lng,
      ));
    } catch (e) {
      var message = 'Failed to compute route. Please try again.';
      // Try to extract a more specific error message
      if (e.toString().contains('no_active_orders')) {
        message = 'No active orders found to plan a route.';
      }
      emit(RoutePlanError(message));
    }
  }
}
