import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/shared/widgets/custom_text_field.dart';
import 'package:anti_food_waste_app/shared/widgets/password_field.dart';
import 'package:anti_food_waste_app/shared/widgets/info_box.dart';

class MerchantSignUpForm extends StatelessWidget {
  final TextEditingController businessNameController;
  final String businessType;
  final TextEditingController businessAddressController;
  final TextEditingController businessPhoneController;
  final TextEditingController contactNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool agreedToTerms;
  final Function(String) onBusinessTypeChanged;
  final Function(bool) onTermsChanged;

  const MerchantSignUpForm({
    super.key,
    required this.businessNameController,
    required this.businessType,
    required this.businessAddressController,
    required this.businessPhoneController,
    required this.contactNameController,
    required this.emailController,
    required this.passwordController,
    required this.agreedToTerms,
    required this.onBusinessTypeChanged,
    required this.onTermsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.business_info,
          style: const TextStyle(
              color: AppTheme.mutedForeground, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.business_name,
          controller: businessNameController,
          hint: "Boulangerie El Khobz",
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          l10n.business_type,
          [
            DropdownMenuItem(value: 'bakery', child: Text(l10n.bakery)),
            DropdownMenuItem(value: 'restaurant', child: Text(l10n.restaurant)),
            DropdownMenuItem(
                value: 'supermarket', child: Text(l10n.supermarket)),
            DropdownMenuItem(value: 'cafe', child: Text(l10n.cafe)),
            DropdownMenuItem(value: 'hotel', child: Text(l10n.hotel)),
          ],
          (val) => onBusinessTypeChanged(val!),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.business_address,
          controller: businessAddressController,
          hint: "123 Rue Didouche Mourad, Algiers",
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.phone_number,
          controller: businessPhoneController,
          hint: "+213 21 XX XX XX",
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        Text(
          l10n.your_contact,
          style: const TextStyle(
              color: AppTheme.mutedForeground, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.your_name,
          controller: contactNameController,
          hint: "Mohamed Cherif",
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.email,
          controller: emailController,
          hint: "mohamed@elkhobz.dz",
          keyboardType: TextInputType.emailAddress,
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
              child: Text(l10n.authorized_confirm,
                  style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InfoBox(
          text: l10n.review_time,
          icon: Icons.info_outline,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    List<DropdownMenuItem<String>> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.inputBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: businessType,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }
}
