import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/domain/calorie_entry.dart';
import 'package:mealtrack/features/calories/domain/meal_type.dart';
import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';

void main() {
  group('CalorieEntry enums', () {
    test('CalorieEntrySource value mapping', () {
      expect(CalorieEntrySource.manual.value, 'manual');
      expect(
        CalorieEntrySource.fromValue('off_barcode'),
        CalorieEntrySource.offBarcode,
      );
      expect(
        CalorieEntrySource.fromValue('ocr_label'),
        CalorieEntrySource.ocrLabel,
      );
      expect(
        CalorieEntrySource.fromValue('unknown'),
        CalorieEntrySource.manual,
      );
    });

    test('ConsumedUnit value mapping', () {
      expect(ConsumedUnit.grams.value, 'g');
      expect(ConsumedUnit.milliliters.value, 'ml');
      expect(ConsumedUnit.fromValue('ml'), ConsumedUnit.milliliters);
      expect(ConsumedUnit.fromValue('x'), ConsumedUnit.grams);
    });
  });

  group('CalorieEntry', () {
    test('create computes totals from per100 and amount', () {
      final entry = CalorieEntry.create(
        id: 'id-1',
        userId: 'user-1',
        productName: 'Skyr',
        source: CalorieEntrySource.manual,
        mealType: MealType.breakfast,
        consumedAmount: 250,
        consumedUnit: ConsumedUnit.grams,
        per100: const NutritionPer100(
          kcal: 100,
          protein: 10,
          carbs: 5,
          fat: 2,
          sugar: 4,
          salt: 0.2,
          saturatedFat: 0.3,
          polyunsaturatedFat: 0.1,
          fiber: 1.5,
        ),
        loggedAt: DateTime(2026, 2, 13, 8, 0),
        createdAt: DateTime(2026, 2, 13, 8, 0),
        updatedAt: DateTime(2026, 2, 13, 8, 0),
      );

      expect(entry.totalKcal, 250);
      expect(entry.totalProtein, 25);
      expect(entry.totalCarbs, 12.5);
      expect(entry.totalFat, 5);
      expect(entry.isValid, isTrue);
    });

    test('recalculateTotals updates total values', () {
      final entry = CalorieEntry.create(
        id: 'id-2',
        userId: 'user-1',
        productName: 'Bread',
        source: CalorieEntrySource.manual,
        mealType: MealType.lunch,
        consumedAmount: 100,
        consumedUnit: ConsumedUnit.grams,
        per100: const NutritionPer100(
          kcal: 250,
          protein: 8,
          carbs: 40,
          fat: 4,
          sugar: 3,
          salt: 1.2,
          saturatedFat: null,
          polyunsaturatedFat: null,
          fiber: null,
        ),
      );

      final changed = entry
          .copyWith(consumedAmount: 60)
          .recalculateTotals(updatedAt: DateTime(2026, 2, 13, 12, 0));

      expect(changed.totalKcal, 150);
      expect(changed.totalProtein, 4.8);
      expect(changed.totalCarbs, 24);
      expect(changed.totalFat, 2.4);
      expect(changed.updatedAt, DateTime(2026, 2, 13, 12, 0));
    });

    test('isValid is false for invalid payload', () {
      final invalid = CalorieEntry.create(
        id: 'id-3',
        userId: ' ',
        productName: ' ',
        source: CalorieEntrySource.manual,
        mealType: MealType.snack,
        consumedAmount: 0,
        consumedUnit: ConsumedUnit.grams,
        per100: const NutritionPer100(
          kcal: -1,
          protein: 1,
          carbs: 1,
          fat: 1,
          sugar: 1,
          salt: 1,
          saturatedFat: null,
          polyunsaturatedFat: null,
          fiber: null,
        ),
      );

      expect(invalid.isValid, isFalse);
    });

    test('toJson and fromJson roundtrip', () {
      final source = CalorieEntry.create(
        id: 'id-4',
        userId: 'user-1',
        productName: 'Milk',
        brand: 'Brand A',
        barcode: '4001724819806',
        offProductRef: 'off:4001724819806',
        source: CalorieEntrySource.offBarcode,
        mealType: MealType.dinner,
        consumedAmount: 333,
        consumedUnit: ConsumedUnit.milliliters,
        per100: const NutritionPer100(
          kcal: 64,
          protein: 3.3,
          carbs: 4.8,
          fat: 3.5,
          sugar: 4.8,
          salt: 0.12,
          saturatedFat: 2.3,
          polyunsaturatedFat: 0.2,
          fiber: 0,
        ),
        loggedAt: DateTime(2026, 2, 13, 19, 10),
        createdAt: DateTime(2026, 2, 13, 19, 11),
        updatedAt: DateTime(2026, 2, 13, 19, 12),
      );

      final json = source.toJson();
      final restored = CalorieEntry.fromJson(json);

      expect(restored.id, source.id);
      expect(restored.userId, source.userId);
      expect(restored.productName, source.productName);
      expect(restored.brand, source.brand);
      expect(restored.barcode, source.barcode);
      expect(restored.offProductRef, source.offProductRef);
      expect(restored.source, source.source);
      expect(restored.mealType, source.mealType);
      expect(restored.consumedAmount, source.consumedAmount);
      expect(restored.consumedUnit, source.consumedUnit);
      expect(restored.per100.sugar, source.per100.sugar);
      expect(restored.totalKcal, source.totalKcal);
      expect(restored.loggedAt, source.loggedAt);
      expect(restored.createdAt, source.createdAt);
      expect(restored.updatedAt, source.updatedAt);
    });

    test(
      'fromJson falls back for unknown mealType and parses numeric strings',
      () {
        final restored = CalorieEntry.fromJson({
          'id': 'id-5',
          'userId': 'user-1',
          'productName': 'Fallback',
          'source': 'manual',
          'mealType': 'unknown',
          'consumedAmount': '120,5',
          'consumedUnit': 'ml',
          'per100': {
            'kcal': '200',
            'protein': '10,2',
            'carbs': '20,5',
            'fat': '5,1',
            'sugar': '7,5',
            'salt': '0,6',
          },
          'totalKcal': '241',
          'totalProtein': '12,3',
          'totalCarbs': '24,7',
          'totalFat': '6,1',
          'loggedAt': '2026-02-13T10:00:00.000',
          'createdAt': '2026-02-13T10:00:01.000',
          'updatedAt': '2026-02-13T10:00:02.000',
        });

        expect(restored.mealType, MealType.snack);
        expect(restored.consumedUnit, ConsumedUnit.milliliters);
        expect(restored.consumedAmount, 120.5);
        expect(restored.per100.protein, 10.2);
        expect(restored.per100.sugar, 7.5);
      },
    );
  });
}
