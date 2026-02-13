import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/data/calorie_log_repository.dart';
import 'package:mealtrack/features/calories/domain/calorie_entry.dart';
import 'package:mealtrack/features/calories/domain/calorie_goal_settings.dart';
import 'package:mealtrack/features/calories/domain/meal_type.dart';
import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';
import 'package:mealtrack/features/calories/provider/calorie_log_provider.dart';
import 'package:mealtrack/features/calories/provider/calorie_settings_provider.dart';
import 'package:mealtrack/features/calories/presentation/calories_page.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/l10n/app_localizations_de.dart';

void main() {
  group('CaloriesPage', () {
    testWidgets('renders summary with kcal progress and today label', (
      tester,
    ) async {
      final now = DateTime.now();
      final entries = [_entry(id: 'entry-1', mealType: MealType.breakfast)];

      await tester.pumpWidget(
        _buildSubject(
          entries: entries,
          goalProgress: CalorieGoalProgress(
            settings: CalorieGoalSettings(
              dailyKcalGoal: 2000,
              goalSource: CalorieGoalSource.manual,
              updatedAt: now,
            ),
            consumedKcal: 250,
            remainingKcal: 1750,
            progress01: 0.125,
          ),
          logMutations: _SpyCalorieLogMutations(),
        ),
      );
      await tester.pump();

      final l10n = AppLocalizationsDe();
      expect(find.text(l10n.caloriesToday), findsWidgets);
      expect(find.textContaining('/ 2000 ${l10n.calories}'), findsWidgets);
    });

    testWidgets('expands meal section and shows meal entry details', (
      tester,
    ) async {
      final entry = _entry(id: 'entry-2', mealType: MealType.breakfast);

      await tester.pumpWidget(
        _buildSubject(
          entries: [entry],
          goalProgress: _goalWithoutTarget(),
          logMutations: _SpyCalorieLogMutations(),
        ),
      );
      await tester.pump();

      final l10n = AppLocalizationsDe();
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

      await tester.tap(find.text(l10n.caloriesMealBreakfast));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
      expect(find.text(entry.productName), findsOneWidget);
      expect(find.textContaining(l10n.caloriesProtein), findsOneWidget);
      expect(find.textContaining(l10n.caloriesCarbs), findsOneWidget);
      expect(find.textContaining(l10n.caloriesFat), findsOneWidget);
    });

    testWidgets('deletes entry after confirmation dialog', (tester) async {
      final entry = _entry(id: 'entry-3', mealType: MealType.breakfast);
      final logMutations = _SpyCalorieLogMutations();
      final l10n = AppLocalizationsDe();

      await tester.pumpWidget(
        _buildSubject(
          entries: [entry],
          goalProgress: _goalWithoutTarget(),
          logMutations: logMutations,
        ),
      );
      await tester.pump();

      await tester.tap(find.text(l10n.caloriesMealBreakfast));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text(l10n.deleteItemConfirmation), findsOneWidget);

      final dialogDeleteButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextButton, l10n.delete),
      );
      await tester.tap(dialogDeleteButton);
      await tester.pumpAndSettle();

      expect(logMutations.deletedEntryId, entry.id);
    });
  });
}

Widget _buildSubject({
  required List<CalorieEntry> entries,
  required CalorieGoalProgress goalProgress,
  required _SpyCalorieLogMutations logMutations,
}) {
  return ProviderScope(
    overrides: [
      calorieEntriesForSelectedDay.overrideWith((ref) => Stream.value(entries)),
      calorieGoalProgress.overrideWithValue(goalProgress),
      calorieLogMutations.overrideWithValue(logMutations),
    ],
    child: const MaterialApp(
      locale: Locale('de'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CaloriesPage(),
    ),
  );
}

CalorieGoalProgress _goalWithoutTarget() {
  return CalorieGoalProgress(
    settings: CalorieGoalSettings.empty(),
    consumedKcal: 0,
    remainingKcal: null,
    progress01: null,
  );
}

CalorieEntry _entry({required String id, required MealType mealType}) {
  final now = DateTime(2026, 2, 13, 12, 0);
  return CalorieEntry.create(
    id: id,
    userId: 'user-1',
    productName: 'Skyr Natur',
    brand: 'Test Brand',
    source: CalorieEntrySource.manual,
    mealType: mealType,
    consumedAmount: 250,
    consumedUnit: ConsumedUnit.grams,
    per100: const NutritionPer100(
      kcal: 100,
      protein: 10,
      carbs: 5,
      fat: 1,
      sugar: 4,
      salt: 0.1,
      saturatedFat: 0.2,
      polyunsaturatedFat: 0.1,
      fiber: 0,
    ),
    loggedAt: now,
    createdAt: now,
    updatedAt: now,
  );
}

class _SpyCalorieLogMutations extends CalorieLogMutations {
  _SpyCalorieLogMutations()
    : super(
        CalorieLogRepository(
          firestore: FakeFirebaseFirestore(),
          uid: 'test-user',
        ),
      );

  String? deletedEntryId;

  @override
  Future<void> delete(String entryId) async {
    deletedEntryId = entryId;
  }
}
