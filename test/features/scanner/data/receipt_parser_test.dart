import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/data/receipt_parser.dart';

void main() {
  group('parseScannedItemsFromJson', () {
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

    test(
      'throws FormatException on empty sanitized string (only markdown tags)',
      () {
        // Simuliert den Fall, wo nur Markdown-Tags ohne Inhalt zurückkommen
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
      },
    );

    test('throws FormatException on invalid JSON format', () {
      expect(
        () => parseScannedItemsFromJson('{ kein valides json }'),
        throwsA(isA<FormatException>()),
      );
    });

    test('returns empty list on unexpected JSON structure', () {
      // JSON ist valide, aber enthält weder eine Liste noch einen "items" Key
      final result = parseScannedItemsFromJson('{"falscherKey": "wert"}');
      expect(result, isEmpty);
    });

    test('parses valid JSON and verifies unitPrice is >= 0', () {
      const jsonString = '''
      {
        "items": [
          {
            "name": "Test Item",
            "quantity": 1,
            "totalPrice": 10.50
          }
        ]
      }
      ''';

      final result = parseScannedItemsFromJson(jsonString);

      expect(result, isNotEmpty);
      expect(result.first.unitPrice, greaterThanOrEqualTo(0));
    });

    test('parses discounts correctly', () {
      const jsonString = '''
      {
        "items": [
          {
            "name": "Item with Discounts",
            "discounts": [
              { "name": "Summer Sale", "amount": 2.5 },
              { "amount": 1.0 },
              { "name": "Invalid Amount", "amount": 0 },
              { "name": "Negative Amount", "amount": -5.0 },
              "invalid_entry"
            ]
          }
        ]
      }
      ''';

      final result = parseScannedItemsFromJson(jsonString);

      expect(result, isNotEmpty);
      final item = result.first;
      expect(item.discounts, containsPair('Summer Sale', 2.5));
      expect(item.discounts, containsPair('Invalid Amount', 0.0));
      expect(item.discounts, containsPair('Negative Amount', -5.0));
      expect(item.discounts.length, 3);
    });
  });
}
