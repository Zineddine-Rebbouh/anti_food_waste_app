import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/core/services/preferences_service.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('ar');

  LocaleProvider() {
    final savedLocale = PreferencesService.getLocale();
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    }
  }

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    PreferencesService.setLocale(locale.languageCode);
    notifyListeners();
  }

  void clearLocale() {
    _locale = const Locale('en');
    PreferencesService.clearLocale();
    notifyListeners();
  }
}
