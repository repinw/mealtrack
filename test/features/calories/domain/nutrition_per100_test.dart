import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';

void main() {
  group('NutritionPer100', () {
    test('zero constant is zero and non-negative', () {
      expect(NutritionPer100.zero.isZero, isTrue);
      expect(NutritionPer100.zero.hasNegativeValues, isFalse);
    });

    test('hasNegativeValues detects negatives in core and optional fields', () {
      const coreNegative = NutritionPer100(
        kcal: -1,
        protein: 1,
        carbs: 1,
        fat: 1,
        sugar: 1,
        salt: 1,
      );
      const optionalNegative = NutritionPer100(
        kcal: 1,
        protein: 1,
        carbs: 1,
        fat: 1,
        sugar: 1,
        salt: 1,
        saturatedFat: -0.1,
      );

      expect(coreNegative.hasNegativeValues, isTrue);
      expect(optionalNegative.hasNegativeValues, isTrue);
    });

    test('isZero is false when any value is non-zero', () {
      const value = NutritionPer100(
        kcal: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        sugar: 0,
        salt: 0,
        fiber: 0.2,
      );

      expect(value.isZero, isFalse);
    });

    test('copyWith updates values and supports clearing optional values', () {
      const base = NutritionPer100(
        kcal: 100,
        protein: 10,
        carbs: 20,
        fat: 5,
        sugar: 7,
        salt: 0.4,
        saturatedFat: 1,
        polyunsaturatedFat: 0.5,
        fiber: 3,
      );

      final updated = base.copyWith(kcal: 120, sugar: 8);
      expect(updated.kcal, 120);
      expect(updated.sugar, 8);
      expect(updated.saturatedFat, 1);

      final cleared = base.copyWith(
        clearSaturatedFat: true,
        clearPolyunsaturatedFat: true,
        clearFiber: true,
      );
      expect(cleared.saturatedFat, isNull);
      expect(cleared.polyunsaturatedFat, isNull);
      expect(cleared.fiber, isNull);
    });

    test('scaleForAmount scales all values including optional values', () {
      const per100 = NutritionPer100(
        kcal: 250,
        protein: 10,
        carbs: 20,
        fat: 5,
        sugar: 8,
        salt: 0.6,
        saturatedFat: 1,
        polyunsaturatedFat: 0.4,
        fiber: 2,
      );

      final totals = per100.scaleForAmount(150);

      expect(totals.kcal, 375);
      expect(totals.protein, 15);
      expect(totals.carbs, 30);
      expect(totals.fat, 7.5);
      expect(totals.sugar, 12);
      expect(totals.salt, closeTo(0.9, 0.000001));
      expect(totals.saturatedFat, 1.5);
      expect(totals.polyunsaturatedFat, closeTo(0.6, 0.000001));
      expect(totals.fiber, 3);
    });

    test('toJson omits null optional fields and fromJson restores values', () {
      const value = NutritionPer100(
        kcal: 123,
        protein: 7,
        carbs: 9,
        fat: 3,
        sugar: 4,
        salt: 0.5,
      );

      final json = value.toJson();
      expect(json.containsKey('saturatedFat'), isFalse);
      expect(json.containsKey('polyunsaturatedFat'), isFalse);
      expect(json.containsKey('fiber'), isFalse);

      final restored = NutritionPer100.fromJson(json);
      expect(restored.kcal, 123);
      expect(restored.protein, 7);
      expect(restored.carbs, 9);
      expect(restored.fat, 3);
      expect(restored.sugar, 4);
      expect(restored.salt, 0.5);
      expect(restored.saturatedFat, isNull);
    });

    test('fromJson parses comma decimals and blank optional values', () {
      final restored = NutritionPer100.fromJson({
        'kcal': '98,5',
        'protein': '7,2',
        'carbs': '15,3',
        'fat': '2,1',
        'sugar': '5,4',
        'salt': '0,8',
        'saturatedFat': '',
        'polyunsaturatedFat': '0,4',
        'fiber': null,
      });

      expect(restored.kcal, 98.5);
      expect(restored.protein, 7.2);
      expect(restored.carbs, 15.3);
      expect(restored.fat, 2.1);
      expect(restored.sugar, 5.4);
      expect(restored.salt, 0.8);
      expect(restored.saturatedFat, isNull);
      expect(restored.polyunsaturatedFat, 0.4);
      expect(restored.fiber, isNull);
    });
  });

  group('NutritionTotals', () {
    test('zero constant and toJson', () {
      expect(NutritionTotals.zero.kcal, 0);
      final json = NutritionTotals.zero.toJson();
      expect(json['sugar'], 0);
      expect(json.containsKey('fiber'), isFalse);
    });
  });
}
