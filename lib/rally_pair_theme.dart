import 'package:flutter/material.dart';

abstract final class RallyPairColors {
  static const background = Color(0xFFEDF4FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFDDEAF2);
  static const textPrimary = Color(0xFF102A43);
  static const textSecondary = Color(0xFF526B7B);
  static const primary = Color(0xFF2563D9);
  static const accent = Color(0xFF3BBF75);
  static const court = Color(0xFF2E9376);
  static const courtLine = Color(0xFFF8FFFC);
  static const danger = Color(0xFFC23E55);
  static const outline = Color(0xFFC5D6E0);
}

abstract final class RallyPairTheme {
  static ThemeData get light {
    const colors = ColorScheme.light(
      primary: RallyPairColors.primary,
      onPrimary: Colors.white,
      secondary: RallyPairColors.accent,
      onSecondary: RallyPairColors.textPrimary,
      surface: RallyPairColors.surface,
      onSurface: RallyPairColors.textPrimary,
      error: RallyPairColors.danger,
      onError: Colors.white,
      outline: RallyPairColors.outline,
      shadow: Color(0x1A102A43),
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colors,
      scaffoldBackgroundColor: RallyPairColors.background,
    );
    final text = base.textTheme.apply(
      bodyColor: RallyPairColors.textPrimary,
      displayColor: RallyPairColors.textPrimary,
    );

    return base.copyWith(
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(
          fontSize: 28,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleLarge: text.titleLarge?.copyWith(
          fontSize: 22,
          height: 1.25,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: text.titleMedium?.copyWith(
          fontSize: 16,
          height: 1.35,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: text.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
        bodyMedium: text.bodyMedium?.copyWith(fontSize: 14, height: 1.45),
        labelLarge: text.labelLarge?.copyWith(
          fontSize: 15,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: RallyPairColors.background,
        foregroundColor: RallyPairColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: RallyPairColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: RallyPairColors.outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: RallyPairColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RallyPairColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: RallyPairColors.textSecondary),
        hintStyle: const TextStyle(color: RallyPairColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: RallyPairColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: RallyPairColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: RallyPairColors.primary,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: RallyPairColors.danger),
        ),
      ),
      dividerColor: RallyPairColors.outline,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: RallyPairColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
