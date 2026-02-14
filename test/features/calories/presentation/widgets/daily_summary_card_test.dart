import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/presentation/widgets/daily_summary_card.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/l10n/app_localizations_de.dart';

void main() {
  group('DailySummaryCard', () {
    testWidgets('shows today label and macro values', (tester) async {
      final l10n = AppLocalizationsDe();

      await tester.pumpWidget(
        _host(
          child: DailySummaryCard(
            date: DateTime.now(),
            totalKcal: 1234,
            proteinGrams: 88.5,
            carbsGrams: 140,
            fatGrams: 54.2,
          ),
        ),
      );

      expect(find.text(l10n.caloriesToday), findsOneWidget);
      expect(find.text('1234'), findsOneWidget);
      expect(find.text(l10n.calories), findsWidgets);
      expect(find.text(l10n.caloriesProtein), findsOneWidget);
      expect(find.text(l10n.caloriesCarbs), findsOneWidget);
      expect(find.text(l10n.caloriesFat), findsOneWidget);
      expect(find.text('88.5 g'), findsOneWidget);
      expect(find.text('140 g'), findsOneWidget);
      expect(find.text('54.2 g'), findsOneWidget);
    });

    testWidgets('shows formatted date label for non-today dates', (
      tester,
    ) async {
      final l10n = AppLocalizationsDe();

      await tester.pumpWidget(
        _host(
          child: DailySummaryCard(
            date: DateTime(2020, 1, 10),
            totalKcal: 500,
            proteinGrams: 20,
            carbsGrams: 50,
            fatGrams: 10,
          ),
        ),
      );

      expect(find.text(l10n.caloriesToday), findsNothing);
      expect(find.text('500'), findsOneWidget);
      expect(find.text('20 g'), findsOneWidget);
      expect(find.text('50 g'), findsOneWidget);
      expect(find.text('10 g'), findsOneWidget);
    });
  });
}

Widget _host({required Widget child}) {
  return MaterialApp(
    locale: const Locale('de'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
