import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

void main() {
  testWidgets('AppLocalizations.of(context) returns correct German strings', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Builder(
          builder: (context) {
            // Verify access to localizations
            final l10n = AppLocalizations.of(context);
            if (l10n == null) {
              return const Text('L10n not found');
            }
            return Column(
              children: [
                Text(l10n.loading), // Should be 'Lädt...'
                Text(
                  l10n.welcomeTitle,
                ), // Should be 'Willkommen bei MealTrack!'
              ],
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify 'L10n not found' is NOT present
    expect(find.text('L10n not found'), findsNothing);

    // Verify expected German strings are present
    expect(find.text('Lädt...'), findsOneWidget);
    expect(find.text('Willkommen bei MealTrack!'), findsOneWidget);
  });
}
