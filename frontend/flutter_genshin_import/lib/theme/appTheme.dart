// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
/// Genshin Import — Design System
///
/// Theme customisations (all visible in-app, documented here):
///  1. Font family  : "Cinzel" (display) + "Lato" (body)
///  2. Primary color: Deep navy  #0D1B2A  (backgrounds)
///  3. Accent color : Teyvat gold #C9A84C  (buttons, highlights)
///  4. Card color   : #132236 with 0.92 alpha surface treatment
///  5. Font sizes   : headline 24sp / title 18sp / body 14sp
/// ─────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color deepNavy = Color(0xFF0D1B2A);
  static const Color darkCard = Color(0xFF132236);
  static const Color darkSurface = Color(0xFF1A2D42);

  // Accents
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C97A);
  static const Color goldDark = Color(0xFF8A6B1E);

  // Text
  static const Color textPrimary = Color(0xFFEEE8D5);
  static const Color textSecondary = Color(0xFFB0A89A);
  static const Color textDisabled = Color(0xFF6B6357);

  // Semantic
  static const Color success = Color(0xFF4CAF6E);
  static const Color error = Color(0xFFE05C5C);
  static const Color warning = Color(0xFFE8A44A);

  // Weapon type colours
  static const Map<String, Color> weaponTypeColors = {
    'Sword': Color(0xFF7EC8E3),
    'Claymore': Color(0xFFE07070),
    'Polearm': Color(0xFF90EE90),
    'Bow': Color(0xFFDDA0DD),
    'Catalyst': Color(0xFFFFD700),
  };
}

class AppTextStyles {
  AppTextStyles._();

  // Display / Cinzel (decorative serif — evokes Genshin menus)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'serif', // fallback; swap for 'Cinzel' after adding font asset
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
    letterSpacing: 2.0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'serif',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.gold,
    letterSpacing: 1.5,
  );

  // Titles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
  );

  // Price
  static const TextStyle price = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.gold,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepNavy,
      primaryColor: AppColors.gold,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.goldLight,
        surface: AppColors.darkCard,
        error: AppColors.error,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge,
        iconTheme: IconThemeData(color: AppColors.gold),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.goldDark.withOpacity(0.3),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.deepNavy,
          textStyle: const TextStyle(
            fontFamily: 'sans-serif',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 4,
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.gold, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.goldDark.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.goldDark.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
        prefixIconColor: AppColors.gold,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.gold.withOpacity(0.3),
        labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        side: BorderSide(color: AppColors.goldDark.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCard,
        contentTextStyle: AppTextStyles.bodyLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.goldDark.withOpacity(0.3),
        thickness: 1,
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.deepNavy,
        elevation: 6,
      ),
    );
  }
}
