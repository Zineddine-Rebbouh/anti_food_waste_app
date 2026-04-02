import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/core/services/location_service.dart';
import 'package:anti_food_waste_app/core/utils/error_handler.dart';
import 'package:anti_food_waste_app/features/consumer/data/repositories/consumer_repository.dart';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';

/// Real Google Maps view used inside [SearchScreen].
///
/// Accepts optional [category] and [freshnessGrade] filters forwarded to the
/// `/listings/map/` backend endpoint.  When the user pans the map a
/// "Search this area" button appears; tapping it re-fetches listings for the
/// new viewport.
class MapView extends StatefulWidget {
  /// Called when the user taps "View Details" in the bottom-sheet preview.
  final void Function(FoodListing)? onListingTap;

  /// Optional backend category filter (e.g. "bakery", "restaurant").
  final String? category;

  /// Optional backend freshness filter ("A", "B", or "C").
  final String? freshnessGrade;

  const MapView({
    super.key,
    this.onListingTap,
    this.category,
    this.freshnessGrade,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  static const _defaultTarget = LatLng(36.7538, 3.0588); // Algiers centre

  GoogleMapController? _mapController;
  final _repository = ConsumerRepository();

  Set<Marker> _markers = {};

  bool _isSearching = false;
  bool _isLocating = false;
  bool _mapMoved = false;
  String? _resultLabel;

  LatLng _lastSearchCenter = _defaultTarget;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ── Filters changed externally ───────────────────────────────────────────

  @override
  void didUpdateWidget(MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category ||
        oldWidget.freshnessGrade != widget.freshnessGrade) {
      _searchCurrentArea();
    }
  }

  // ── Map callbacks ────────────────────────────────────────────────────────

  void _onMapCreated(GoogleMapController c) {
    _mapController = c;
    Future.delayed(const Duration(milliseconds: 600), _searchCurrentArea);
  }

  void _onCameraMove(CameraPosition pos) {
    if (!_mapMoved && _hasMoved(pos.target)) {
      setState(() => _mapMoved = true);
    }
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);

  double _distanceMeters(LatLng a, LatLng b) {
    const earthRadiusM = 6371000.0;
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLng = _degToRad(b.longitude - a.longitude);
    final lat1 = _degToRad(a.latitude);
    final lat2 = _degToRad(b.latitude);

    final sinDLat = math.sin(dLat / 2);
    final sinDLng = math.sin(dLng / 2);
    final h = sinDLat * sinDLat +
        math.cos(lat1) * math.cos(lat2) * sinDLng * sinDLng;
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return earthRadiusM * c;
  }

  bool _hasMoved(LatLng c) {
    const thresholdM = 500;
    return _distanceMeters(_lastSearchCenter, c) > thresholdM;
  }

  // ── GPS ──────────────────────────────────────────────────────────────────

  Future<void> _useMyLocation() async {
    setState(() => _isLocating = true);
    final pos = await LocationService.getCurrentPosition();
    if (pos != null && mounted) {
      final ll = LatLng(pos.lat, pos.lng);
      await _mapController?.animateCamera(CameraUpdate.newLatLngZoom(ll, 14));
      _lastSearchCenter = ll;
      await _searchCurrentArea();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not get location. Please enable GPS.'),
        behavior: SnackBarBehavior.floating,
      ));
    }
    if (mounted) setState(() => _isLocating = false);
  }

  // ── Search ───────────────────────────────────────────────────────────────

  Future<void> _searchCurrentArea() async {
    if (_isSearching) return;
    setState(() {
      _isSearching = true;
      _mapMoved = false;
      _resultLabel = null;
    });

    try {
      final bounds = await _mapController?.getVisibleRegion();
      if (bounds == null) return;

      // Guard: skip if the camera hasn't settled yet (zero-size region)
      if (bounds.northeast.latitude == bounds.southwest.latitude &&
          bounds.northeast.longitude == bounds.southwest.longitude) {
        setState(() => _isSearching = false);
        return;
      }

      final data = await _repository.fetchListingsMap(
        neLat: bounds.northeast.latitude,
        neLng: bounds.northeast.longitude,
        swLat: bounds.southwest.latitude,
        swLng: bounds.southwest.longitude,
        category: widget.category,
        freshnessGrade: widget.freshnessGrade,
      );

      final rawList = data['listings'] as List<dynamic>? ?? [];
      final listings = rawList
          .map((e) => FoodListing.fromJson(e as Map<String, dynamic>))
          .where((l) => l.lat != 0 || l.lng != 0)
          .toList();

      if (!mounted) return;

      // Update last search center
      final mid = LatLng(
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );
      _lastSearchCenter = mid;

      setState(() {
        _markers = listings.map(_buildMarker).toSet();
        _resultLabel =
            'Found ${listings.length} listing${listings.length == 1 ? '' : 's'}';
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _resultLabel = null);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppErrorHandler.getMessage(e)),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // ── Marker ───────────────────────────────────────────────────────────────

  Marker _buildMarker(FoodListing l) => Marker(
        markerId: MarkerId(l.id),
        position: LatLng(l.lat, l.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(_hue(l)),
        infoWindow: InfoWindow(
          title: l.title,
          snippet:
              '${l.discountedPrice.toStringAsFixed(0)} DA · ${l.merchantName}',
        ),
        onTap: () => _showPreview(l),
      );

  double _hue(FoodListing l) {
    if (l.discountPercent >= 50) return BitmapDescriptor.hueRed;
    if (l.freshness == FreshnessGrade.A) return BitmapDescriptor.hueGreen;
    if (l.freshness == FreshnessGrade.B) return BitmapDescriptor.hueOrange;
    return BitmapDescriptor.hueYellow;
  }

  // ── Bottom sheet preview ─────────────────────────────────────────────────

  void _showPreview(FoodListing listing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ListingPreviewSheet(
        listing: listing,
        onViewDetails: () {
          Navigator.of(context).pop();
          widget.onListingTap?.call(listing);
        },
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final showTopButton =
        _mapMoved || _isSearching || _resultLabel != null;

    return Stack(
      children: [
        // ── Real Google Map ───────────────────────────────────────────────
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: _defaultTarget,
            zoom: 13,
          ),
          onCameraMove: _onCameraMove,
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

        // ── "Search this area" / result button ────────────────────────────
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedSlide(
              offset: showTopButton ? Offset.zero : const Offset(0, -2),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: showTopButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _SearchAreaButton(
                  isSearching: _isSearching,
                  resultText: _resultLabel,
                  onTap: _searchCurrentArea,
                ),
              ),
            ),
          ),
        ),

        // ── GPS FAB ───────────────────────────────────────────────────────
        Positioned(
          bottom: 16,
          right: 16,
          child: _LocationFab(
            isLocating: _isLocating,
            onTap: _useMyLocation,
          ),
        ),

        // ── Legend ────────────────────────────────────────────────────────
        if (_markers.isNotEmpty)
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _LegendDot(color: Color(0xFF22C55E), label: 'A'),
                  SizedBox(width: 8),
                  _LegendDot(color: Color(0xFFF97316), label: 'B/C'),
                  SizedBox(width: 8),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primary, width: 1.5),
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
                    strokeWidth: 2, color: AppTheme.primary),
              )
            else
              Icon(
                resultText != null
                    ? Icons.check_circle_outline
                    : Icons.refresh,
                size: 16,
                color: AppTheme.primary,
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
        width: 48,
        height: 48,
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
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppTheme.primary),
              )
            : const Icon(Icons.my_location,
                color: AppTheme.primary, size: 22),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF374151))),
        ],
      );
}

// ── Listing Preview Bottom Sheet ──────────────────────────────────────────────

class _ListingPreviewSheet extends StatelessWidget {
  final FoodListing listing;
  final VoidCallback onViewDetails;

  const _ListingPreviewSheet({
    required this.listing,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final hasPic = listing.imageUrl.isNotEmpty;
    return GestureDetector(
      onTap: onViewDetails,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 20),
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
            // drag handle
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: hasPic
                        ? Image.network(listing.imageUrl,
                            width: 86,
                            height: 86,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _placeholder())
                        : _placeholder(),
                  ),
                  const SizedBox(width: 14),
                  // Meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(listing.merchantName,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280))),
                        const SizedBox(height: 2),
                        Text(listing.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827))),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '${listing.discountedPrice.toStringAsFixed(0)} DA',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary),
                            ),
                            const SizedBox(width: 6),
                            if (listing.discountPercent > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '-${listing.discountPercent}%',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF065F46)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 12, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                'Until ${listing.pickupEnd}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280)),
                                overflow: TextOverflow.ellipsis,
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                height: 44,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.fastfood_outlined,
            color: Color(0xFF9CA3AF), size: 30),
      );
}
