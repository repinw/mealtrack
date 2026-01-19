import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/presentation/widgets/summary_header.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('de')],
      home: Scaffold(body: child),
    );
  }

  group('SummaryHeader Tests', () {
    testWidgets('displays correct label and total value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const SummaryHeader(
            label: 'TEST LABEL',
            totalValue: 123.45,
            articleCount: 5,
          ),
        ),
      );

      expect(find.text('TEST LABEL'), findsOneWidget);
      // Depending on locale formatting, 123.45 should be 123,45 €
      expect(find.text('123,45 €'), findsOneWidget);
    });

    testWidgets('displays correct article count', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const SummaryHeader(
            label: 'LABEL',
            totalValue: 10.0,
            articleCount: 42,
          ),
        ),
      );

      // "42 Teile" as defined in app_de.arb for "items"
      expect(find.text('42 Teile'), findsOneWidget);
    });

    testWidgets('displays secondary info when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const SummaryHeader(
            label: 'LABEL',
            totalValue: 10.0,
            articleCount: 1,
            secondaryInfo: Text('SECONDARY'),
          ),
        ),
      );

      expect(find.text('SECONDARY'), findsOneWidget);
    });

    testWidgets('does not display secondary info when null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const SummaryHeader(
            label: 'LABEL',
            totalValue: 10.0,
            articleCount: 1,
            secondaryInfo: null,
          ),
        ),
      );

      // Check that there is only one Column in the right side (or rather, no 'SECONDARY' text)
      expect(find.text('SECONDARY'), findsNothing);
    });
  });
}
