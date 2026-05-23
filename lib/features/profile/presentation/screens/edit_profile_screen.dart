import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:animate_do/animate_do.dart';

import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/profile/domain/models/app_user.dart';
import 'package:anti_food_waste_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:anti_food_waste_app/shared/widgets/tawfir_loading_indicator.dart';

class EditProfileScreen extends StatefulWidget {
  final AppUser user;

  const EditProfileScreen({required this.user, super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  XFile? _pickedImage;
  bool _isSaving = false;

  static const Color forestGreen = AppTheme.primary;
  static const Color accentBeige = Colors.white;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked != null) setState(() => _pickedImage = picked);
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final parts = _nameCtrl.text.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final cubit = context.read<ProfileCubit>();

    try {
      if (_pickedImage != null) {
        await cubit.updateAvatar(_pickedImage!.path);
      }

      await cubit.updateProfile(
        firstName: firstName.isEmpty ? null : firstName,
        lastName: lastName.isEmpty ? null : lastName,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profile_updated),
          backgroundColor: forestGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profile_update_failed),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: accentBeige,
      body: Column(
        children: [
          // ── Premium Header ──────────────────────────────────────────────────
          _buildHeader(context, l10n),

          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      child: _buildAvatarPicker(l10n),
                    ),
                    const SizedBox(height: 40),

                    FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      child: Column(
                        children: [
                          _buildField(
                            controller: _nameCtrl,
                            label: l10n.full_name,
                            icon: Icons.person_rounded,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return l10n.full_name;
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                            controller: _phoneCtrl,
                            label: l10n.phone_number,
                            icon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                            controller: TextEditingController(text: widget.user.email),
                            label: l10n.email,
                            icon: Icons.email_rounded,
                            readOnly: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Save Button ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (_, state) {
                final busy = state is ProfileUpdating || _isSaving;
                return SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: busy ? null : () => _save(l10n),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: forestGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: busy
                        ? const TawfirLoadingIndicator(
                            size: 18,
                            strokeWidth: 2,
                            color: Colors.white,
                          )
                        : Text(
                            l10n.save_changes,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: forestGreen,
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
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.edit_profile,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPicker(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _pickAvatar,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: forestGreen.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
            ),
            child: ClipOval(
              child: _pickedImage != null
                  ? Image.file(
                      File(_pickedImage!.path),
                      fit: BoxFit.cover,
                    )
                  : widget.user.avatarUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.user.avatarUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _avatarPlaceholder(),
                        )
                      : _avatarPlaceholder(),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: forestGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                CupertinoIcons.camera_fill,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder() => Container(
        color: forestGreen.withOpacity(0.05),
        child: const Icon(Icons.person_rounded, size: 52, color: forestGreen),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: forestGreen.withOpacity(0.5),
              letterSpacing: 1,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          validator: validator,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: readOnly ? Colors.grey[400] : const Color(0xFF1A1A2E),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: forestGreen, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: forestGreen, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
