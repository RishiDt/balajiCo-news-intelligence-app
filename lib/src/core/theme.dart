// App theme definitions and helpers

import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0A63A8);
  static const accent = Color(0xFFFFC857);
  static const scaffold = Color(0xFFF7F9FB);
  static const surface = Colors.white;
  static const error = Color(0xFFB00020);
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.scaffold,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14.0),
      titleMedium: TextStyle(fontSize: 16.0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
  );
}
