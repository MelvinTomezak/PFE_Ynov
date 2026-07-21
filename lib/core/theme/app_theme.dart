import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Thème sombre « Néon » bleu de STYMA (fond noir).
class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Color(0xFF04121C),
      secondary: AppColors.secondary,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme,
      textTheme: _textTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        titleTextStyle: GoogleFonts.unbounded(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: 1,
          shadows: const [
            Shadow(color: Color(0xCC38BDF8), blurRadius: 16),
            Shadow(color: Color(0x6638BDF8), blurRadius: 32),
          ],
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: const Color(0xFF04121C),
          shadowColor: AppColors.primary,
          elevation: 12,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primaryLight),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AppColors.primary),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceAlt,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      headlineMedium: GoogleFonts.unbounded(
          fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      titleLarge: GoogleFonts.unbounded(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleMedium: GoogleFonts.unbounded(
          fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.inter(
          fontSize: 15, color: AppColors.textPrimary, height: 1.5),
      bodyMedium: GoogleFonts.inter(
          fontSize: 14, color: AppColors.textSecondary, height: 1.4),
      labelLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
    );
  }
}
