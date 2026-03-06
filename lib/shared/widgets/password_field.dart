import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: widget.controller,
          builder: (context, value, child) {
            return Column(
              children: [
                TextField(
                  controller: widget.controller,
                  obscureText: !_showPassword,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "••••••••",
                    filled: true,
                    fillColor: AppTheme.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                ),
                if (widget.controller.text.isNotEmpty)
                  _buildPasswordStrengthIndicator(widget.controller.text, l10n),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator(
      String password, AppLocalizations l10n) {
    double strength = 0;
    String label = l10n.weak;
    Color color = Colors.red;

    if (password.length >= 8) {
      strength = 0.33;
      label = l10n.weak;
    }
    if (password.length >= 10 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password)) {
      strength = 0.66;
      label = l10n.medium;
      color = Colors.orange;
    }
    if (password.length >= 12 &&
        RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength = 1.0;
      label = l10n.strong;
      color = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: strength,
              backgroundColor: Colors.grey[200],
              color: color,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
