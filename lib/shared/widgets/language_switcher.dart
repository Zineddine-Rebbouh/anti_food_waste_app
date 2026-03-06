import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:anti_food_waste_app/core/providers/locale_provider.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    Locale currentLocale = localeProvider.locale;

    return TextButton.icon(
      onPressed: () {
        Locale newLocale;
        if (currentLocale.languageCode == 'ar') {
          newLocale = const Locale('fr');
        } else if (currentLocale.languageCode == 'fr') {
          newLocale = const Locale('en');
        } else {
          newLocale = const Locale('ar');
        }
        localeProvider.setLocale(newLocale);
      },
      icon: const Icon(Icons.language, size: 20),
      label: Text(
        appLocalizations.languageName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.foreground,
      ),
    );
  }
}
