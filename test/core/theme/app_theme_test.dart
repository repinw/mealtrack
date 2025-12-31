import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('theme returns a valid ThemeData', () {
      final theme = AppTheme.theme;

      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
    });

    test('primaryColor is correct', () {
      expect(AppTheme.primaryColor, const Color(0xFF0B1426));
    });

    test('secondaryColor is correct', () {
      expect(AppTheme.secondaryColor, const Color(0xFF1E2A3B));
    });

    test('accentColor is correct', () {
      expect(AppTheme.accentColor, const Color(0xFF4CAF50));
    });

    test('white is Colors.white', () {
      expect(AppTheme.white, Colors.white);
    });

    test('error is Colors.redAccent', () {
      expect(AppTheme.error, Colors.redAccent);
    });

    test('theme colorScheme has correct primary color', () {
      final theme = AppTheme.theme;

      expect(theme.colorScheme.primary, AppTheme.primaryColor);
      expect(theme.colorScheme.secondary, AppTheme.secondaryColor);
    });

    test('theme scaffoldBackgroundColor is correct', () {
      final theme = AppTheme.theme;

      expect(theme.scaffoldBackgroundColor, AppTheme.scaffoldBackgroundColor);
    });

    test('theme appBarTheme has correct backgroundColor', () {
      final theme = AppTheme.theme;

      expect(theme.appBarTheme.backgroundColor, AppTheme.primaryColor);
      expect(theme.appBarTheme.foregroundColor, AppTheme.white);
    });

    test('elevatedButtonTheme has correct style', () {
      final theme = AppTheme.theme;
      final buttonStyle = theme.elevatedButtonTheme.style;

      expect(buttonStyle, isNotNull);
    });
  });
}
