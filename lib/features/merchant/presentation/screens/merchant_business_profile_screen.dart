import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_map_location_screen.dart';

class MerchantBusinessProfileScreen extends StatefulWidget {
  const MerchantBusinessProfileScreen({super.key});

  @override
  State<MerchantBusinessProfileScreen> createState() =>
      _MerchantBusinessProfileScreenState();
}

class _MerchantBusinessProfileScreenState
    extends State<MerchantBusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _wilayaCtrl;

  double? _pickedLat;
  double? _pickedLng;

  String _selectedType = 'Bakery';
  bool _isSaving = false;

  static const _businessTypes = [
    'Bakery',
    'Restaurant',
    'Café',
    'Grocery',
    'Butcher',
    'Pastry Shop',
    'Snack Bar',
    'Supermarket',
    'Other',
  ];

  static const _businessHours = [
    _HoursRow(day: 'Monday', hours: '07:00 – 20:00', open: true),
    _HoursRow(day: 'Tuesday', hours: '07:00 – 20:00', open: true),
    _HoursRow(day: 'Wednesday', hours: '07:00 – 20:00', open: true),
    _HoursRow(day: 'Thursday', hours: '07:00 – 20:00', open: true),
    _HoursRow(day: 'Friday', hours: '14:00 – 20:00', open: true),
    _HoursRow(day: 'Saturday', hours: '07:00 – 13:00', open: true),
    _HoursRow(day: 'Sunday', hours: 'Closed', open: false),
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<MerchantCubit>().state;
    final profile = state is MerchantLoaded ? state.profile : null;
    _nameCtrl =
        TextEditingController(text: profile?.businessName ?? '');
    _phoneCtrl =
        TextEditingController(text: profile?.phone ?? '');
    _addressCtrl =
        TextEditingController(text: profile?.address ?? '');
    _wilayaCtrl =
        TextEditingController(text: profile?.wilaya ?? '');
    _selectedType = profile?.businessType ?? 'Bakery';
    _pickedLat = profile?.latitude;
    _pickedLng = profile?.longitude;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _wilayaCtrl.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<MapLocationResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MerchantMapLocationScreen(
          initialLat: _pickedLat,
          initialLng: _pickedLng,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _pickedLat = result.latitude;
        _pickedLng = result.longitude;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final cubit = context.read<MerchantCubit>();
    final state = cubit.state;
    if (state is MerchantLoaded) {
      final updated = state.profile.copyWith(
        businessName: _nameCtrl.text.trim(),
        businessType: _selectedType,
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        wilaya: _wilayaCtrl.text.trim(),
      );
      cubit.updateProfile(updated);
    }
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: Color(0xFF2D8659),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFF2D8659),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2D8659), Color(0xFF1A5E3C)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(56, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text(
                          'Business Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Edit your business information',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: 'Basic Info',
                    children: [
                      _buildField(
                        controller: _nameCtrl,
                        label: 'Business Name',
                        icon: Icons.store_outlined,
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      _buildTypeDropdown(),
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _phoneCtrl,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Location',
                    children: [
                      _buildField(
                        controller: _addressCtrl,
                        label: 'Street Address',
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _wilayaCtrl,
                        label: 'Wilaya',
                        icon: Icons.map_outlined,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openMapPicker,
                          icon: const Icon(
                            Icons.pin_drop_outlined,
                            size: 18,
                            color: Color(0xFF2D8659),
                          ),
                          label: Text(
                            _pickedLat != null
                                ? 'Location set  (${_pickedLat!.toStringAsFixed(4)}, ${_pickedLng!.toStringAsFixed(4)})'
                                : 'Set Location on Map',
                            style: const TextStyle(
                              color: Color(0xFF2D8659),
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2D8659)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildHoursSection(),
                  const SizedBox(height: 16),
                  _buildDocumentsSection(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D8659),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2)
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF2D8659), width: 2),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      items: _businessTypes
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: (v) => setState(() => _selectedType = v ?? _selectedType),
      decoration: InputDecoration(
        labelText: 'Business Type',
        prefixIcon: const Icon(Icons.category_outlined,
            color: Color(0xFF9CA3AF), size: 20),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF2D8659), width: 2),
        ),
      ),
    );
  }

  Widget _buildHoursSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Business Hours',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined,
                    size: 14, color: Color(0xFF2D8659)),
                label: const Text(
                  'Edit',
                  style:
                      TextStyle(color: Color(0xFF2D8659), fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: _businessHours.asMap().entries.map((e) {
                final i = e.key;
                final row = e.value;
                return Column(
                  children: [
                    if (i > 0)
                      const Divider(
                          height: 1,
                          color: Color(0xFFF3F4F6),
                          indent: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              row.day,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF374151)),
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: row.open
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFD1D5DB),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            row.hours,
                            style: TextStyle(
                              fontSize: 13,
                              color: row.open
                                  ? const Color(0xFF111827)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verification Documents',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _DocumentRow(
                  label: 'Trade Register',
                  status: 'Verified',
                  statusColor: const Color(0xFF10B981),
                  icon: Icons.description_outlined,
                ),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                _DocumentRow(
                  label: 'Food Safety Certificate',
                  status: 'Pending Review',
                  statusColor: const Color(0xFFF59E0B),
                  icon: Icons.verified_outlined,
                ),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                _DocumentRow(
                  label: 'ID Document',
                  status: 'Verified',
                  statusColor: const Color(0xFF10B981),
                  icon: Icons.badge_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HoursRow {
  final String day;
  final String hours;
  final bool open;
  const _HoursRow({required this.day, required this.hours, required this.open});
}

class _DocumentRow extends StatelessWidget {
  final String label;
  final String status;
  final Color statusColor;
  final IconData icon;

  const _DocumentRow({
    required this.label,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF2D8659).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2D8659), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF374151)),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
