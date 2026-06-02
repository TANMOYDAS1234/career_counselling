import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Builds the app [ThemeData]. Body text uses Inter, headings use Poppins —
/// matching the web app's font stack. Noto Sans Devanagari/Bengali fall back
/// automatically through google_fonts when Hindi/Bengali glyphs are rendered.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.neutral50,
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary600,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary600,
      secondary: AppColors.secondary600,
      tertiary: AppColors.accent500,
      surface: AppColors.white,
      error: AppColors.destructive,
    );

    // Inter for body, Poppins for display/headline/title.
    final interTheme = GoogleFonts.interTextTheme(base.textTheme);
    final textTheme = interTheme.copyWith(
      displayLarge: GoogleFonts.poppins(textStyle: interTheme.displayLarge, fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.poppins(textStyle: interTheme.displayMedium, fontWeight: FontWeight.w700),
      displaySmall: GoogleFonts.poppins(textStyle: interTheme.displaySmall, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.poppins(textStyle: interTheme.headlineLarge, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.poppins(textStyle: interTheme.headlineMedium, fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.poppins(textStyle: interTheme.headlineSmall, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.poppins(textStyle: interTheme.titleLarge, fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.poppins(textStyle: interTheme.titleMedium, fontWeight: FontWeight.w600),
    ).apply(
      bodyColor: AppColors.neutral900,
      displayColor: AppColors.neutral900,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.neutral200),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.neutral400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary500, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.destructive),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.neutral200, thickness: 1),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary600,
          side: const BorderSide(color: AppColors.primary600),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary600),
      ),
    );
  }
}
