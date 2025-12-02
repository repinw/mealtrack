import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';
import 'package:uuid/uuid.dart';

class MockUuid extends Mock implements Uuid {}

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
      // ignore: invalid_use_of_internal_member
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

      test('uses provided uuid and now function', () {
        // Arrange: Erstelle Mocks für Uuid und die now-Funktion
        final mockUuid = MockUuid();
        final specificDate = DateTime(2025, 10, 20, 10, 0, 0);
        DateTime mockNow() => specificDate;

        // Definiere das Verhalten des Uuid-Mocks
        when(() => mockUuid.v4()).thenReturn('mocked-uuid');

        // Act: Erstelle das Item mit den Mocks
        final item = FridgeItem.create(
          rawText: 'Test Item',
          uuid: mockUuid,
          now: mockNow,
        );

        // Assert: Überprüfe, ob die gemockten Werte verwendet wurden
        expect(item.id, 'mocked-uuid');
        expect(item.entryDate, specificDate);
      });

      test('throws ArgumentError if rawText is empty or whitespace', () {
        // Test mit einem leeren String
        expect(
          () => FridgeItem.create(rawText: ''),
          throwsA(isA<ArgumentError>()),
        );

        // Test mit einem String, der nur Leerzeichen enthält
        expect(
          () => FridgeItem.create(rawText: '   '),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    // Testet die Gleichheit basierend auf Equatable
    group('Equality', () {
      test('two instances with the same properties should be equal', () {
        // ignore: invalid_use_of_internal_member
        final item1 = FridgeItem(
          id: id,
          rawText: rawText,
          entryDate: entryDate,
        );
        // ignore: invalid_use_of_internal_member
        final item2 = FridgeItem(
          id: id,
          rawText: rawText,
          entryDate: entryDate,
        );

        expect(item1, equals(item2));
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('two instances with different properties should not be equal', () {
        // ignore: invalid_use_of_internal_member
        final item1 = FridgeItem(
          id: id,
          rawText: rawText,
          entryDate: entryDate,
        );
        // ignore: invalid_use_of_internal_member
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
        // ignore: invalid_use_of_internal_member
        final item1 = FridgeItem(
          id: '1',
          rawText: 'a',
          entryDate: date,
          isConsumed: true,
          consumptionDate: date,
        );
        // ignore: invalid_use_of_internal_member
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
        // ignore: invalid_use_of_internal_member
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

    group('Methods', () {
      test('markAsConsumed sets consumption status and date', () {
        // Arrange
        final item = FridgeItem.create(rawText: 'Käse');
        expect(item.isConsumed, isFalse);
        expect(item.consumptionDate, isNull);

        // Act
        item.markAsConsumed();

        // Assert
        expect(item.isConsumed, isTrue);
        expect(item.consumptionDate, isA<DateTime>());
        // Check if the date is very recent
        expect(
          item.consumptionDate!.difference(DateTime.now()).inSeconds.abs(),
          lessThan(2),
        );
      });

      test('markAsConsumed uses provided consumption time', () {
        // Arrange
        final item = FridgeItem.create(rawText: 'Wurst');
        final specificConsumptionTime = DateTime(2025, 12, 24, 18, 0, 0);

        // Act
        item.markAsConsumed(consumptionTime: specificConsumptionTime);

        // Assert
        expect(item.isConsumed, isTrue);
        expect(item.consumptionDate, equals(specificConsumptionTime));
      });
    });
  });

  group('Hive Persistence', () {
    const boxName = 'fridge_item_persistence_test';
    late Box<FridgeItem> box;

    // Öffnet vor jedem Test eine saubere Box
    setUp(() async {
      box = await Hive.openBox<FridgeItem>(boxName);
    });

    // Schließt und löscht die Box nach jedem Test
    tearDown(() async {
      await box.deleteFromDisk();
    });

    test('can be written to and read from a Hive box', () async {
      // Arrange
      final originalItem = FridgeItem.create(rawText: 'Frische Milch');

      // Act
      await box.put(originalItem.id, originalItem);
      final retrievedItem = box.get(originalItem.id);

      // Assert
      expect(retrievedItem, isNotNull);
      expect(retrievedItem, equals(originalItem));
    });

    test('can be updated in a Hive box', () async {
      // Arrange: Erstelle ein Item und speichere es.
      final item = FridgeItem.create(rawText: 'Joghurt');
      await box.put(item.id, item);

      // Act: Hole das Item, modifiziere es und speichere es erneut.
      final itemToUpdate = box.get(item.id)!;
      final consumptionTime = DateTime.now();

      itemToUpdate.rawText = 'Joghurt (fast leer)';
      itemToUpdate.isConsumed = true;
      itemToUpdate.consumptionDate = consumptionTime;
      await itemToUpdate.save(); // Wichtig: .save() aufrufen für HiveObject

      // Assert: Hole das Item erneut und überprüfe die Änderungen.
      final updatedItem = box.get(item.id)!;

      expect(updatedItem.rawText, 'Joghurt (fast leer)');
      expect(updatedItem.isConsumed, isTrue);
      // Vergleiche Millisekunden, da die Präzision beim Speichern variieren kann.
      expect(
        updatedItem.consumptionDate!.millisecondsSinceEpoch,
        consumptionTime.millisecondsSinceEpoch,
      );
    });
  });
}
