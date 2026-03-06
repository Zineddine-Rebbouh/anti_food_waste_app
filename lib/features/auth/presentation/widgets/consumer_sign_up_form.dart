import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/shared/widgets/custom_text_field.dart';
import 'package:anti_food_waste_app/shared/widgets/password_field.dart';

class ConsumerSignUpForm extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool agreedToTerms;
  final bool sendUpdates;
  final Function(bool) onTermsChanged;
  final Function(bool) onUpdatesChanged;

  const ConsumerSignUpForm({
    super.key,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.agreedToTerms,
    required this.sendUpdates,
    required this.onTermsChanged,
    required this.onUpdatesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        CustomTextField(
          label: l10n.full_name,
          controller: fullNameController,
          hint: "Ahmed Benali",
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.email,
          controller: emailController,
          hint: "ahmed@example.com",
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: "${l10n.phone} ${l10n.phone_optional}",
          controller: phoneController,
          hint: "+213 551 23 45 67",
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        PasswordField(
          label: l10n.password,
          controller: passwordController,
        ),
        const SizedBox(height: 24),
        Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: agreedToTerms,
                  onChanged: (val) => onTermsChanged(val!),
                  activeColor: AppTheme.primary,
                ),
                Expanded(
                  child: Text(l10n.agree_terms,
                      style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: sendUpdates,
                  onChanged: (val) => onUpdatesChanged(val!),
                  activeColor: AppTheme.primary,
                ),
                Expanded(
                  child: Text(l10n.send_updates,
                      style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
