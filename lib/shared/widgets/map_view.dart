import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/shared/models/food_listing.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MapView extends StatefulWidget {
  final List<FoodListing> listings;
  final void Function(FoodListing)? onListingTap;

  const MapView({super.key, required this.listings, this.onListingTap});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  FoodListing? _selectedListing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Mock Map Background
        Container(
          color: const Color(0xFFF5F5F5),
          child: CustomPaint(
            painter: MapGridPainter(),
            size: Size.infinite,
          ),
        ),

        // Mock Pins
        ...widget.listings.map((l) => _buildPin(l)),

        // Selected Info Card
        if (_selectedListing != null)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: _buildInfoCard(_selectedListing!),
            ),
          ),

        // Map Controls
        Positioned(
          top: 20,
          right: 20,
          child: Column(
            children: [
              _buildMapButton(Icons.my_location),
              const SizedBox(height: 12),
              _buildMapButton(Icons.layers_outlined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPin(FoodListing listing) {
    // Arbitrary positioning for mock effect
    final double left = (listing.lng % 0.1) * 2000 + 100;
    final double top = (listing.lat % 0.1) * 2000 + 100;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => setState(() => _selectedListing = listing),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(blurRadius: 4, color: Colors.black26)
                ],
              ),
              child:
                  const Icon(Icons.shopping_bag, size: 20, color: Colors.white),
            ),
            Container(
              width: 2,
              height: 10,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(FoodListing listing) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => widget.onListingTap?.call(listing),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(listing.imageUrl,
                    width: 80, height: 80, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(listing.merchantName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(listing.title,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${listing.rating}',
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${listing.distance} km',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    if (widget.onListingTap != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.view_details,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _selectedListing = null),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapButton(IconData icon) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)]),
      child:
          IconButton(icon: Icon(icon, color: Colors.black54), onPressed: () {}),
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
