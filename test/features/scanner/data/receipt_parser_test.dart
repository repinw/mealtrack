import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mealtrack/features/scanner/data/receipt_parser.dart';

void main() {
  group('parseScannedItemsFromJson', () {
    group('Happy Path', () {
      test('parses minified JSON correctly', () {
        const jsonString = '{"i": [{"n": "Milk", "p": 1.50, "q": 1}]}';
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

      test('parses keys with string types correctly', () {
        const jsonString = '''
        {
          "l": "en_US",
          "i": [
            {"n": "Apple", "p": "6.0", "q": "3"},
             {"n": "Orange", "p": "5.0", "q": "5"}
          ]
        }
        ''';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.length, 2);
        expect(result[0].name, 'Apple');
        expect(result[0].unitPrice, 2.0);
        expect(result[0].quantity, 3);

        expect(result[1].name, 'Orange');
        expect(result[1].unitPrice, 1.0);
        expect(result[1].quantity, 5);
      });
    });

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
        final result = parseScannedItemsFromJson('{"i": []}');
        expect(result, isEmpty);
      });

      test('fallbacks to quantity 1 if quantity is 0 or negative', () {
        const jsonString = '''
        {
          "i": [
            {"n": "Zero Qty", "q": 0, "p": 5.0},
            {"n": "Neg Qty", "q": -5, "p": 5.0}
          ]
        }
        ''';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.length, 2);
        expect(result[0].quantity, 1);
        expect(result[1].quantity, 1);
        expect(result[0].unitPrice, 5.0);
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

      test('preserves negative price', () {
        const jsonString = '{"i": [{"n": "Negative", "p": -2.0, "q": 1}]}';
        final result = parseScannedItemsFromJson(jsonString);
        expect(result.first.unitPrice, -2.0);
      });

      group('Number Parsing Edge Cases', () {
        test('parses German format with comma (1,99) correctly', () {
          const jsonString = '{"i": [{"n": "German", "p": "1,99", "q": 1}]}';
          final result = parseScannedItemsFromJson(jsonString);
          expect(result.first.unitPrice, 1.99);
        });

        test('handling of thousands separators (1.200,50)', () {
          const jsonString =
              '{"l": "de_DE", "i": [{"n": "DE", "p": "1.200,50", "q": 1}]}';
          final result = parseScannedItemsFromJson(jsonString);
          expect(result.first.unitPrice, 1200.50);
        });

        test('handling of thousands separators (1,200.50)', () {
          const jsonString =
              '{"l": "en_US", "i": [{"n": "US", "p": "1,200.50", "q": 1}]}';
          final result = parseScannedItemsFromJson(jsonString);
          expect(result.first.unitPrice, 1200.50);
        });

        test('handles invalid price strings ("kostenlos") with default 0', () {
          const jsonString = '{"i": [{"n": "Free", "p": "kostenlos", "q": 1}]}';
          final result = parseScannedItemsFromJson(jsonString);
          expect(result.length, 1);
          expect(result.first.unitPrice, 0.0);
        });

        test('handles empty string price with default 0', () {
          const jsonString = '{"i": [{"n": "Empty", "p": "", "q": 1}]}';
          final result = parseScannedItemsFromJson(jsonString);
          expect(result.length, 1);
          expect(result.first.unitPrice, 0.0);
        });
      });

      test('parses direct JSON array (not wrapped in object)', () {
        const jsonString = '[{"n": "Apple", "p": 2.0, "q": 2}]';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.length, 1);
        expect(result.first.name, 'Apple');
        expect(result.first.unitPrice, 1.0);
      });

      test('uses fallback text when name is empty', () {
        const jsonString = '{"i": [{"n": "", "p": 1.0, "q": 1}]}';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.first.name, contains('Parsen'));
      });

      test('uses fallback text when storeName is empty', () {
        const jsonString = '{"i": [{"n": "Test", "s": "", "p": 1.0, "q": 1}]}';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.first.storeName, contains('Parsen'));
      });

      test('returns empty list when JSON object has no items/i key', () {
        const jsonString = '{"other": "data", "noItems": true}';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result, isEmpty);
      });

      test('parses discounts with minified keys (n, a)', () {
        const jsonString = '''{
          "i": [
            {
              "n": "Discounted",
              "p": 10.0,
              "q": 1,
              "d": [{"n": "Sale", "a": 2.0}]
            }
          ]
        }''';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.first.discounts, {'Sale': 2.0});
      });

      test('parses isDeposit from "if" key (isFood)', () {
        const jsonString = '''{
          "i": [
            {
              "n": "Deposit Item (isFood=false)",
              "p": -3.0,
              "q": 1,
              "if": false
            },
            {
              "n": "Normal Item (isFood=true)",
              "p": 3.0,
              "q": 1,
              "if": true
            },
            {
              "n": "Default Item (no if key)",
              "p": 3.0,
              "q": 1
            }
          ]
        }''';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result[0].isDeposit, isTrue);
        expect(result[1].isDeposit, isFalse);
        expect(result[2].isDeposit, isFalse);
      });

      test('parses weight and brand fields', () {
        const jsonString = '''{
          "i": [
            {"n": "Cheese", "p": 5.0, "q": 1, "w": "200g", "b": "BrandX"}
          ]
        }''';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.first.weight, '200g');
        expect(result.first.brand, 'BrandX');
      });

      test(
        'returns empty list for unexpected JSON format (primitive value)',
        () {
          final result = parseScannedItemsFromJson('42');
          expect(result, isEmpty);
        },
      );

      test('returns empty list for unexpected JSON format (boolean)', () {
        final result = parseScannedItemsFromJson('true');
        expect(result, isEmpty);
      });

      test('returns empty list for unexpected JSON format (string)', () {
        final result = parseScannedItemsFromJson('"just a string"');
        expect(result, isEmpty);
      });

      test(
        'throws FormatException when item is not a Map (type error in parsing)',
        () {
          const jsonString = '{"i": ["not a map", "another string"]}';
          expect(
            () => parseScannedItemsFromJson(jsonString),
            throwsA(isA<FormatException>()),
          );
        },
      );
    });
    group('New Schema Fields', () {
      test('parses root storeName, receiptDate, and language correctly', () {
        const jsonString = '''{
          "s": "Aldi",
          "rd": "2023-12-24",
          "l": "de_DE",
          "i": [
            {"n": "Glühwein", "p": 3.99, "q": 1}
          ]
        }''';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result.length, 1);
        final item = result.first;
        expect(item.storeName, 'Aldi');
        expect(item.receiptDate, DateTime(2023, 12, 24));
        expect(item.language, 'de_DE');
        expect(item.name, 'Glühwein');
      });

      test('prioritizes item storeName over root storeName', () {
        const jsonString = '''{
          "s": "RootStore",
          "i": [
            {"n": "Item1", "p": 1.0, "q": 1, "s": "ItemStore"},
            {"n": "Item2", "p": 1.0, "q": 1}
          ]
        }''';
        final result = parseScannedItemsFromJson(jsonString);

        expect(result[0].storeName, 'ItemStore');
        expect(result[1].storeName, 'RootStore');
      });

      test(
        'validates invalid date format gracefully by falling back to now',
        () {
          const jsonString = '''{
          "rd": "inv-ali-d",
          "i": [
            {"n": "Item", "p": 1.0, "q": 1}
          ]
        }''';
          final result = parseScannedItemsFromJson(jsonString);

          expect(result.first.receiptDate, isNotNull);
          expect(
            result.first.receiptDate!
                .difference(DateTime.now())
                .inSeconds
                .abs(),
            lessThan(2),
          );
        },
      );
    });
    group('Locale-Aware Number Parsing', () {
      test('parses "1,234" using comma-to-dot fallback', () {
        const jsonString = '''{
          "l": "en_US",
          "i": [
            {"n": "Item", "p": "1,234", "q": 1}
          ]
        }''';
        final result = parseScannedItemsFromJson(jsonString);
        expect(result.first.unitPrice, 1.234);
      });

      test(
        'parses "1,234" same way with de_DE locale (comma-to-dot fallback)',
        () {
          const jsonString = '''{
          "l": "de_DE",
          "i": [
            {"n": "Item", "p": "1,234", "q": 1}
          ]
        }''';
          final result = parseScannedItemsFromJson(jsonString);
          expect(result.first.unitPrice, 1.234);
        },
      );

      test('parses "1.234" as 1.234 with de_DE locale (dot parsed first)', () {
        const jsonString = '''{
          "l": "de_DE",
          "i": [
            {"n": "Item", "p": "1.234", "q": 1}
          ]
        }''';
        final result = parseScannedItemsFromJson(jsonString);
        expect(result.first.unitPrice, 1.234);
      });
    });
  });
}
