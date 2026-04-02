import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/features/auth/presentation/widgets/role_button.dart';
import 'package:anti_food_waste_app/features/auth/domain/models/user_role.dart';

class RoleSelectionOverlay extends StatelessWidget {
  final Function(UserRole) onRoleSelected;

  const RoleSelectionOverlay({
    super.key,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Colors.black.withOpacity(0.5),
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.who_are_you,
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.select_role_desc,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),
            RoleButton(
              icon: Icons.shopping_bag_outlined,
              title: l10n.consumer,
              description: l10n.consumer_desc,
              onTap: () => onRoleSelected(UserRole.consumer),
            ),
            const SizedBox(height: 16),
            RoleButton(
              icon: Icons.storefront_outlined,
              title: l10n.merchant,
              description: l10n.merchant_desc,
              onTap: () => onRoleSelected(UserRole.merchant),
            ),
            const SizedBox(height: 16),
            RoleButton(
              icon: Icons.volunteer_activism_outlined,
              title: l10n.charity,
              description: l10n.charity_desc,
              onTap: () => onRoleSelected(UserRole.charity),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
