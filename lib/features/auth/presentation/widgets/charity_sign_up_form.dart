import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/shared/widgets/custom_text_field.dart';
import 'package:anti_food_waste_app/shared/widgets/password_field.dart';
import 'package:anti_food_waste_app/shared/widgets/info_box.dart';

class CharitySignUpForm extends StatelessWidget {
  final TextEditingController orgNameController;
  final TextEditingController regNumberController;
  final TextEditingController orgAddressController;
  final TextEditingController contactPersonController;
  final TextEditingController positionController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool agreedToTerms;
  final Function(bool) onTermsChanged;

  const CharitySignUpForm({
    super.key,
    required this.orgNameController,
    required this.regNumberController,
    required this.orgAddressController,
    required this.contactPersonController,
    required this.positionController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.agreedToTerms,
    required this.onTermsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.org_info,
          style: const TextStyle(
              color: AppTheme.mutedForeground, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.org_name,
          controller: orgNameController,
          hint: "Croissant Rouge Algérien - Alger",
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.registration_number,
          controller: regNumberController,
          hint: "06-12-XXXX",
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.address,
          controller: orgAddressController,
          hint: "15 Rue Ahmed Bey, Algiers",
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        Text(
          l10n.contact_person,
          style: const TextStyle(
              color: AppTheme.mutedForeground, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.full_name,
          controller: contactPersonController,
          hint: "Fatima Boudiaf",
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.position,
          controller: positionController,
          hint: "Coordinator",
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.email,
          controller: emailController,
          hint: "fatima@croissant-rouge.dz",
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.phone,
          controller: phoneController,
          hint: "+213 551 XX XX XX",
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        PasswordField(
          label: l10n.password,
          controller: passwordController,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Checkbox(
              value: agreedToTerms,
              onChanged: (val) => onTermsChanged(val!),
              activeColor: AppTheme.primary,
            ),
            Expanded(
              child: Text(l10n.org_authorized_confirm,
                  style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InfoBox(
          text: l10n.document_upload_note,
          icon: Icons.description_outlined,
          color: Colors.orange,
        ),
      ],
    );
  }
}
