import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/domain/calorie_entry.dart';
import 'package:mealtrack/features/calories/domain/meal_type.dart';
import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';
import 'package:mealtrack/features/calories/provider/calorie_log_provider.dart';

void main() {
  group('CalorieDaySelection', () {
    test('normalizes and navigates days', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(calorieDaySelection.notifier);
      notifier.setDay(DateTime(2026, 2, 13, 18, 45));
      expect(container.read(calorieDaySelection), DateTime(2026, 2, 13));

      notifier.nextDay();
      expect(container.read(calorieDaySelection), DateTime(2026, 2, 14));

      notifier.previousDay();
      expect(container.read(calorieDaySelection), DateTime(2026, 2, 13));
    });
  });

  group('calorieEntriesByMeal + calorieDaySummary', () {
    test('groups by meal and sums totals', () {
      final entries = <CalorieEntry>[
        _entry(
          id: 'b-1',
          mealType: MealType.breakfast,
          consumedAmount: 100,
          per100: const NutritionPer100(
            kcal: 100,
            protein: 10,
            carbs: 5,
            fat: 1,
            sugar: 2,
            salt: 0.1,
            saturatedFat: null,
            polyunsaturatedFat: null,
            fiber: null,
          ),
        ),
        _entry(
          id: 'l-1',
          mealType: MealType.lunch,
          consumedAmount: 200,
          per100: const NutritionPer100(
            kcal: 150,
            protein: 8,
            carbs: 12,
            fat: 6,
            sugar: 3,
            salt: 0.4,
            saturatedFat: null,
            polyunsaturatedFat: null,
            fiber: null,
          ),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          calorieEntriesForSelectedDay.overrideWithValue(
            AsyncValue.data(entries),
          ),
        ],
      );
      addTearDown(container.dispose);

      final grouped = container.read(calorieEntriesByMeal);
      expect(grouped[MealType.breakfast], hasLength(1));
      expect(grouped[MealType.lunch], hasLength(1));
      expect(grouped[MealType.dinner], isEmpty);
      expect(grouped[MealType.snack], isEmpty);

      final summary = container.read(calorieDaySummary);
      expect(summary.entryCount, 2);
      expect(summary.totalKcal, closeTo(400, 0.001));
      expect(summary.totalProtein, closeTo(26, 0.001));
      expect(summary.totalCarbs, closeTo(29, 0.001));
      expect(summary.totalFat, closeTo(13, 0.001));
    });

    test('returns empty summary when entries are unavailable', () {
      final container = ProviderContainer(
        overrides: [
          calorieEntriesForSelectedDay.overrideWithValue(
            const AsyncValue.loading(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final summary = container.read(calorieDaySummary);
      expect(summary.totalKcal, 0);
      expect(summary.totalProtein, 0);
      expect(summary.totalCarbs, 0);
      expect(summary.totalFat, 0);
      expect(summary.entryCount, 0);
    });
  });
}

CalorieEntry _entry({
  required String id,
  required MealType mealType,
  required double consumedAmount,
  required NutritionPer100 per100,
}) {
  final now = DateTime(2026, 2, 13, 12, 0);
  return CalorieEntry.create(
    id: id,
    userId: 'user-1',
    productName: 'Product $id',
    source: CalorieEntrySource.manual,
    mealType: mealType,
    consumedAmount: consumedAmount,
    consumedUnit: ConsumedUnit.grams,
    per100: per100,
    loggedAt: now,
    createdAt: now,
    updatedAt: now,
  );
}
