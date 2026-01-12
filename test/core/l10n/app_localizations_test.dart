import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/l10n/app_localizations_de.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() {
    l10n = AppLocalizationsDe();
  });

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
            final contextL10n = AppLocalizations.of(context);
            if (contextL10n == null) {
              return const Text('L10n not found');
            }
            return Column(
              children: [
                Text(contextL10n.loading),
                Text(contextL10n.welcomeTitle)
              ],
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('L10n not found'), findsNothing);

    expect(find.text(l10n.loading), findsOneWidget);
    expect(find.text(l10n.welcomeTitle), findsOneWidget);
  });

  testWidgets('AppLocalizations returns correct HomeMenu localization keys', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Builder(
          builder: (context) {
            final contextL10n = AppLocalizations.of(context);
            if (contextL10n == null) {
              return const Text('L10n not found');
            }
            return Column(
              children: [
                Text(contextL10n.calories),
                Text(contextL10n.statistics),
                Text(contextL10n.featureInProgress),
                Text(contextL10n.addItemNotImplemented),
              ],
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(l10n.calories), findsOneWidget);
    expect(find.text(l10n.statistics), findsOneWidget);
    expect(find.text(l10n.featureInProgress), findsOneWidget);
    expect(find.text(l10n.addItemNotImplemented), findsOneWidget);
  });
}
