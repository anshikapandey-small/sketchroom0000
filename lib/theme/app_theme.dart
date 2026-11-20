import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Text styles from the Figma "Typography" section (font: Inter).
class AppText {
  static final display = GoogleFonts.inter(
      fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.2);
  static final h1 = GoogleFonts.inter(
      fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.ink);
  static final h2 = GoogleFonts.inter(
      fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink);
  static final body = GoogleFonts.inter(
      fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.ink);
  static final label = GoogleFonts.inter(
      fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink);
  static final caption = GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.muted);
}

class AppTheme {
  static const double pagePadding = 24; // screens use 24px side padding
  static const double radius = 10;

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.bg,
        error: AppColors.danger,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: base.textTheme
    .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}
