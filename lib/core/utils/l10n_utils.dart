import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class L10nUtils {
  static String translateError(String key, AppLocalizations l10n) {
    switch (key) {
      case 'error_no_connection':
        return l10n.error_no_connection;
      case 'error_unauthorized':
        return l10n.error_unauthorized;
      case 'error_forbidden':
        return l10n.error_forbidden;
      case 'error_generic':
        return l10n.error_generic;
      default:
        return key;
    }
  }
}
