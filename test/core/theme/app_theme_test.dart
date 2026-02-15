import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('lightTheme returns a valid Material 3 ThemeData', () {
      final theme = AppTheme.lightTheme;

      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
    });

    test('darkTheme returns a valid Material 3 ThemeData', () {
      final theme = AppTheme.darkTheme;

      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
    });

    test('seedColor is correct', () {
      expect(AppTheme.seedColor, const Color(0xFF090668));
    });

    test('lightTheme colorScheme is generated from seed', () {
      final theme = AppTheme.lightTheme;
      final expected = ColorScheme.fromSeed(
        seedColor: AppTheme.seedColor,
        brightness: Brightness.light,
      );

      expect(theme.colorScheme.primary, expected.primary);
      expect(theme.colorScheme.secondary, expected.secondary);
      expect(theme.colorScheme.surface, expected.surface);
    });

    test('darkTheme colorScheme is generated from seed', () {
      final theme = AppTheme.darkTheme;
      final expected = ColorScheme.fromSeed(
        seedColor: AppTheme.seedColor,
        brightness: Brightness.dark,
      );

      expect(theme.colorScheme.primary, expected.primary);
      expect(theme.colorScheme.secondary, expected.secondary);
      expect(theme.colorScheme.surface, expected.surface);
    });

    test('themes keep AppBar colors at Material defaults', () {
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;

      expect(lightTheme.appBarTheme.backgroundColor, isNull);
      expect(lightTheme.appBarTheme.foregroundColor, isNull);
      expect(darkTheme.appBarTheme.backgroundColor, isNull);
      expect(darkTheme.appBarTheme.foregroundColor, isNull);
    });

    test('seed-specific theme builders generate different palettes', () {
      final first = AppTheme.lightThemeFromSeed(const Color(0xFF6750A4));
      final second = AppTheme.lightThemeFromSeed(const Color(0xFF00639B));

      expect(
        first.colorScheme.primary,
        isNot(equals(second.colorScheme.primary)),
      );
      expect(
        first.colorScheme.secondary,
        isNot(equals(second.colorScheme.secondary)),
      );
    });

    test('theme alias points to lightTheme', () {
      final theme = AppTheme.theme;
      final lightTheme = AppTheme.lightTheme;

      expect(theme.brightness, lightTheme.brightness);
      expect(theme.colorScheme.primary, lightTheme.colorScheme.primary);
      expect(theme.colorScheme.surface, lightTheme.colorScheme.surface);
    });
  });
}
