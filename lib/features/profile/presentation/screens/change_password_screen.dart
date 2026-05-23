import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:anti_food_waste_app/features/consumer/data/repositories/consumer_repository.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;

  static const Color forestGreen = AppTheme.primary;
  static const Color accentBeige = Colors.white;
  static const Color textNavy = Color(0xFF1A1A2E);

  String get _newPassword => _newCtrl.text;
  bool get _hasMinLength => _newPassword.length >= 8;
  bool get _hasUppercase => _newPassword.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _newPassword.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial => _newPassword.contains(RegExp(r'[!@#$%]'));
  bool get _allRequirementsMet =>
      _hasMinLength && _hasUppercase && _hasDigit && _hasSpecial;

  double get _strengthValue {
    if (_newPassword.isEmpty) return 0;
    if (_newPassword.length < 6) return 0.25;
    if (_newPassword.length < 10 || !_allRequirementsMet) return 0.6;
    return 1.0;
  }

  Color get _strengthColor {
    if (_newPassword.isEmpty) return Colors.transparent;
    if (_newPassword.length < 6) return const Color(0xFFEF4444);
    if (_newPassword.length < 10 || !_allRequirementsMet) return const Color(0xFFF59E0B);
    return forestGreen;
  }

  String _strengthLabel(AppLocalizations l10n) {
    if (_newPassword.isEmpty) return '';
    if (_newPassword.length < 6) return l10n.weak;
    if (_newPassword.length < 10 || !_allRequirementsMet) return l10n.medium;
    return l10n.strong;
  }

  bool get _canSubmit =>
      _currentCtrl.text.isNotEmpty &&
      _newCtrl.text.isNotEmpty &&
      _confirmCtrl.text.isNotEmpty &&
      _allRequirementsMet;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    if (_newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwords_dont_match),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ConsumerRepository().changePassword(
        oldPassword: _currentCtrl.text,
        newPassword: _newCtrl.text,
        newPasswordConfirm: _confirmCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.password_changed_success),
          backgroundColor: forestGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop();
    } on Object catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('old_password')
          ? l10n.password_current_incorrect
          : l10n.passwords_dont_match;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: accentBeige,
      body: Column(
        children: [
          _buildHeader(context, l10n),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: forestGreen.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.lock_shield_fill,
                          color: forestGreen,
                          size: 38,
                        ),
                      ).animate().scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    ),
                    const SizedBox(height: 40),

                    _buildFieldLabel(l10n.current_password),
                    _PasswordField(
                      controller: _currentCtrl,
                      hint: '••••••••',
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.current_password;
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildFieldLabel(l10n.new_password_label),
                    _PasswordField(
                      controller: _newCtrl,
                      hint: '••••••••',
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.new_password_label;
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildFieldLabel(l10n.confirm_new_password),
                    _PasswordField(
                      controller: _confirmCtrl,
                      hint: '••••••••',
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.confirm_new_password;
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    if (_newPassword.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.password_requirements,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: textNavy),
                          ),
                          Text(
                            _strengthLabel(l10n).toUpperCase(),
                            style: TextStyle(color: _strengthColor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                          ),
                        ],
                      ).animate().fadeIn(),
                      const SizedBox(height: 12),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _strengthValue),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutQuart,
                        builder: (context, value, _) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.white,
                              valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                              minHeight: 8,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _RequirementRow(met: _hasMinLength, label: l10n.min_8_chars),
                      _RequirementRow(met: _hasUppercase, label: l10n.uppercase_required),
                      _RequirementRow(met: _hasDigit, label: l10n.number_required),
                      _RequirementRow(met: _hasSpecial, label: l10n.special_char_required),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: forestGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                onPressed: _canSubmit && !_isLoading ? () => _submit(l10n) : null,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        l10n.update_password,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
              ),
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
                l10n.change_password,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: forestGreen.withOpacity(0.5), letterSpacing: 1),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _PasswordField({required this.controller, required this.hint, this.validator, this.onChanged});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    const forestGreen = AppTheme.primary;
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      onChanged: widget.onChanged,
      validator: widget.validator,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: widget.hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: forestGreen, width: 1.5)),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill, color: Colors.grey[400], size: 20),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final bool met;
  final String label;

  const _RequirementRow({required this.met, required this.label});

  @override
  Widget build(BuildContext context) {
    const forestGreen = AppTheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: met ? forestGreen.withOpacity(0.1) : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              met ? Icons.check_rounded : Icons.circle_outlined,
              color: met ? forestGreen : Colors.grey[300],
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: met ? const Color(0xFF1A1A2E) : Colors.grey[500],
              fontSize: 13,
              fontWeight: met ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, duration: 300.ms),
    );
  }
}
