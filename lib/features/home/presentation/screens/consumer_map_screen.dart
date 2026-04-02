import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/core/services/location_service.dart';
import 'package:anti_food_waste_app/core/utils/error_handler.dart';
import 'package:anti_food_waste_app/features/consumer/data/repositories/consumer_repository.dart';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';
import 'package:anti_food_waste_app/features/home/presentation/screens/listing_detail_screen.dart';

/// Full-screen interactive Google Map for consumers.
///
/// Shows listing pins fetched from GET /api/v1/listings/map/ for the visible
/// bounding box.  Tapping a pin opens a bottom-sheet preview and the user
/// can navigate to the full detail screen from there.
class ConsumerMapScreen extends StatefulWidget {
  const ConsumerMapScreen({super.key});

  @override
  State<ConsumerMapScreen> createState() => _ConsumerMapScreenState();
}

class _ConsumerMapScreenState extends State<ConsumerMapScreen> {
  static const _defaultTarget = LatLng(36.7538, 3.0588); // Algiers centre

  GoogleMapController? _mapController;
  final _repository = ConsumerRepository();

  Set<Marker> _markers = {};

  bool _isSearching = false;
  bool _isLocating = false;
  bool _mapMoved = false;
  String? _searchResult; // "Found 12 listings" message

  // Track the last camera idle position to know if map moved
  LatLng _lastSearchCenter = _defaultTarget;

  // Track user's actual GPS position for accurate distance calculation
  LatLng? _userPosition;

  @override
  void initState() {
    super.initState();
    // Fetch the user's GPS position early for distance calculations
    _fetchUserPosition();
  }

  Future<void> _fetchUserPosition() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null && mounted) {
      setState(() => _userPosition = LatLng(pos.lat, pos.lng));
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ── Map events ──────────────────────────────────────────────────────────

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Initial search once map is ready
    Future.delayed(const Duration(milliseconds: 600), _searchCurrentArea);
  }

  void _onCameraMove(CameraPosition position) {
    // Show "Search this area" if the map moved noticeably
    if (!_mapMoved) {
      final moved = _hasMoved(position.target);
      if (moved) setState(() => _mapMoved = true);
    }
  }

  void _onCameraIdle() {
    // Intentionally not auto-searching — user taps button manually
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);

  /// Haversine distance between two points in meters.
  double _distanceMeters(LatLng a, LatLng b) {
    const earthRadiusM = 6371000.0;
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLng = _degToRad(b.longitude - a.longitude);
    final lat1 = _degToRad(a.latitude);
    final lat2 = _degToRad(b.latitude);

    final sinDLat = math.sin(dLat / 2);
    final sinDLng = math.sin(dLng / 2);
    final h =
        sinDLat * sinDLat + math.cos(lat1) * math.cos(lat2) * sinDLng * sinDLng;
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return earthRadiusM * c;
  }

  bool _hasMoved(LatLng newCenter) {
    const thresholdM = 500; // show button after ~500m viewport move
    return _distanceMeters(_lastSearchCenter, newCenter) > thresholdM;
  }

  // ── GPS ─────────────────────────────────────────────────────────────────

  Future<void> _useMyLocation() async {
    setState(() => _isLocating = true);
    final pos = await LocationService.getCurrentPosition();
    if (pos != null && mounted) {
      final latlng = LatLng(pos.lat, pos.lng);
      _userPosition = latlng;
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latlng, 14),
      );
      _lastSearchCenter = latlng;
      await _searchCurrentArea();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not get location. Please enable GPS.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    if (mounted) setState(() => _isLocating = false);
  }

  // ── Search ───────────────────────────────────────────────────────────────

  Future<void> _searchCurrentArea() async {
    if (_isSearching) return;
    setState(() {
      _isSearching = true;
      _mapMoved = false;
      _searchResult = null;
    });

    try {
      final bounds = await _mapController?.getVisibleRegion();
      if (bounds == null) return;

      final data = await _repository.fetchListingsMap(
        neLat: bounds.northeast.latitude,
        neLng: bounds.northeast.longitude,
        swLat: bounds.southwest.latitude,
        swLng: bounds.southwest.longitude,
      );

      final rawList = data['listings'] as List<dynamic>? ?? [];
      final listings = rawList
          .map((e) => FoodListing.fromJson(e as Map<String, dynamic>))
          .where((l) => l.lat != 0 || l.lng != 0) // skip no-location
          .toList();

      if (!mounted) return;

      final markers = listings.map((l) => _buildMarker(l)).toSet();

      final center = await _mapController?.getVisibleRegion();
      if (center != null) {
        final midLat =
            (center.northeast.latitude + center.southwest.latitude) / 2;
        final midLng =
            (center.northeast.longitude + center.southwest.longitude) / 2;
        _lastSearchCenter = LatLng(midLat, midLng);
      }

      setState(() {
        _markers = markers;
        _searchResult =
            'Found ${listings.length} listing${listings.length == 1 ? '' : 's'}';
      });

      // Auto-clear the "Found X" message after 3s
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _searchResult = null);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppErrorHandler.getMessage(e)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // ── Marker helpers ───────────────────────────────────────────────────────

  Marker _buildMarker(FoodListing listing) {
    final hue = _markerHue(listing);
    return Marker(
      markerId: MarkerId(listing.id),
      position: LatLng(listing.lat, listing.lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      infoWindow: InfoWindow(
        title: listing.title,
        snippet:
            '${listing.discountedPrice.toStringAsFixed(0)} DA · ${listing.merchantName}',
      ),
      onTap: () => _showListingPreview(listing),
    );
  }

  double _markerHue(FoodListing listing) {
    if (listing.discountPercent >= 50) return BitmapDescriptor.hueRed;
    if (listing.freshness == FreshnessGrade.A) return BitmapDescriptor.hueGreen;
    if (listing.freshness == FreshnessGrade.B)
      return BitmapDescriptor.hueOrange;
    return BitmapDescriptor.hueYellow;
  }

  // ── Bottom sheet ─────────────────────────────────────────────────────────

  /// Compute the actual distance from user GPS to a listing (in km).
  double _realDistanceKm(FoodListing listing) {
    if (_userPosition == null) return listing.distance;
    return _distanceMeters(
          _userPosition!,
          LatLng(listing.lat, listing.lng),
        ) /
        1000.0;
  }

  void _showListingPreview(FoodListing listing) {
    // Use real user-to-listing distance instead of camera-center distance
    final realDist = _realDistanceKm(listing);
    final enrichedListing = FoodListing(
      id: listing.id,
      title: listing.title,
      merchantName: listing.merchantName,
      merchantId: listing.merchantId,
      originalPrice: listing.originalPrice,
      discountedPrice: listing.discountedPrice,
      discountPercent: listing.discountPercent,
      imageUrl: listing.imageUrl,
      rating: listing.rating,
      reviewCount: listing.reviewCount,
      distance: realDist,
      freshness: listing.freshness,
      category: listing.category,
      pickupStart: listing.pickupStart,
      pickupEnd: listing.pickupEnd,
      quantityLeft: listing.quantityLeft,
      dietary: listing.dietary,
      lat: listing.lat,
      lng: listing.lng,
      postedMinutesAgo: listing.postedMinutesAgo,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.35,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        builder: (_, scrollController) => _ListingPreviewSheet(
          listing: enrichedListing,
          scrollController: scrollController,
          onViewDetails: () {
            Navigator.of(context).pop(); // close sheet
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ListingDetailScreen(listing: listing),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Map ──────────────────────────────────────────────────────────
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: _defaultTarget,
            zoom: 13,
          ),
          onCameraMove: _onCameraMove,
          onCameraIdle: _onCameraIdle,
          markers: _markers,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          compassEnabled: true,
          mapToolbarEnabled: false,
        ),

        // ── "Search this area" button ────────────────────────────────────
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedSlide(
              offset: (_mapMoved || _isSearching || _searchResult != null)
                  ? Offset.zero
                  : const Offset(0, -2),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: (_mapMoved || _isSearching || _searchResult != null)
                    ? 1.0
                    : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _SearchAreaButton(
                  isSearching: _isSearching,
                  resultText: _searchResult,
                  onTap: _searchCurrentArea,
                ),
              ),
            ),
          ),
        ),

        // ── GPS / My Location button ─────────────────────────────────────
        Positioned(
          bottom: 24,
          right: 16,
          child: _LocationFab(
            isLocating: _isLocating,
            onTap: _useMyLocation,
          ),
        ),

        // ── Legend ───────────────────────────────────────────────────────
        if (_markers.isNotEmpty)
          Positioned(
            bottom: 24,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _LegendDot(color: Color(0xFF22C55E), label: 'Grade A'),
                  SizedBox(width: 10),
                  _LegendDot(color: Color(0xFFF97316), label: 'Grade B/C'),
                  SizedBox(width: 10),
                  _LegendDot(color: Color(0xFFEF4444), label: '≥50% off'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SearchAreaButton extends StatelessWidget {
  final bool isSearching;
  final String? resultText;
  final VoidCallback onTap;

  const _SearchAreaButton({
    required this.isSearching,
    required this.resultText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label =
        isSearching ? 'Searching...' : (resultText ?? 'Search this area');

    return GestureDetector(
      onTap: isSearching ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF10B981), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSearching)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF10B981),
                ),
              )
            else
              Icon(
                resultText != null ? Icons.check_circle_outline : Icons.refresh,
                size: 16,
                color: const Color(0xFF10B981),
              ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF065F46),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationFab extends StatelessWidget {
  final bool isLocating;
  final VoidCallback onTap;

  const _LocationFab({required this.isLocating, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocating ? null : onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: isLocating
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF10B981),
                ),
              )
            : const Icon(Icons.my_location, color: Color(0xFF10B981), size: 24),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF374151))),
      ],
    );
  }
}

// ── Listing Preview Bottom Sheet ──────────────────────────────────────────────

class _ListingPreviewSheet extends StatelessWidget {
  final FoodListing listing;
  final VoidCallback onViewDetails;
  final ScrollController? scrollController;

  const _ListingPreviewSheet({
    required this.listing,
    required this.onViewDetails,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final discountPct = listing.discountPercent;
    final hasFreshPhoto = listing.imageUrl.isNotEmpty;

    return SingleChildScrollView(
      controller: scrollController,
      child: GestureDetector(
        onTap: onViewDetails,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: hasFreshPhoto
                          ? Image.network(
                              listing.imageUrl,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imagePlaceholder(),
                            )
                          : _imagePlaceholder(),
                    ),

                    const SizedBox(width: 14),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.merchantName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            listing.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '${listing.discountedPrice.toStringAsFixed(0)} DA',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (discountPct > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '-$discountPct%',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF065F46),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (listing.distance > 0) ...[
                                const Icon(Icons.place_outlined,
                                    size: 13, color: Color(0xFF9CA3AF)),
                                const SizedBox(width: 2),
                                Text(
                                  '${listing.distance.toStringAsFixed(1)} km',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                              const Icon(Icons.access_time,
                                  size: 13, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 2),
                              Text(
                                'Pickup until ${listing.pickupEnd}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // View Details button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.fastfood_outlined,
          color: Color(0xFF9CA3AF), size: 32),
    );
  }
}
