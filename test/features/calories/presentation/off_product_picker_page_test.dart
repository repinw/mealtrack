import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';
import 'package:mealtrack/features/calories/domain/off_product_candidate.dart';
import 'package:mealtrack/features/calories/presentation/off_product_picker_page.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/l10n/app_localizations_de.dart';

void main() {
  group('OffProductPickerPage', () {
    testWidgets('renders sugar and salt chips for candidates', (tester) async {
      final l10n = AppLocalizationsDe();
      final candidate = _candidate(
        code: '4001724819806',
        name: 'Skyr Natur',
        kcal: 63,
        fat: 0.2,
        carbs: 3.8,
        sugar: 3.8,
        protein: 11,
        salt: 0.12,
      );

      await tester.pumpWidget(
        _buildTestApp(
          child: OffProductPickerPage(
            barcode: candidate.code,
            candidates: [candidate],
          ),
        ),
      );

      expect(find.textContaining(l10n.caloriesSugar), findsOneWidget);
      expect(find.textContaining(l10n.caloriesSalt), findsOneWidget);
      expect(find.textContaining(l10n.caloriesEnergy), findsOneWidget);
    });

    testWidgets('returns selected candidate when proceeding', (tester) async {
      final l10n = AppLocalizationsDe();
      final candidateA = _candidate(
        code: '111',
        name: 'Magerquark',
        kcal: 67,
        fat: 0.3,
        carbs: 4.1,
        sugar: 4.1,
        protein: 12,
        salt: 0.1,
      );
      final candidateB = _candidate(
        code: '222',
        name: 'Vollkornbrot',
        kcal: 225,
        fat: 2.6,
        carbs: 38,
        sugar: 4.5,
        protein: 8.3,
        salt: 1.1,
      );

      OffProductCandidate? selected;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      selected = await OffProductPickerPage.open(
                        context,
                        barcode: '222',
                        candidates: [candidateA, candidateB],
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vollkornbrot'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, l10n.proceed));
      await tester.pumpAndSettle();

      expect(selected, same(candidateB));
    });

    testWidgets('disables proceed when there are no candidates', (
      tester,
    ) async {
      final l10n = AppLocalizationsDe();

      await tester.pumpWidget(
        _buildTestApp(
          child: const OffProductPickerPage(barcode: '123', candidates: []),
        ),
      );

      expect(find.text(l10n.noAvailableProducts), findsOneWidget);
      final proceedButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, l10n.proceed),
      );
      expect(proceedButton.onPressed, isNull);
    });
  });
}

Widget _buildTestApp({required Widget child}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('de'),
    home: child,
  );
}

OffProductCandidate _candidate({
  required String code,
  required String name,
  required double kcal,
  required double fat,
  required double carbs,
  required double sugar,
  required double protein,
  required double salt,
}) {
  return OffProductCandidate(
    code: code,
    name: name,
    brand: 'Test Brand',
    quantityLabel: '100 g',
    servingSizeLabel: '50 g',
    imageUrl: null,
    per100: NutritionPer100(
      kcal: kcal,
      protein: protein,
      carbs: carbs,
      fat: fat,
      sugar: sugar,
      salt: salt,
      saturatedFat: null,
      polyunsaturatedFat: null,
      fiber: null,
    ),
    hasKcal: true,
    hasProtein: true,
    hasCarbs: true,
    hasFat: true,
    hasSugar: true,
    hasSalt: true,
    hasSaturatedFat: false,
    hasPolyunsaturatedFat: false,
    hasFiber: false,
    completenessScore: 1,
  );
}
