import 'package:shared_preferences/shared_preferences.dart';

/// A simple wrapper around SharedPreferences to manage key app settings
/// like Theme, Locale, Onboarding status, and Cached Favorites.
class PreferencesService {
  PreferencesService._();

  static late SharedPreferences _prefs;

  // Keys
  static const String _keyLocale = 'app_locale';
  static const String _keyThemeMode = 'app_theme_mode'; // 'light', 'dark', or 'system'
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyFavoriteIds = 'cached_favorite_ids';

  /// Must be called essentially first thing in main()
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ------------------------------------------------------------------------
  // Locale Preferences
  // ------------------------------------------------------------------------
  static String? getLocale() => _prefs.getString(_keyLocale);
  static Future<void> setLocale(String languageCode) => _prefs.setString(_keyLocale, languageCode);
  static Future<void> clearLocale() => _prefs.remove(_keyLocale);

  // ------------------------------------------------------------------------
  // Theme Preferences
  // ------------------------------------------------------------------------
  static String? getThemeMode() => _prefs.getString(_keyThemeMode);
  static Future<void> setThemeMode(String mode) => _prefs.setString(_keyThemeMode, mode);

  // ------------------------------------------------------------------------
  // Onboarding
  // ------------------------------------------------------------------------
  static bool hasSeenOnboarding() => _prefs.getBool(_keyHasSeenOnboarding) ?? false;
  static Future<void> setHasSeenOnboarding(bool value) => _prefs.setBool(_keyHasSeenOnboarding, value);

  // ------------------------------------------------------------------------
  // Favorites Cache
  // ------------------------------------------------------------------------
  static List<String> getFavoriteIds() {
    return _prefs.getStringList(_keyFavoriteIds) ?? [];
  }
  
  static Future<void> setFavoriteIds(List<String> ids) async {
    await _prefs.setStringList(_keyFavoriteIds, ids);
  }
}
