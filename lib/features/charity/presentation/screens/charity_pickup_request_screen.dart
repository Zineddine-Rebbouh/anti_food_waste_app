import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';

class CharityPickupRequestScreen extends StatefulWidget {
  const CharityPickupRequestScreen({super.key, required this.donation});

  final CharityDonation donation;

  @override
  State<CharityPickupRequestScreen> createState() =>
      _CharityPickupRequestScreenState();
}

class _CharityPickupRequestScreenState
    extends State<CharityPickupRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _contactPersonCtrl =
      TextEditingController(text: 'Nadia Benali');
  final _contactPhoneCtrl =
      TextEditingController(text: '0555 123 456');
  final _notesCtrl = TextEditingController();

  String _selectedVehicle = 'Van';
  int _selectedSlot = 0;
  bool _isSubmitting = false;

  static const _vehicleOptions = [
    {'label': 'Bicycle', 'icon': Icons.directions_bike_outlined},
    {'label': 'Car', 'icon': Icons.directions_car_outlined},
    {'label': 'Van', 'icon': Icons.local_shipping_outlined},
    {'label': 'Truck', 'icon': Icons.fire_truck_outlined},
  ];

  List<Map<String, String>> get _timeSlots => [
        {
          'label':
              'Today, ${widget.donation.pickupWindowStart}',
          'sub': 'Recommended — within usual window',
        },
        {
          'label': 'Today, 30 min before closing',
          'sub': 'Available if donor approves',
        },
        {
          'label': 'Next available slot',
          'sub': 'Donor will confirm exact time',
        },
      ];

  @override
  void dispose() {
    _contactPersonCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;
    _showSuccessSheet();
  }

  void _showSuccessSheet() {
    final requestId =
        '#REQ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Request Submitted!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your pickup request has been sent to '
              '${widget.donation.merchantName}. You will be notified '
              'once it\'s confirmed.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Request ID: $requestId',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
              ),
              child: const Text(
                'Go to My Pickups',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.mutedForeground,
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Request Pickup',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDonationSummary(),
              const SizedBox(height: 8),
              _buildPickupSlotSection(),
              const SizedBox(height: 8),
              _buildVehicleSection(),
              const SizedBox(height: 8),
              _buildContactSection(),
              const SizedBox(height: 8),
              _buildNotesSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section 1: Donation Summary ─────────────────────────────────────────────

  Widget _buildDonationSummary() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Requesting pickup from:',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.donation.merchantName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.donation.merchantAddress,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoBadge(
                icon: Icons.scale_outlined,
                label: '${widget.donation.quantityKg} kg',
                color: AppTheme.primary,
              ),
              _InfoBadge(
                icon: Icons.restaurant_outlined,
                label: '~${widget.donation.estimatedServings} servings',
                color: Colors.orange.shade700,
              ),
              _InfoBadge(
                icon: Icons.access_time_rounded,
                label:
                    '${widget.donation.pickupWindowStart} – ${widget.donation.pickupWindowEnd}',
                color: AppTheme.info,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section 2: Pickup Slot ───────────────────────────────────────────────────

  Widget _buildPickupSlotSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Pickup Time',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(_timeSlots.length, (i) {
            final slot = _timeSlots[i];
            final isSelected = _selectedSlot == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedSlot = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withOpacity(0.06)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.transparent,
                      width: 4,
                    ),
                    top: BorderSide(
                      color: isSelected
                          ? AppTheme.primary.withOpacity(0.2)
                          : Colors.grey.shade200,
                    ),
                    right: BorderSide(
                      color: isSelected
                          ? AppTheme.primary.withOpacity(0.2)
                          : Colors.grey.shade200,
                    ),
                    bottom: BorderSide(
                      color: isSelected
                          ? AppTheme.primary.withOpacity(0.2)
                          : Colors.grey.shade200,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Radio<int>(
                      value: i,
                      groupValue: _selectedSlot,
                      activeColor: AppTheme.primary,
                      onChanged: (v) =>
                          setState(() => _selectedSlot = v!),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slot['label']!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppTheme.primary
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              slot['sub']!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Section 3: Vehicle Selection ────────────────────────────────────────────

  Widget _buildVehicleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehicle Type',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _vehicleOptions.map((v) {
              final label = v['label'] as String;
              final icon = v['icon'] as IconData;
              final isSelected = _selectedVehicle == label;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _selectedVehicle = label),
                  child: Container(
                    margin: EdgeInsets.only(
                      right:
                          label == (_vehicleOptions.last['label'] as String)
                              ? 0
                              : 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withOpacity(0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 24,
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.mutedForeground,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Section 4: Contact Info ─────────────────────────────────────────────────

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _contactPersonCtrl,
            decoration: InputDecoration(
              hintText: 'Contact person name',
              labelText: 'Contact Person',
              filled: true,
              fillColor: AppTheme.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _contactPhoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Phone number',
              labelText: 'Contact Phone',
              filled: true,
              fillColor: AppTheme.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  // ── Section 5: Notes ────────────────────────────────────────────────────────

  Widget _buildNotesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes (Optional)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Any special instructions for the merchant?',
              filled: true,
              fillColor: AppTheme.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Submit Button ────────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Confirm Pickup Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Helper widget ────────────────────────────────────────────────────────────

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
