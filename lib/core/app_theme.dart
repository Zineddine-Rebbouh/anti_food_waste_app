import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // -------------------------
  // Colors (Light Theme)
  // -------------------------
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF212121);

  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF212121);

  static const Color primary = Color(0xFF2D8659); // Primary Green
  static const Color primaryForeground = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFFFFF8E1);
  static const Color secondaryForeground = Color(0xFF212121);

  static const Color muted = Color(0xFFECECF0);
  static const Color mutedForeground = Color(0xFF757575);

  static const Color accent = Color(0xFFD32F2F);
  static const Color accentForeground = Color(0xFFFFFFFF);

  static const Color destructive = Color(0xFFF44336);
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  static const Color border = Color(0x1A000000); // rgba(0, 0, 0, 0.1)
  static const Color inputBackground = Color(0xFFF3F3F5);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // -------------------------
  // Typography
  // -------------------------
  static TextTheme _getTextTheme(String languageCode) {
    if (languageCode == 'ar') {
      return GoogleFonts.tajawalTextTheme();
    } else {
      return GoogleFonts.poppinsTextTheme();
    }
  }

  // -------------------------
  // Theme Factory
  // -------------------------
  static ThemeData getTheme(Locale locale) {
    final textTheme = _getTextTheme(locale.languageCode);
    final String? fontFamily = locale.languageCode == 'ar'
        ? GoogleFonts.tajawal().fontFamily
        : GoogleFonts.poppins().fontFamily;

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: background,
        error: destructive,
        onPrimary: primaryForeground,
        onSecondary: secondaryForeground,
        onSurface: foreground,
        onError: destructiveForeground,
      ),
      scaffoldBackgroundColor: background,
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          color: foreground,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: foreground,
          fontSize: 16,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: foreground,
          fontSize: 14,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primaryForeground,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(
          color: mutedForeground,
          fontSize: 14,
        ),
      ),
    );
  }

  // -------------------------
  // Common Values
  // -------------------------
  static const double radius = 12.0;
  static const double padding = 24.0;
  static const double baseFontSize = 16.0;

  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightBold = FontWeight.w700;
}
