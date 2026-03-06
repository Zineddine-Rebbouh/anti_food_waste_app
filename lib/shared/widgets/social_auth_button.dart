import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';

enum SocialAuthType { google, facebook, email }

class SocialAuthButton extends StatelessWidget {
  final SocialAuthType type;
  final String text;
  final VoidCallback onPressed;

  const SocialAuthButton({
    super.key,
    required this.type,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case SocialAuthType.google:
        return _buildGoogleButton();
      case SocialAuthType.facebook:
        return _buildFacebookButton();
      case SocialAuthType.email:
        return _buildEmailButton();
    }
  }

  Widget _buildGoogleButton() {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppTheme.card,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://developers.google.com/identity/images/g-logo.png',
            height: 24,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: AppTheme.baseFontSize,
              color: AppTheme.cardForeground,
              fontWeight: AppTheme.fontWeightNormal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacebookButton() {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1877F2),
        foregroundColor: AppTheme.primaryForeground,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.facebook, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: AppTheme.baseFontSize,
              fontWeight: AppTheme.fontWeightNormal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailButton() {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        side: const BorderSide(color: AppTheme.primary, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mail_outline, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: AppTheme.baseFontSize,
              fontWeight: AppTheme.fontWeightNormal,
            ),
          ),
        ],
      ),
    );
  }
}
