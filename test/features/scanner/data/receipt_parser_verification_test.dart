import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mealtrack/features/scanner/data/receipt_parser.dart';

void main() {
  group('ReceiptParser Verification Requirements', () {
    // 1. Happy Path: Validierung des JSON-Parsings mit einem perfekten JSON-String
    test('Happy Path: Parses perfect JSON correctly', () {
      const jsonString = '''
      {
        "s": "Supermarket",
        "rd": "2023-10-27",
        "l": "en_US",
        "i": [
          {"n": "Banana", "p": 1.50, "q": 2}
        ]
      }
      ''';
      final result = parseScannedItemsFromJson(jsonString);

      expect(result.length, 1);
      expect(result.first.name, 'Banana');
      expect(result.first.storeName, 'Supermarket');
      expect(result.first.quantity, 2);
      expect(result.first.unitPrice, 0.75); // 1.50 / 2
    });

    // 2. Edge Case: Input ist leerer String -> Erwartet: FormatException
    test('Edge Case: Empty string throws FormatException', () {
      expect(
        () => parseScannedItemsFromJson(''),
        throwsA(isA<FormatException>()),
      );
    });

    // 3. Edge Case: Disney JSON (mit Markdown Code-Blocks) -> Muss korrekt extrahiert werden
    test('Edge Case: Extracts JSON from Markdown code blocks', () {
      const jsonString = '''
      Here is the receipt data:
      ```json
      {
        "i": [{"n": "Markdown Item", "p": 5.0, "q": 1}]
      }
      ```
      Hope this helps!
      ''';
      final result = parseScannedItemsFromJson(jsonString);

      expect(result.length, 1);
      expect(result.first.name, 'Markdown Item');
    });

    // 4. Edge Case: Valid JSON aber keine Liste -> Muss handled werden oder leere Liste zurückgeben
    test('Edge Case: Valid JSON object without items returns empty list', () {
      const jsonString = '{"some": "other", "data": 123}';
      final result = parseScannedItemsFromJson(jsonString);

      expect(result, isEmpty);
    });

    // 5. Edge Case: Parsing-Fehler (Malformed JSON) -> Muss ReceiptAnalysisException werfen
    test('Edge Case: Malformed JSON throws ReceiptAnalysisException', () {
      const jsonString = '{ invalid json here }';
      expect(
        () => parseScannedItemsFromJson(jsonString),
        throwsA(isA<ReceiptAnalysisException>()),
      );
    });
  });
}
