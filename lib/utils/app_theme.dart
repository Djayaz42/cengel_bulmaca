// lib/utils/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Ana renkler - turkuaz tema (ikinci resimden)
  static const primary = Color(0xFF00A896);
  static const primaryDark = Color(0xFF007A6E);
  static const primaryLight = Color(0xFFB2EDE8);

  // Hücre renkleri
  static const questionCell = Color(0xFF00A896);
  static const questionCellText = Colors.white;
  static const answerCell = Colors.white;
  static const answerCellText = Color(0xFF1A1A2E);
  static const blackCell = Color(0xFF1A1A2E);
  static const selectedWordCell = Color(0xFFFFF3B0);
  static const selectedCell = Color(0xFF007A6E);
  static const correctCell = Color(0xFFE8F5E9);
  static const correctCellText = Color(0xFF2E7D32);

  // UI renkleri
  static const background = Color(0xFFF5FAFA);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFDDE8E7);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
