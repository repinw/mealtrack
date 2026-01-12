import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0B1426);
  static const Color secondaryColor = Color(0xFF1E2A3B);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color scaffoldBackgroundColor = Color(0xFFF5F5F5);
  static const Color actionButtonColor = Color(0xFF0B1426);
  static const Color white = Colors.white;
  static const Color error = Colors.redAccent;

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: error,
        surface: white,
        onPrimary: white,
        onSecondary: white,
        onSurface: Colors.black87,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: accentColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: actionButtonColor,
          foregroundColor: white,
          elevation: 2,
          shadowColor: actionButtonColor.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
