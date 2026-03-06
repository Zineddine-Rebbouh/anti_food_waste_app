import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

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

  // ── Computed getters ──────────────────────────────────────────────────────

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
    if (_newPassword.length < 6) return AppTheme.accent;
    if (_newPassword.length < 10 || !_allRequirementsMet) return Colors.orange;
    return AppTheme.primary;
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

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    if (_newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwords_dont_match),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.password_changed_success),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.of(context).pop();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.change_password,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Lock icon ────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Current password ─────────────────────────────────────────
              _PasswordField(
                controller: _currentCtrl,
                label: l10n.current_password,
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.current_password;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── New password ─────────────────────────────────────────────
              _PasswordField(
                controller: _newCtrl,
                label: l10n.new_password_label,
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.new_password_label;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Confirm password ─────────────────────────────────────────
              _PasswordField(
                controller: _confirmCtrl,
                label: l10n.confirm_new_password,
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.confirm_new_password;
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ── Strength indicator + requirements (shown when typing) ─────
              if (_newPassword.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.password_requirements,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _strengthLabel(l10n),
                      style: TextStyle(
                        color: _strengthColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _strengthValue),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (context, value, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: AppTheme.inputBackground,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_strengthColor),
                        minHeight: 7,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Requirements checklist
                _RequirementRow(
                  met: _hasMinLength,
                  label: l10n.min_8_chars,
                ),
                _RequirementRow(
                  met: _hasUppercase,
                  label: l10n.uppercase_required,
                ),
                _RequirementRow(
                  met: _hasDigit,
                  label: l10n.number_required,
                ),
                _RequirementRow(
                  met: _hasSpecial,
                  label: l10n.special_char_required,
                ),
                const SizedBox(height: 28),
              ],

              if (_newPassword.isEmpty) const SizedBox(height: 12),

              // ── Update button ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _canSubmit ? AppTheme.primary : AppTheme.muted,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.muted,
                    disabledForegroundColor: AppTheme.mutedForeground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed:
                      _canSubmit && !_isLoading ? () => _submit(l10n) : null,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          l10n.update_password,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── _PasswordField ───────────────────────────────────────────────────────────

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _PasswordField({
    required this.controller,
    required this.label,
    this.validator,
    this.onChanged,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      onChanged: widget.onChanged,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: AppTheme.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
            color: AppTheme.mutedForeground,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

// ─── _RequirementRow ─────────────────────────────────────────────────────────

class _RequirementRow extends StatelessWidget {
  final bool met;
  final String label;

  const _RequirementRow({required this.met, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: met ? AppTheme.primary : AppTheme.mutedForeground,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: met ? AppTheme.primary : AppTheme.mutedForeground,
              fontSize: 13,
              fontWeight: met ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .slideX(begin: 0.3, duration: 300.ms, curve: Curves.easeOut),
    );
  }
}
