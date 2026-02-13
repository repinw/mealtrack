import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';
import 'package:mealtrack/features/calories/domain/off_product_candidate.dart';

void main() {
  group('OffProductCandidate.fromOffJson', () {
    test('parses full core nutrition including sugar and salt', () {
      final candidate = OffProductCandidate.fromOffJson({
        'code': '4001724819806',
        'product_name': 'Skyr Natur',
        'brands': 'Example Brand',
        'quantity': '500 g',
        'serving_size': '150 g',
        'nutriments': {
          'energy-kcal_100g': 63,
          'proteins_100g': 11,
          'carbohydrates_100g': 3.8,
          'fat_100g': 0.2,
          'sugars_100g': 3.8,
          'salt_100g': 0.12,
          'saturated-fat_100g': 0.1,
          'polyunsaturated-fat_100g': 0.0,
          'fiber_100g': 0.0,
        },
      });

      expect(candidate.code, '4001724819806');
      expect(candidate.name, 'Skyr Natur');
      expect(candidate.brand, 'Example Brand');
      expect(candidate.quantityLabel, '500 g');
      expect(candidate.servingSizeLabel, '150 g');

      expect(candidate.hasKcal, isTrue);
      expect(candidate.hasProtein, isTrue);
      expect(candidate.hasCarbs, isTrue);
      expect(candidate.hasFat, isTrue);
      expect(candidate.hasSugar, isTrue);
      expect(candidate.hasSalt, isTrue);
      expect(candidate.hasCompleteCoreNutrition, isTrue);
      expect(candidate.hasAnyNutrition, isTrue);

      expect(candidate.per100.kcal, 63);
      expect(candidate.per100.protein, 11);
      expect(candidate.per100.carbs, 3.8);
      expect(candidate.per100.fat, 0.2);
      expect(candidate.per100.sugar, 3.8);
      expect(candidate.per100.salt, 0.12);
      expect(candidate.completenessScore, 1);
    });

    test('falls back to kJ when kcal is missing', () {
      final candidate = OffProductCandidate.fromOffJson({
        'code': '12345678',
        'product_name': 'Energy Test',
        'nutriments': {
          'energy-kj_100g': 418.4,
          'proteins_100g': 1,
          'carbohydrates_100g': 2,
          'fat_100g': 3,
          'sugars_100g': 4,
          'salt_100g': 0.5,
        },
      });

      expect(candidate.hasKcal, isTrue);
      expect(candidate.per100.kcal, closeTo(100, 0.001));
    });

    test('marks candidate incomplete when sugar is missing', () {
      final candidate = OffProductCandidate.fromOffJson({
        'code': '111222333',
        'product_name': 'No Sugar Product',
        'nutriments': {
          'energy-kcal_100g': 100,
          'proteins_100g': 10,
          'carbohydrates_100g': 10,
          'fat_100g': 10,
          'salt_100g': 1.0,
        },
      });

      expect(candidate.hasSugar, isFalse);
      expect(candidate.hasCompleteCoreNutrition, isFalse);
      expect(candidate.per100.sugar, 0);
      expect(candidate.completenessScore, closeTo(6 / 7, 0.0001));
    });

    test('falls back to barcode as name when name fields are empty', () {
      final candidate = OffProductCandidate.fromOffJson({
        'code': '999888777',
        'product_name': '   ',
        'generic_name': '',
        'nutriments': {
          'energy-kcal_100g': 10,
          'proteins_100g': 1,
          'carbohydrates_100g': 1,
          'fat_100g': 1,
          'sugars_100g': 1,
          'salt_100g': 0.1,
        },
      });

      expect(candidate.name, '999888777');
    });

    test('parses decimal strings with comma', () {
      final candidate = OffProductCandidate.fromOffJson({
        'code': '123',
        'product_name': 'Comma Test',
        'nutriments': {
          'energy-kcal_100g': '250,5',
          'proteins_100g': '12,3',
          'carbohydrates_100g': '40,0',
          'fat_100g': '8,1',
          'sugars_100g': '14,6',
          'salt_100g': '0,7',
        },
      });

      expect(candidate.per100.kcal, 250.5);
      expect(candidate.per100.protein, 12.3);
      expect(candidate.per100.carbs, 40.0);
      expect(candidate.per100.fat, 8.1);
      expect(candidate.per100.sugar, 14.6);
      expect(candidate.per100.salt, 0.7);
    });
  });

  group('OffProductCandidate serialization', () {
    test('toJson and fromJson roundtrip', () {
      final original = const OffProductCandidate(
        code: '1234567890',
        name: 'Roundtrip Product',
        brand: 'Brand',
        quantityLabel: '500 g',
        servingSizeLabel: '50 g',
        imageUrl: 'https://example.com/p.png',
        per100: NutritionPer100(
          kcal: 250,
          protein: 10,
          carbs: 25,
          fat: 8,
          sugar: 12,
          salt: 0.7,
          saturatedFat: 2.4,
          polyunsaturatedFat: 1.1,
          fiber: 3.2,
        ),
        hasKcal: true,
        hasProtein: true,
        hasCarbs: true,
        hasFat: true,
        hasSugar: true,
        hasSalt: true,
        hasSaturatedFat: true,
        hasPolyunsaturatedFat: true,
        hasFiber: true,
        completenessScore: 1,
      );

      final restored = OffProductCandidate.fromJson(original.toJson());

      expect(restored.code, original.code);
      expect(restored.name, original.name);
      expect(restored.brand, original.brand);
      expect(restored.quantityLabel, original.quantityLabel);
      expect(restored.servingSizeLabel, original.servingSizeLabel);
      expect(restored.imageUrl, original.imageUrl);
      expect(restored.per100.kcal, original.per100.kcal);
      expect(restored.per100.protein, original.per100.protein);
      expect(restored.per100.carbs, original.per100.carbs);
      expect(restored.per100.fat, original.per100.fat);
      expect(restored.per100.sugar, original.per100.sugar);
      expect(restored.per100.salt, original.per100.salt);
      expect(restored.per100.saturatedFat, original.per100.saturatedFat);
      expect(
        restored.per100.polyunsaturatedFat,
        original.per100.polyunsaturatedFat,
      );
      expect(restored.per100.fiber, original.per100.fiber);
      expect(restored.hasCompleteCoreNutrition, isTrue);
      expect(restored.completenessScore, 1);
    });
  });
}
