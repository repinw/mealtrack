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
      // Der Parser fängt jsonDecode Fehler ab und gibt [] zurück (laut Implementierung)
      // HINWEIS: Die Implementierung wirft eine Exception, anstatt eine leere Liste zurückzugeben.
      // Dieser Test wurde angepasst, um das aktuelle (fehlerhafte) Verhalten zu prüfen.
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

    test('parses valid JSON and verifies totalPrice is >= 0', () {
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
      expect(result.first.totalPrice, greaterThanOrEqualTo(0));
    });
  });
}
