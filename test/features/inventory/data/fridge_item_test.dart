import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';
import 'package:uuid/uuid.dart';

void main() {
  late Directory tempDir;

  // Initialisiert Hive in einem temporären Verzeichnis für alle Tests in dieser Datei.
  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_fridge_item_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapter(FridgeItemAdapter());
  });

  // Räumt das temporäre Verzeichnis nach allen Tests auf.
  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('FridgeItem', () {
    const id = 'test-uuid';
    const rawText = '2 Eier';
    final entryDate = DateTime(2025, 12, 1);

    // Testet den Standardkonstruktor
    test('can be instantiated with default values', () {
      final item = FridgeItem(id: id, rawText: rawText, entryDate: entryDate);

      expect(item.id, id);
      expect(item.rawText, rawText);
      expect(item.entryDate, entryDate);
      expect(item.isConsumed, isFalse);
      expect(item.consumptionDate, isNull);
    });

    // Testet die .create() Factory
    group('FridgeItem.create factory', () {
      test('creates an instance with generated values', () {
        final item = FridgeItem.create(rawText: 'Milch');

        // Überprüft, ob die ID ein gültiges UUID v4 Format hat.
        expect(
          Uuid.isValidUUID(
            fromString: item.id,
            validationMode: ValidationMode.nonStrict,
          ),
          isTrue,
        );
        expect(item.rawText, 'Milch');
        // Überprüft, ob das Datum sehr nah am aktuellen Datum liegt.
        expect(
          item.entryDate.difference(DateTime.now()).inSeconds.abs(),
          lessThan(2),
        );
        expect(item.isConsumed, isFalse);
        expect(item.consumptionDate, isNull);
      });
      test('FridgeItem.create should handle empty rawText', () {
        final item = FridgeItem.create(rawText: '');
        expect(item.rawText, '');
      });
    });

    // Testet die Gleichheit basierend auf Equatable
    group('Equality', () {
      test('two instances with the same properties should be equal', () {
        final item1 = FridgeItem(
          id: id,
          rawText: rawText,
          entryDate: entryDate,
        );
        final item2 = FridgeItem(
          id: id,
          rawText: rawText,
          entryDate: entryDate,
        );

        expect(item1, equals(item2));
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('two instances with different properties should not be equal', () {
        final item1 = FridgeItem(
          id: id,
          rawText: rawText,
          entryDate: entryDate,
        );
        final item2 = FridgeItem(
          id: 'another-id',
          rawText: rawText,
          entryDate: entryDate,
        );

        expect(item1, isNot(equals(item2)));
        expect(item1.hashCode, isNot(equals(item2.hashCode)));
      });

      test('two instances with all properties set should be equal', () {
        final date = DateTime.now();
        final item1 = FridgeItem(
          id: '1',
          rawText: 'a',
          entryDate: date,
          isConsumed: true,
          consumptionDate: date,
        );
        final item2 = FridgeItem(
          id: '1',
          rawText: 'a',
          entryDate: date,
          isConsumed: true,
          consumptionDate: date,
        );
        expect(item1, equals(item2));
      });
    });

    // Testet die toString() Methode (via Equatable's stringify)
    group('toString', () {
      test('returns a string with all properties', () {
        final item = FridgeItem(
          id: id,
          rawText: rawText,
          entryDate: entryDate,
          isConsumed: false,
        );

        final itemString = item.toString();

        expect(itemString, contains(id));
        expect(itemString, contains(rawText));
        expect(itemString, contains(entryDate.toString()));
        expect(itemString, contains(false.toString()));
      });
    });
  });
}
