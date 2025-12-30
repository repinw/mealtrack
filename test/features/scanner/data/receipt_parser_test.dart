import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
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

      test('parses keys with string types correctly', () {
        const jsonString = '''
        {
          "items": [
            {"n": "Apple", "p": "6.0", "q": "3"},
             {"name": "Orange", "totalPrice": "5.0", "quantity": "5"}
          ]
        }
        ''';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.length, 2);
        expect(result[0].name, 'Apple');
        expect(result[0].unitPrice, 2.0); // 6.0 / 3
        expect(result[0].quantity, 3);

        expect(result[1].name, 'Orange');
        expect(result[1].unitPrice, 1.0); // 5.0 / 5
        expect(result[1].quantity, 5);
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

      test('parses numbers with commas correctly', () {
        const jsonString = '{"i": [{"n": "Brot", "p": "1,59", "q": 1}]}';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.length, 1);
        expect(result.first.name, 'Brot');
        expect(result.first.unitPrice, 1.59);
      });

      test('parses JSON surrounded by dirty text/markdown', () {
        const jsonString = '''
        Here is the JSON you asked for:
        ```json
        {"i": [{"n": "Clean", "p": 1.0, "q": 1}]}
        ```
        Hope this helps!
        ''';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.length, 1);
        expect(result.first.name, 'Clean');
      });

      test('handles null price but existing quantity', () {
        // q exists (1), p is null (0.0). unitPrice = 0.0 / 1 = 0.0
        const jsonString = '{"i": [{"n": "No Price", "p": null, "q": 1}]}';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.length, 1);
        expect(result.first.name, 'No Price');
        expect(result.first.unitPrice, 0.0);
        expect(result.first.quantity, 1);
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

      test('throws ReceiptAnalysisException on malformed JSON', () {
        expect(
          () => parseScannedItemsFromJson('{ kein valides json }'),
          throwsA(
            isA<ReceiptAnalysisException>().having(
              (e) => e.code,
              'code',
              'INVALID_JSON',
            ),
          ),
        );
      });

      test('converts negative price to positive', () {
        const jsonString = '{"i": [{"n": "Negative", "p": -2.0, "q": 1}]}';
        final result = parseScannedItemsFromJson(jsonString);
        expect(result.first.unitPrice, 2.0);
      });

      group('Number Parsing Edge Cases', () {
        test('parses German format with comma (1,99) correctly', () {
          const jsonString = '{"i": [{"n": "German", "p": "1,99", "q": 1}]}';
          final result = parseScannedItemsFromJson(jsonString);
          expect(result.first.unitPrice, 1.99);
        });

        test('handling of thousands separators (1.200,50)', () {
          // German format with thousands dot
          const jsonString = '{"i": [{"n": "DE", "p": "1.200,50", "q": 1}]}';
          final result = parseScannedItemsFromJson(jsonString);
          expect(result.first.unitPrice, 1200.50);
        });

        test('handling of thousands separators (1,200.50)', () {
          // US format
          const jsonString = '{"i": [{"n": "US", "p": "1,200.50", "q": 1}]}';
          final result = parseScannedItemsFromJson(jsonString);
          expect(result.first.unitPrice, 1200.50);
        });

        test('handling of spaces (1 200.50)', () {
          // Space as separator
          const jsonString = '{"i": [{"n": "Space", "p": "1 200.50", "q": 1}]}';
          final result = parseScannedItemsFromJson(jsonString);
          expect(result.first.unitPrice, 1200.50);
        });

        test('handles invalid price strings ("kostenlos") gracefully', () {
          const jsonString = '{"i": [{"n": "Free", "p": "kostenlos", "q": 1}]}';
          final result = parseScannedItemsFromJson(jsonString);
          expect(result.first.unitPrice, 0.0);
        });
      });
    });
  });
}
