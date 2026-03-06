import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
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
      color: Colors.black54,
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.who_are_you,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            RoleButton(
              icon: Icons.shopping_bag_outlined,
              title: l10n.consumer,
              description: l10n.consumer_desc,
              onTap: () => onRoleSelected(UserRole.consumer),
            ),
            const SizedBox(height: 12),
            RoleButton(
              icon: Icons.storefront,
              title: l10n.merchant,
              description: l10n.merchant_desc,
              onTap: () => onRoleSelected(UserRole.merchant),
            ),
            const SizedBox(height: 12),
            RoleButton(
              icon: Icons.favorite_outline,
              title: l10n.charity,
              description: l10n.charity_desc,
              onTap: () => onRoleSelected(UserRole.charity),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: AppTheme.mutedForeground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
