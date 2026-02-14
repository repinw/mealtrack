import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/data/nutrition_ocr_parser.dart';

void main() {
  group('parseNutritionOcrResult', () {
    test('parses minified schema keys', () {
      const raw = '''
      {
        "n": "Skyr Natur",
        "b": "Arla",
        "q": "450 g",
        "ss": "150 g",
        "kcal": 63,
        "protein": 11,
        "carbs": 3.8,
        "fat": 0.2,
        "sugar": 3.8,
        "salt": 0.12
      }
      ''';

      final result = parseNutritionOcrResult(raw);

      expect(result.productName, 'Skyr Natur');
      expect(result.brand, 'Arla');
      expect(result.quantityLabel, '450 g');
      expect(result.servingSizeLabel, '150 g');
      expect(result.per100.kcal, 63);
      expect(result.per100.protein, 11);
      expect(result.per100.carbs, 3.8);
      expect(result.per100.fat, 0.2);
      expect(result.per100.sugar, 3.8);
      expect(result.hasCompleteCoreNutrition, isTrue);
    });

    test('parses json from markdown code fence', () {
      const raw = '''
      ```json
      {
        "name": "Haferdrink",
        "brand": "Oatly",
        "energy_kcal": "45 kcal",
        "carbohydrates": "6,7 g",
        "protein": "1.0g",
        "fat": "1,5 g"
      }
      ```
      ''';

      final result = parseNutritionOcrResult(raw);

      expect(result.productName, 'Haferdrink');
      expect(result.brand, 'Oatly');
      expect(result.per100.kcal, 45);
      expect(result.per100.carbs, 6.7);
      expect(result.per100.protein, 1);
      expect(result.per100.fat, 1.5);
    });

    test('falls back to kJ conversion when kcal is missing', () {
      const raw = '''
      {
        "n": "Nudeln",
        "energy_kj": 1500,
        "protein": 12,
        "carbs": 70,
        "fat": 2
      }
      ''';

      final result = parseNutritionOcrResult(raw);

      expect(result.hasKcal, isTrue);
      expect(result.per100.kcal, closeTo(358.5, 0.2));
      expect(result.per100.protein, 12);
      expect(result.per100.carbs, 70);
      expect(result.per100.fat, 2);
    });

    test('supports nested nutriments style map', () {
      const raw = '''
      {
        "product": {
          "title": "Protein Pudding",
          "manufacturer": "Brand X"
        },
        "nutriments": {
          "energy_kcal_100g": "75",
          "proteins_100g": "10,0",
          "carbohydrates_100g": "4.2",
          "fat_100g": "1,3"
        }
      }
      ''';

      final result = parseNutritionOcrResult(raw);

      expect(result.productName, 'Protein Pudding');
      expect(result.brand, 'Brand X');
      expect(result.per100.kcal, 75);
      expect(result.per100.protein, 10);
      expect(result.per100.carbs, 4.2);
      expect(result.per100.fat, 1.3);
    });

    test('parses polyunsaturated fat when provided', () {
      const raw = '''
      {
        "kcal": 250,
        "protein": 8,
        "carbs": 20,
        "fat": 15,
        "sugar": 2.7,
        "salt": 0.6,
        "saturated_fat": 4.1,
        "polyunsaturated_fat": 5.3,
        "fiber": 3.0
      }
      ''';

      final result = parseNutritionOcrResult(raw);

      expect(result.per100.saturatedFat, 4.1);
      expect(result.per100.polyunsaturatedFat, 5.3);
      expect(result.per100.fiber, 3.0);
      expect(result.hasSaturatedFat, isTrue);
      expect(result.hasPolyunsaturatedFat, isTrue);
      expect(result.hasFiber, isTrue);
    });

    test('throws EMPTY_RESPONSE on blank input', () {
      expect(
        () => parseNutritionOcrResult('   '),
        throwsA(
          isA<NutritionOcrParseException>().having(
            (e) => e.code,
            'code',
            'EMPTY_RESPONSE',
          ),
        ),
      );
    });

    test('throws INVALID_JSON on malformed json', () {
      expect(
        () => parseNutritionOcrResult('{"kcal": 100'),
        throwsA(
          isA<NutritionOcrParseException>().having(
            (e) => e.code,
            'code',
            'INVALID_JSON',
          ),
        ),
      );
    });
  });

  group('tryParseNutritionOcrResult', () {
    test('returns null on parser failure', () {
      final result = tryParseNutritionOcrResult('not valid json');
      expect(result, isNull);
    });

    test('returns parsed result on valid json', () {
      const raw =
          '{"kcal": 123, "protein": 9, "carbs": 10, "fat": 5, "sugar": 4.2, "salt": 0.8}';

      final result = tryParseNutritionOcrResult(raw);

      expect(result, isNotNull);
      expect(result!.per100.kcal, 123);
      expect(result.hasCompleteCoreNutrition, isTrue);
    });
  });
}
