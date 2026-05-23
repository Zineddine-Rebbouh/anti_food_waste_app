import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/cubits/merchant_cubit.dart';
import 'package:anti_food_waste_app/features/merchant/presentation/screens/merchant_map_location_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/utils/app_logger.dart';

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

  XFile? _pickedLogo;
  String _selectedType = 'Bakery';
  bool _isSaving = false;

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    final state = context.read<MerchantCubit>().state;
    if (state is MerchantLoaded) {
      final profile = state.profile;
      _nameCtrl = TextEditingController(text: profile.businessName);
      _phoneCtrl = TextEditingController(text: profile.phone);
      _addressCtrl = TextEditingController(text: profile.address);
      _wilayaCtrl = TextEditingController(text: profile.wilaya);
      _selectedType = profile.businessType;
      _pickedLat = profile.latitude;
      _pickedLng = profile.longitude;
    } else {
      _nameCtrl = TextEditingController();
      _phoneCtrl = TextEditingController();
      _addressCtrl = TextEditingController();
      _wilayaCtrl = TextEditingController();
    }
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

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked != null) {
      setState(() => _pickedLogo = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);

    final cubit = context.read<MerchantCubit>();
    String? newLogoUrl;

    if (_pickedLogo != null) {
      try {
        newLogoUrl = await cubit.uploadLogoAsync(_pickedLogo!.path);
      } catch (e) {
        AppLogger.error('MerchantBusinessProfileScreen: Logo upload failed', e);
      }
    }

    try {
      await cubit.updateProfileAsync(
        businessName: _nameCtrl.text.trim(),
        businessType: _selectedType,
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        wilaya: _wilayaCtrl.text.trim(),
        avatarUrl: newLogoUrl,
        latitude: _pickedLat,
        longitude: _pickedLng,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profile_updated_msg),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      AppLogger.error('MerchantBusinessProfileScreen: Profile update failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profile_update_failed), backgroundColor: Colors.red)
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<MerchantCubit, MerchantState>(
      builder: (context, state) {
        if (state is MerchantLoading && !_isSaving) {
          return const Scaffold(
            backgroundColor: backgroundColor,
            body: Center(child: CircularProgressIndicator(color: primaryGreen)),
          );
        }
        if (state is! MerchantLoaded) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: Center(child: Text(l10n.error_label)),
          );
        }

        final profile = state.profile;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, l10n),
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Column(
                    children: [
                      _buildLogoSection(profile, l10n),
                      const SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildSectionHeader(l10n.business_info.toUpperCase()),
                            _buildSectionCard([
                              _buildField(
                                controller: _nameCtrl,
                                label: l10n.business_name,
                                icon: Icons.store_outlined,
                                validator: (v) => v == null || v.isEmpty ? l10n.required_label : null,
                                hintText: l10n.enter_label(l10n.business_name),
                              ),
                              const SizedBox(height: 20),
                              _buildTypeDropdown(l10n),
                              const SizedBox(height: 20),
                              _buildField(
                                controller: _phoneCtrl,
                                label: l10n.phone_number,
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                hintText: l10n.enter_label(l10n.phone_number),
                              ),
                            ]),
                            const SizedBox(height: 32),
                            _buildSectionHeader(l10n.location_details.toUpperCase()),
                            _buildSectionCard([
                              _buildField(
                                controller: _addressCtrl,
                                label: l10n.street_address,
                                icon: Icons.location_on_outlined,
                                hintText: l10n.enter_label(l10n.street_address),
                              ),
                              const SizedBox(height: 20),
                              _buildField(
                                controller: _wilayaCtrl,
                                label: l10n.wilaya_label,
                                icon: Icons.map_outlined,
                                hintText: l10n.enter_label(l10n.wilaya_label),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  onPressed: _openMapPicker,
                                  icon: const Icon(Icons.pin_drop_rounded, size: 18, color: primaryGreen),
                                  label: Text(
                                    _pickedLat != null ? l10n.confirmed_label : l10n.confirm_location_action,
                                    style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: primaryGreen.withOpacity(0.05),
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 32),
                            _buildHoursSection(l10n),
                            const SizedBox(height: 32),
                            _buildDocumentsSection(l10n),
                            const SizedBox(height: 48),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGreen,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: _isSaving
                                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                      : Text(l10n.save_changes.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: const BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(48), bottomRight: Radius.circular(48)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.edit_profile,
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
              Text(
                l10n.manage_public_presence,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.grey.shade400),
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: primaryGreen, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: Colors.grey.shade300, size: 20),
            filled: true,
            fillColor: backgroundColor.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown(AppLocalizations l10n) {
    final types = [
      (l10n.bakery, 'Bakery'),
      (l10n.restaurant, 'Restaurant'),
      (l10n.cafe, 'Café'),
      (l10n.grocery, 'Grocery'),
      (l10n.butcher, 'Butcher'),
      (l10n.pastry_shop, 'Pastry Shop'),
      (l10n.snack_bar, 'Snack Bar'),
      (l10n.supermarket, 'Supermarket'),
      (l10n.other_label, 'Other'),
    ];

    final safeValue = types.any((t) => t.$2 == _selectedType) ? _selectedType : 'Other';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.business_type.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: primaryGreen, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: safeValue,
          items: types.map((t) => DropdownMenuItem(value: t.$2, child: Text(t.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)))).toList(),
          onChanged: (v) => setState(() => _selectedType = v ?? _selectedType),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.category_outlined, color: Colors.grey.shade300, size: 20),
            filled: true,
            fillColor: backgroundColor.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection(dynamic profile, AppLocalizations l10n) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD54F),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white, width: 6),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 24, offset: const Offset(0, 12))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: _pickedLogo != null
                  ? Image.file(File(_pickedLogo!.path), fit: BoxFit.cover)
                  : (profile.avatarUrl.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: profile.avatarUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : Center(child: Text(profile.initials, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.black87))),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _pickLogo,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursSection(AppLocalizations l10n) {
    final hours = [
      (l10n.monday, '07:00 – 20:00', true),
      (l10n.tuesday, '07:00 – 20:00', true),
      (l10n.wednesday, '07:00 – 20:00', true),
      (l10n.thursday, '07:00 – 20:00', true),
      (l10n.friday, '14:00 – 20:00', true),
      (l10n.saturday, '07:00 – 13:00', true),
      (l10n.sunday, l10n.closed_label, false),
    ];

    return Column(
      children: [
        _buildSectionHeader(l10n.business_hours),
        _buildSectionCard(
          hours.map((h) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(width: 100, child: Text(h.$1, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14))),
                Container(width: 8, height: 8, decoration: BoxDecoration(color: h.$3 ? const Color(0xFF2D8659) : Colors.grey.shade200, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Text(h.$2, style: TextStyle(color: h.$3 ? Colors.black87 : Colors.grey.shade400, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(AppLocalizations l10n) {
    return Column(
      children: [
        _buildSectionHeader(l10n.verification.toUpperCase()),
        _buildSectionCard([
          _DocTile(label: l10n.trade_register, status: l10n.verified_label, icon: Icons.verified_rounded, color: const Color(0xFF2D8659)),
          const SizedBox(height: 12),
          _DocTile(label: l10n.food_safety_cert, status: l10n.pending_label, icon: Icons.hourglass_empty_rounded, color: const Color(0xFFF59E0B)),
        ]),
      ],
    );
  }
}

class _DocTile extends StatelessWidget {
  final String label;
  final String status;
  final IconData icon;
  final Color color;

  const _DocTile({required this.label, required this.status, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
          Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 1)),
        ],
      ),
    );
  }
}



