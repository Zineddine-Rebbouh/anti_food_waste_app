import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:anti_food_waste_app/core/services/location_service.dart';
import 'package:anti_food_waste_app/features/merchant/data/sources/merchant_remote_source.dart';

/// Result returned when the merchant confirms a location on the map.
class MapLocationResult {
  final double latitude;
  final double longitude;

  const MapLocationResult({required this.latitude, required this.longitude});
}

/// Full-screen Google Map that lets the merchant drag a pin to set their
/// business location.
///
/// Returns a [MapLocationResult] via [Navigator.pop] when the merchant
/// confirms.  Returns `null` if they dismiss without saving.
///
/// Usage:
/// ```dart
/// final result = await Navigator.push<MapLocationResult>(context,
///   MaterialPageRoute(builder: (_) => MerchantMapLocationScreen(
///     initialLat: profile.latitude,
///     initialLng: profile.longitude,
///   )),
/// );
/// ```
class MerchantMapLocationScreen extends StatefulWidget {
  /// Pre-selected latitude (from saved profile).  Falls back to Algiers centre.
  final double? initialLat;

  /// Pre-selected longitude (from saved profile).  Falls back to Algiers centre.
  final double? initialLng;

  const MerchantMapLocationScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<MerchantMapLocationScreen> createState() =>
      _MerchantMapLocationScreenState();
}

class _MerchantMapLocationScreenState
    extends State<MerchantMapLocationScreen> {
  // Default: Algiers city centre
  static const _defaultLat = 36.7538;
  static const _defaultLng = 3.0588;

  late LatLng _selectedPosition;
  GoogleMapController? _mapController;
  bool _isSaving = false;
  String? _address;
  bool _loadingAddress = false;

  static const _green = Color(0xFF2D8659);

  @override
  void initState() {
    super.initState();
    _selectedPosition = LatLng(
      widget.initialLat ?? _defaultLat,
      widget.initialLng ?? _defaultLng,
    );
    // If no initial position, try GPS
    if (widget.initialLat == null) {
      _tryGps();
    } else {
      _reverseGeocode(_selectedPosition);
    }
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _loadingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final parts = [
          if (p.street?.isNotEmpty == true) p.street,
          if (p.subLocality?.isNotEmpty == true) p.subLocality,
          if (p.locality?.isNotEmpty == true) p.locality,
          if (p.administrativeArea?.isNotEmpty == true) p.administrativeArea,
        ];
        setState(() => _address = parts.join(', '));
      }
    } catch (_) {
      // Silently fail — coordinates are still shown as fallback
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  Future<void> _tryGps() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null && mounted) {
      final newPos = LatLng(pos.lat, pos.lng);
      setState(() => _selectedPosition = newPos);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newPos, 15),
      );
      _reverseGeocode(newPos);
    }
  }

  void _onMapTap(LatLng position) {
    setState(() => _selectedPosition = position);
    _reverseGeocode(position);
  }

  void _onMarkerDrag(LatLng position) {
    setState(() => _selectedPosition = position);
    _reverseGeocode(position);
  }

  Future<void> _confirm() async {
    setState(() => _isSaving = true);
    try {
      await MerchantRemoteSource().updateLocation(
        lat: _selectedPosition.latitude,
        lng: _selectedPosition.longitude,
        address: _address,
      );
      if (!mounted) return;
      Navigator.of(context).pop(
        MapLocationResult(
          latitude: _selectedPosition.latitude,
          longitude: _selectedPosition.longitude,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save location: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Set Business Location',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: _green,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (c) => _mapController = c,
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 15,
            ),
            onTap: _onMapTap,
            markers: {
              Marker(
                markerId: const MarkerId('business_location'),
                position: _selectedPosition,
                draggable: true,
                onDragEnd: _onMarkerDrag,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
                infoWindow: const InfoWindow(title: 'Business Location'),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),

          // Instructional overlay at the top
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: _green, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tap the map or drag the pin to set your location.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF374151)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confirm button at the bottom
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _confirm,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  'Confirm Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  disabledBackgroundColor: _green.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          // Address / coordinates display
          Positioned(
            bottom: 88,
            left: 16,
            right: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: _loadingAddress
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _green),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_address != null)
                            Text(
                              _address!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.w500),
                            ),
                          if (_address != null) const SizedBox(height: 2),
                          Text(
                            '${_selectedPosition.latitude.toStringAsFixed(5)}, '
                            '${_selectedPosition.longitude.toStringAsFixed(5)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
