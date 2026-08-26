import 'package:flutter/material.dart';

class ZfRallyPairColors {
  const ZfRallyPairColors._();

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
}

class ZfRallyPairTheme {
  const ZfRallyPairTheme._();

  static ThemeData get light {
    const colors = ColorScheme.light(
      primary: ZfRallyPairColors.primary,
      onPrimary: Colors.white,
      secondary: ZfRallyPairColors.accent,
      onSecondary: ZfRallyPairColors.textPrimary,
      error: ZfRallyPairColors.danger,
      onError: Colors.white,
      surface: ZfRallyPairColors.surface,
      onSurface: ZfRallyPairColors.textPrimary,
    );

    final textTheme = Typography.material2021().black.apply(
      bodyColor: ZfRallyPairColors.textPrimary,
      displayColor: ZfRallyPairColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: ZfRallyPairColors.background,
      textTheme: textTheme.copyWith(
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZfRallyPairColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZfRallyPairColors.surfaceSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZfRallyPairColors.surfaceSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: ZfRallyPairColors.primary,
            width: 1.6,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
