import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color defaultSeedColor = Color.fromARGB(255, 9, 6, 104);
  static const Color seedColor = defaultSeedColor;

  static ThemeData get theme => lightTheme;
  static ThemeData get lightTheme =>
      _buildTheme(brightness: Brightness.light, seedColor: seedColor);
  static ThemeData get darkTheme =>
      _buildTheme(brightness: Brightness.dark, seedColor: seedColor);

  static ThemeData lightThemeFromSeed(Color seedColor) =>
      _buildTheme(brightness: Brightness.light, seedColor: seedColor);
  static ThemeData darkThemeFromSeed(Color seedColor) =>
      _buildTheme(brightness: Brightness.dark, seedColor: seedColor);

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color seedColor,
  }) {
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
    );
  }
}
