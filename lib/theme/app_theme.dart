import 'package:flutter/material.dart';

abstract final class AppColors {
  static const turquoise = Color(0xFF00A896);
  static const darkTurquoise = Color(0xFF007A6E);
  static const lightTurquoise = Color(0xFFDDF7F3);
  static const selectedWord = Color(0xFFFFF2A8);
  static const blackCell = Color(0xFF657174);
  static const background = Color(0xFFF4FAF9);
  static const ink = Color(0xFF173836);
}

abstract final class AppTheme {
  static ThemeData get data {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.turquoise,
        primary: AppColors.turquoise,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.turquoise,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
        ),
        bodyMedium: TextStyle(color: AppColors.ink),
      ),
    );
  }
}
