import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/orders/domain/models/route_plan.dart';
import 'package:anti_food_waste_app/features/orders/presentation/cubits/route_plan_cubit.dart';

class RoutePlanScreen extends StatefulWidget {
  final List<String> orderIds;
  final String prefix;

  const RoutePlanScreen({
    super.key,
    required this.orderIds,
    this.prefix = 'orders',
  });

  @override
  State<RoutePlanScreen> createState() => _RoutePlanScreenState();
}

class _RoutePlanScreenState extends State<RoutePlanScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  late final RoutePlanCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = RoutePlanCubit();
    _cubit.computeRoute(widget.orderIds, prefix: widget.prefix);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text(
            'Pickup Route',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            BlocBuilder<RoutePlanCubit, RoutePlanState>(
              builder: (context, state) {
                if (state is RoutePlanLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.open_in_new, size: 20),
                    tooltip: 'Open in Google Maps',
                    onPressed: () => _openInGoogleMaps(state),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<RoutePlanCubit, RoutePlanState>(
          builder: (context, state) {
            if (state is RoutePlanLoading) {
              return _buildLoading();
            }
            if (state is RoutePlanLocationError) {
              return _buildLocationError();
            }
            if (state is RoutePlanError) {
              return _buildError(state.message);
            }
            if (state is RoutePlanLoaded) {
              return _buildRouteView(state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ── Loading ─────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primary),
          const SizedBox(height: 24),
          FadeIn(
            child: Text(
              'Computing your optimal route...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeIn(
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Getting location & optimizing stops',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  // ── Location Error ──────────────────────────────────────────────────────

  Widget _buildLocationError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_off, size: 48, color: Colors.orange.shade700),
            ),
            const SizedBox(height: 24),
            const Text(
              'Location Required',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Please enable location services and grant permission to plan your pickup route.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _cubit.computeRoute(widget.orderIds),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error ───────────────────────────────────────────────────────────────

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            ),
            const SizedBox(height: 24),
            const Text(
              'Route Planning Failed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _cubit.computeRoute(widget.orderIds),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Route View (Map + List) ─────────────────────────────────────────────

  Widget _buildRouteView(RoutePlanLoaded state) {
    final plan = state.plan;

    if (plan.isEmpty) {
      return _buildError('No stops could be calculated. Some merchants may be missing location data.');
    }

    return Stack(
      children: [
        // Google Map — full screen behind everything
        _buildMap(state),

        // Draggable bottom sheet with stop list
        DraggableScrollableSheet(
          initialChildSize: 0.38,
          minChildSize: 0.15,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  // Pull indicator
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  // Summary card
                  _buildSummaryCard(plan),

                  // Warnings
                  if (plan.hasWarnings) _buildWarnings(plan.warnings),

                  // Stop list
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Text(
                      'Pickup Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  ...plan.stops.asMap().entries.map((entry) {
                    final idx = entry.key;
                    return FadeInUp(
                      duration: Duration(milliseconds: 300 + (idx * 80)),
                      child: _buildStopCard(entry.value, isLast: idx == plan.stops.length - 1),
                    );
                  }),

                  // Open in Google Maps button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: OutlinedButton.icon(
                      onPressed: () => _openInGoogleMaps(state),
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('Open in Google Maps'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Google Map ──────────────────────────────────────────────────────────

  Widget _buildMap(RoutePlanLoaded state) {
    final plan = state.plan;
    final userLatLng = LatLng(state.userLat, state.userLng);

    // Markers
    final markers = <Marker>{};

    // User marker
    markers.add(Marker(
      markerId: const MarkerId('user_location'),
      position: userLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'You are here'),
    ));

    // Stop markers with numbered labels
    for (final stop in plan.stops) {
      markers.add(Marker(
        markerId: MarkerId('stop_${stop.order}'),
        position: LatLng(stop.latitude, stop.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          stop.hasWarning ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueGreen,
        ),
        infoWindow: InfoWindow(
          title: '${stop.order}. ${stop.merchantName}',
          snippet: stop.listingTitle,
        ),
      ));
    }

    // Polyline connecting user → stop1 → stop2 → ... (following real roads if available)
    final polylinePoints = <LatLng>[];
    
    if (plan.path.isNotEmpty) {
      // Use real road geometry from backend
      for (final point in plan.path) {
        polylinePoints.add(LatLng(point[0], point[1]));
      }
    } else {
      // Fallback to straight lines
      polylinePoints.add(userLatLng);
      for (final stop in plan.stops) {
        polylinePoints.add(LatLng(stop.latitude, stop.longitude));
      }
    }

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('route'),
        points: polylinePoints,
        color: AppTheme.primary,
        width: 5,
        // Only use dashes for straight-line fallback
        patterns: plan.path.isEmpty 
          ? [PatternItem.dash(20), PatternItem.gap(10)]
          : [],
      ),
    };

    // Camera bounds to fit all points
    final allPoints = [userLatLng, ...plan.stops.map((s) => LatLng(s.latitude, s.longitude))];
    final bounds = _boundsFromPoints(allPoints);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: userLatLng,
        zoom: 13,
      ),
      markers: markers,
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (controller) {
        _mapController.complete(controller);
        // Animate camera to fit all markers
        Future.delayed(const Duration(milliseconds: 500), () {
          controller.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 80),
          );
        });
      },
    );
  }

  LatLngBounds _boundsFromPoints(List<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // ── Summary Card ────────────────────────────────────────────────────────

  Widget _buildSummaryCard(RoutePlan plan) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF3BA572)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _summaryItem(
            icon: Icons.place,
            value: '${plan.totalStops}',
            label: plan.totalStops == 1 ? 'Stop' : 'Stops',
          ),
          _summaryDivider(),
          _summaryItem(
            icon: Icons.straighten,
            value: plan.totalDistanceKm < 1
                ? '${(plan.totalDistanceKm * 1000).round()}m'
                : '${plan.totalDistanceKm.toStringAsFixed(1)}km',
            label: 'Distance',
          ),
          _summaryDivider(),
          _summaryItem(
            icon: Icons.access_time,
            value: plan.estimatedDurationMinutes < 60
                ? '${plan.estimatedDurationMinutes}m'
                : '${plan.estimatedDurationMinutes ~/ 60}h${plan.estimatedDurationMinutes % 60}m',
            label: 'Est. Time',
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.2),
    );
  }

  // ── Warnings ────────────────────────────────────────────────────────────

  Widget _buildWarnings(List<String> warnings) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'Route Warnings',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...warnings.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        w,
                        style: TextStyle(fontSize: 13, color: Colors.orange.shade900, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Stop Card ───────────────────────────────────────────────────────────

  Widget _buildStopCard(RouteStop stop, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: timeline indicator
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: stop.hasWarning
                          ? Colors.orange.shade100
                          : AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${stop.order}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: stop.hasWarning ? Colors.orange.shade700 : AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: Colors.grey.shade200,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right: stop details
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: stop.hasWarning ? Colors.orange.shade200 : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Merchant name
                    Text(
                      stop.merchantName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Listing title
                    Text(
                      stop.listingTitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 10),

                    // Address + distance
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            stop.merchantAddress.isNotEmpty
                                ? stop.merchantAddress
                                : 'Address not available',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stop.distanceFromPreviousKm < 1
                                ? '${(stop.distanceFromPreviousKm * 1000).round()}m'
                                : '${stop.distanceFromPreviousKm.toStringAsFixed(1)}km',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Pickup window
                    if (stop.pickupWindow.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            'Pickup: ${stop.pickupWindow}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],

                    // Warning
                    if (stop.hasWarning) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange.shade700),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                stop.warning!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── External Maps ──────────────────────────────────────────────────────

  Future<void> _openInGoogleMaps(RoutePlanLoaded state) async {
    final plan = state.plan;
    if (plan.stops.isEmpty) return;

    final origin = '${state.userLat},${state.userLng}';
    final lastStop = plan.stops.last;
    final destination = '${lastStop.latitude},${lastStop.longitude}';

    // Middle stops as waypoints
    var waypoints = '';
    if (plan.stops.length > 1) {
      final middleStops = plan.stops.sublist(0, plan.stops.length - 1);
      waypoints = middleStops
          .map((s) => '${s.latitude},${s.longitude}')
          .join('|');
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=$origin'
      '&destination=$destination'
      '${waypoints.isNotEmpty ? '&waypoints=$waypoints' : ''}'
      '&travelmode=driving',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
