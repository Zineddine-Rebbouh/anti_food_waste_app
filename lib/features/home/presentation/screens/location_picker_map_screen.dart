import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerMapScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPickerMapScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<LocationPickerMapScreen> createState() => _LocationPickerMapScreenState();
}

class _LocationPickerMapScreenState extends State<LocationPickerMapScreen> {
  static const _fallback = LatLng(36.7538, 3.0588); // Algiers

  LatLng? _selected;

  LatLng get _initial =>
      (widget.initialLat != null && widget.initialLng != null)
          ? LatLng(widget.initialLat!, widget.initialLng!)
          : _fallback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose on map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _initial, zoom: 14),
            onTap: (latLng) => setState(() => _selected = latLng),
            markers: {
              if (_selected != null)
                Marker(
                  markerId: const MarkerId('selected_location'),
                  position: _selected!,
                ),
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () => Navigator.pop<LatLng>(context, _selected),
              child: const Text('Use this location'),
            ),
          ),
        ],
      ),
    );
  }
}
