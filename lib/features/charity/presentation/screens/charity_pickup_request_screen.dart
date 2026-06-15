import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';
import 'package:anti_food_waste_app/features/charity/presentation/cubit/charity_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:animate_do/animate_do.dart';

class CharityPickupRequestScreen extends StatefulWidget {
  const CharityPickupRequestScreen({super.key, required this.donation});

  final CharityDonation donation;

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color accentBeige = Colors.white;

  @override
  State<CharityPickupRequestScreen> createState() => _CharityPickupRequestScreenState();
}

class _CharityPickupRequestScreenState extends State<CharityPickupRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late AppLocalizations l10n;

  final _contactPersonCtrl = TextEditingController(text: 'Nadia Benali');
  final _contactPhoneCtrl = TextEditingController(text: '0555 123 456');
  final _notesCtrl = TextEditingController();

  String _selectedVehicle = 'Van';
  int _selectedSlot = 0;
  bool _isSubmitting = false;

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
    try {
      final notes = _notesCtrl.text.trim();
      await context.read<CharityCubit>().requestDonation(widget.donation.id, notes);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSuccessSheet();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  void _showSuccessSheet() {
    final requestId = '#REQ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: CharityPickupRequestScreen.primaryGreen.withOpacity(0.08), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, size: 48, color: CharityPickupRequestScreen.primaryGreen),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.request_submitted,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.request_sent_msg(widget.donation.merchantName),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.request_id_label(requestId),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 1),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CharityPickupRequestScreen.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(l10n.go_to_pickups, style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text(l10n.done, style: TextStyle(fontWeight: FontWeight.w800, color: Colors.grey.shade500)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: CharityPickupRequestScreen.accentBeige,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ── Premium Header ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: CharityPickupRequestScreen.primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 24, 32),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.request_pickup,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Content ────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(l10n.requesting_from, Icons.storefront_rounded),
                    const SizedBox(height: 12),
                    _buildDonationSummary(l10n),
                    const SizedBox(height: 32),
                    _buildSectionHeader(l10n.choose_pickup_time, Icons.access_time_filled_rounded),
                    const SizedBox(height: 12),
                    _buildPickupSlotSection(l10n),
                    const SizedBox(height: 32),
                    _buildSectionHeader(l10n.vehicle_type, Icons.local_shipping_rounded),
                    const SizedBox(height: 12),
                    _buildVehicleSection(l10n),
                    const SizedBox(height: 32),
                    _buildSectionHeader(l10n.contact_info, Icons.person_rounded),
                    const SizedBox(height: 12),
                    _buildContactSection(l10n),
                    const SizedBox(height: 32),
                    _buildSectionHeader(l10n.notes_optional, Icons.notes_rounded),
                    const SizedBox(height: 12),
                    _buildNotesSection(l10n),
                    const SizedBox(height: 40),
                    _buildSubmitButton(l10n),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: CharityPickupRequestScreen.primaryGreen),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -0.2),
        ),
      ],
    );
  }

  Widget _buildDonationSummary(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.donation.merchantName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: CharityPickupRequestScreen.primaryGreen),
          ),
          const SizedBox(height: 4),
          Text(
            widget.donation.merchantAddress,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _MiniStat(icon: Icons.scale_rounded, label: '${widget.donation.quantityKg} kg'),
              const SizedBox(width: 16),
              _MiniStat(icon: Icons.groups_rounded, label: l10n.servings_count(widget.donation.estimatedServings)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickupSlotSection(AppLocalizations l10n) {
    final slots = [
      {'label': '${l10n.today}, ${widget.donation.pickupWindowStart}', 'sub': l10n.recommended_window},
      {'label': '${l10n.today}, ${l10n.mins_before_closing(30)}', 'sub': l10n.donor_approves_msg},
      {'label': l10n.next_available_slot, 'sub': l10n.donor_confirm_time},
    ];

    return Column(
      children: List.generate(slots.length, (i) {
        final isSelected = _selectedSlot == i;
      return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => setState(() => _selectedSlot = i),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? CharityPickupRequestScreen.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? CharityPickupRequestScreen.primaryGreen.withOpacity(0.18)
                      : Colors.grey.shade200,
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(isSelected ? 0.1 : 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Icon(isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: isSelected ? Colors.white : Colors.grey.shade300, size: 20),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(slots[i]['label']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : const Color(0xFF111827))),
                        Text(slots[i]['sub']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white.withOpacity(0.7) : Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVehicleSection(AppLocalizations l10n) {
    final vehicles = [
      {'key': 'Bicycle', 'label': l10n.bicycle, 'icon': Icons.directions_bike_rounded},
      {'key': 'Car', 'label': l10n.car, 'icon': Icons.directions_car_rounded},
      {'key': 'Van', 'label': l10n.van, 'icon': Icons.local_shipping_rounded},
      {'key': 'Truck', 'label': l10n.truck, 'icon': Icons.fire_truck_rounded},
    ];

    return Row(
      children: vehicles.map((v) {
        final isSelected = _selectedVehicle == v['key'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedVehicle = v['key'] as String),
            child: Container(
              margin: EdgeInsets.only(right: v['key'] == 'Truck' ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? CharityPickupRequestScreen.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? CharityPickupRequestScreen.primaryGreen.withOpacity(0.18)
                      : Colors.grey.shade200,
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Icon(v['icon'] as IconData, color: isSelected ? Colors.white : Colors.grey.shade400, size: 24),
                  const SizedBox(height: 8),
                  Text(v['label'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : Colors.grey.shade500)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          _buildTextField(controller: _contactPersonCtrl, label: l10n.contact_person, icon: Icons.person_outline_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller: _contactPhoneCtrl, label: l10n.contact_phone, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
        ],
      ),
    );
  }

  Widget _buildNotesSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: _buildTextField(
        controller: _notesCtrl,
        label: l10n.special_instructions_hint,
        icon: Icons.chat_bubble_outline_rounded,
        maxLines: 3,
        requiredField: false,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool requiredField = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w700),
        prefixIcon: Icon(icon, color: CharityPickupRequestScreen.primaryGreen.withOpacity(0.5), size: 20),
        filled: true,
        fillColor: CharityPickupRequestScreen.accentBeige.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: CharityPickupRequestScreen.primaryGreen, width: 1.5)),
      ),
      validator: requiredField
          ? (v) => (v == null || v.trim().isEmpty) ? l10n.required_field : null
          : null,
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return FadeInUp(
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: CharityPickupRequestScreen.primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Text(l10n.confirm_pickup_request, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: CharityPickupRequestScreen.primaryGreen.withOpacity(0.6)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.grey.shade600)),
      ],
    );
  }
}



