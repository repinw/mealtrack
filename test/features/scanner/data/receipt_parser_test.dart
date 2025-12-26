import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/data/receipt_parser.dart';

void main() {
  group('parseScannedItemsFromJson', () {
    // --- Happy Path ---
    group('Happy Path', () {
      test('parses standard JSON correctly', () {
        const jsonString =
            '{"items": [{"name": "Milk", "totalPrice": 1.50, "quantity": 1}]}';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.length, 1);
        expect(result.first.name, 'Milk');
        expect(result.first.unitPrice, 1.50);
      });

      test('parses minified JSON and calculates unitPrice', () {
        const jsonString = '{"i": [{"n": "Butter", "p": 2.0, "q": 2}]}';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.length, 1);
        expect(result.first.name, 'Butter');
        expect(result.first.unitPrice, 1.0);
      });

      test('parses mixed keys (minified and standard) correctly', () {
        const jsonString = '''
        {
          "items": [
            {"n": "Milk", "totalPrice": 1.50, "q": 1},
            {"name": "Bread", "p": 2.50, "quantity": 1}
          ]
        }
        ''';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.length, 2);
        expect(result[0].name, 'Milk');
        expect(result[0].unitPrice, 1.50);
        expect(result[1].name, 'Bread');
        expect(result[1].unitPrice, 2.50);
      });
    });

    // --- Edge Cases ---
    group('Edge Cases', () {
      test('returns empty list for empty JSON object {}', () {
        final result = parseScannedItemsFromJson('{}');
        expect(result, isEmpty);
      });

      test('returns empty list for JSON "null"', () {
        final result = parseScannedItemsFromJson('null');
        expect(result, isEmpty);
      });

      test('returns empty list for JSON with empty items list', () {
        final result = parseScannedItemsFromJson('{"items": []}');
        expect(result, isEmpty);
      });

      test('fallbacks to quantity 1 if quantity is 0 or negative', () {
        const jsonString = '''
        {
          "items": [
            {"name": "Zero Qty", "quantity": 0, "totalPrice": 5.0},
            {"name": "Neg Qty", "quantity": -5, "totalPrice": 5.0}
          ]
        }
        ''';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.length, 2);
        expect(result[0].quantity, 1);
        expect(result[1].quantity, 1);
        // Unit price check (5.0 / 1 = 5.0)
        expect(result[0].unitPrice, 5.0);
      });

      test('handles null or invalid discounts gracefully', () {
        const jsonString = '''
        {
          "items": [
            {"name": "Null Discounts", "discounts": null},
            {"name": "Invalid Discounts", "discounts": ["invalid", {"no_name": 1}]}
          ]
        }
        ''';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result[0].discounts, isEmpty);
        expect(result[1].discounts, isEmpty);
      });
    });

    group('Error Handling', () {
      test('throws FormatException on empty string', () {
        expect(
          () => parseScannedItemsFromJson(''),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              'Leerer JSON-String empfangen.',
            ),
          ),
        );
      });

      test('throws FormatException on string with only whitespace', () {
        expect(
          () => parseScannedItemsFromJson('   '),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              'Leerer JSON-String empfangen.',
            ),
          ),
        );
      });

      test('throws FormatException on empty sanitized string', () {
        expect(
          () => parseScannedItemsFromJson('```json ```'),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              'Bereinigter JSON-String ist leer.',
            ),
          ),
        );
      });

      test('throws FormatException on malformed JSON', () {
        expect(
          () => parseScannedItemsFromJson('{ kein valides json }'),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}
