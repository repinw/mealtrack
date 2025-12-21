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
    const storeName = 'Supermarkt';
    const quantity = 2;
    const unitPrice = 0.50;
    const weight = '100g';

    // Testet den Standardkonstruktor
    test('can be instantiated with default values', () {
      // ignore: invalid_use_of_internal_member
      final item = FridgeItem(
        id: id,
        rawText: rawText,
        entryDate: entryDate,
        storeName: storeName,
        quantity: quantity,
        unitPrice: unitPrice,
        weight: weight,
      );

      expect(item.id, id);
      expect(item.rawText, rawText);
      expect(item.entryDate, entryDate);
      expect(item.storeName, storeName);
      expect(item.quantity, quantity);
      expect(item.unitPrice, unitPrice);
      expect(item.weight, weight);
      expect(item.isConsumed, isFalse);
      expect(item.consumptionDate, isNull);
      expect(item.discounts, isEmpty);
    });

    // Testet die .create() Factory
    group('FridgeItem.create factory', () {
      test('creates an instance with generated values', () {
        final item = FridgeItem.create(rawText: 'Milch', storeName: 'Lidl');

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
        expect(item.storeName, 'Lidl');
        expect(item.quantity, 1);
        expect(item.isConsumed, isFalse);
        expect(item.consumptionDate, isNull);
        expect(item.discounts, isEmpty);
      });

      test('creates an instance with all optional values', () {
        final discounts = {'Rabatt': 0.50};
        final item = FridgeItem.create(
          rawText: 'Milch',
          storeName: 'Lidl',
          quantity: 5,
          unitPrice: 1.29,
          weight: '1L',
          discounts: discounts,
        );

        expect(item.quantity, 5);
        expect(item.unitPrice, 1.29);
        expect(item.weight, '1L');
        expect(item.discounts, discounts);
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
          storeName: 'Test Store',
          uuid: mockUuid,
          now: mockNow,
        );

        // Assert: Überprüfe, ob die gemockten Werte verwendet wurden
        expect(item.id, 'mocked-uuid');
        expect(item.entryDate, specificDate);
        expect(item.storeName, 'Test Store');
      });

      test('throws ArgumentError if rawText is empty or whitespace', () {
        // Test mit einem leeren String
        expect(
          () => FridgeItem.create(rawText: '', storeName: 'S'),
          throwsA(isA<ArgumentError>()),
        );

        // Test mit einem String, der nur Leerzeichen enthält
        expect(
          () => FridgeItem.create(rawText: '   ', storeName: 'S'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError if storeName is empty or whitespace', () {
        expect(
          () => FridgeItem.create(rawText: 'Milch', storeName: ''),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => FridgeItem.create(rawText: 'Milch', storeName: '   '),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError if quantity is less than or equal to 0', () {
        expect(
          () => FridgeItem.create(
            rawText: 'Milch',
            storeName: 'Lidl',
            quantity: 0,
          ),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => FridgeItem.create(
            rawText: 'Milch',
            storeName: 'Lidl',
            quantity: -1,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('initializes with receiptId if provided', () {
        const receiptId = 'receipt-123';
        final item = FridgeItem.create(
          rawText: 'Milch',
          storeName: 'Lidl',
          receiptId: receiptId,
        );
        expect(item.receiptId, receiptId);
      });
    });

    // Testet die Gleichheit basierend auf Equatable
    group('Equality', () {
      test('two instances with the same properties should be equal', () {
        final discounts = {'Rabatt': 1.0};
        // ignore: invalid_use_of_internal_member
        final item1 = FridgeItem(
          id: id,
          rawText: rawText,
          entryDate: entryDate,
          storeName: storeName,
          quantity: quantity,
          discounts: discounts,
        );
        // ignore: invalid_use_of_internal_member
        final item2 = FridgeItem(
          id: id,
          rawText: rawText,
          entryDate: entryDate,
          storeName: storeName,
          quantity: quantity,
          discounts: discounts,
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
          storeName: storeName,
          quantity: quantity,
        );
        // ignore: invalid_use_of_internal_member
        final item2 = FridgeItem(
          id: 'another-id',
          rawText: rawText,
          entryDate: entryDate,
          storeName: storeName,
          quantity: quantity,
        );

        expect(item1, isNot(equals(item2)));
        expect(item1.hashCode, isNot(equals(item2.hashCode)));
      });

      test(
          'two instances with different mutable properties should not be equal',
          () {
        // ignore: invalid_use_of_internal_member
        FridgeItem createItem({
          String storeName = 'S',
          int quantity = 1,
          double? unitPrice,
          String? weight,
        }) =>
            FridgeItem(
              id: '1',
              rawText: 'a',
              entryDate: entryDate,
              storeName: storeName,
              quantity: quantity,
              unitPrice: unitPrice,
              weight: weight,
            );

        expect(createItem(), isNot(equals(createItem(storeName: 'Other'))));
        expect(createItem(), isNot(equals(createItem(quantity: 2))));
        expect(createItem(), isNot(equals(createItem(unitPrice: 1.0))));
        expect(createItem(), isNot(equals(createItem(weight: '1kg'))));
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
          storeName: 'S',
          quantity: 1,
        );
        // ignore: invalid_use_of_internal_member
        final item2 = FridgeItem(
          id: '1',
          rawText: 'a',
          entryDate: date,
          isConsumed: true,
          consumptionDate: date,
          storeName: 'S',
          quantity: 1,
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
          storeName: storeName,
          quantity: quantity,
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
        final item = FridgeItem.create(rawText: 'Käse', storeName: 'Aldi');
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
        final item = FridgeItem.create(rawText: 'Wurst', storeName: 'Aldi');
        final specificConsumptionTime = DateTime(2025, 12, 24, 18, 0, 0);

        // Act
        item.markAsConsumed(consumptionTime: specificConsumptionTime);

        // Assert
        expect(item.isConsumed, isTrue);
        expect(item.consumptionDate, equals(specificConsumptionTime));
      });

      test('does not change consumptionDate if already consumed', () {
        // Arrange
        final item = FridgeItem.create(rawText: 'Milch', storeName: 'Aldi');
        final firstConsumptionTime = DateTime(2025, 1, 1);

        // Act: Markiere das Item zum ersten Mal als verbraucht.
        item.markAsConsumed(consumptionTime: firstConsumptionTime);

        // Assert: Überprüfe den initialen Zustand.
        expect(item.isConsumed, isTrue);
        expect(item.consumptionDate, firstConsumptionTime);

        // Act again: Versuche, es erneut mit einer anderen Zeit zu markieren.
        item.markAsConsumed(consumptionTime: DateTime(2025, 2, 2));

        // Assert again: Das Datum darf sich nicht geändert haben.
        expect(item.isConsumed, isTrue);
        expect(item.consumptionDate, firstConsumptionTime);
      });
    });

    group('Bug Fixes & Edge Cases', () {
      test('discounts map should be mutable after creation', () {
        final item = FridgeItem.create(rawText: 'Test', storeName: 'Test');

        // Dieser Aufruf darf keinen UnsupportedError werfen
        item.discounts['Sale'] = 1.0;

        expect(item.discounts, containsPair('Sale', 1.0));
      });

      test('throws ArgumentError if unitPrice is negative', () {
        expect(
          () => FridgeItem.create(
            rawText: 'Brot',
            storeName: 'Bäcker',
            unitPrice: -2.50,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test(
        'Constructor handles empty discounts by defaulting to empty mutable map',
        () {
          // ignore: invalid_use_of_internal_member
          final item = FridgeItem(
            id: 'id',
            rawText: 'text',
            entryDate: DateTime.now(),
            storeName: 'store',
            quantity: 1,
            discounts: {},
          );

          expect(item.discounts, isNotNull);
          expect(item.discounts, isEmpty);
          // Sicherstellen, dass die Map veränderbar ist
          expect(
            () => item.discounts['D'] = 1.0,
            returnsNormally,
          );
        },
      );
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
      final discounts = {'Aktion': 0.33};
      final originalItem = FridgeItem.create(
        rawText: 'Frische Milch',
        storeName: 'Edeka',
        quantity: 2,
        unitPrice: 1.19,
        discounts: discounts,
      );

      // Act
      await box.put(originalItem.id, originalItem);
      final retrievedItem = box.get(originalItem.id);

      // Assert
      expect(retrievedItem, isNotNull);
      expect(retrievedItem, equals(originalItem));
      expect(retrievedItem!.storeName, 'Edeka');
      expect(retrievedItem.quantity, 2);
      expect(retrievedItem.unitPrice, 1.19);
      expect(retrievedItem.discounts, discounts);
    });

    test('can be updated in a Hive box', () async {
      // Arrange: Erstelle ein Item und speichere es.
      final item = FridgeItem.create(rawText: 'Joghurt', storeName: 'Netto');
      await box.put(item.id, item);

      // Act: Hole das Item, modifiziere es und speichere es erneut.
      final itemToUpdate = box.get(item.id)!;
      final consumptionTime = DateTime.now();

      itemToUpdate.rawText = 'Joghurt (fast leer)';
      itemToUpdate.isConsumed = true;
      itemToUpdate.consumptionDate = consumptionTime;
      itemToUpdate.storeName = 'Netto (Updated)';
      await itemToUpdate.save(); // Wichtig: .save() aufrufen für HiveObject

      // Assert: Hole das Item erneut und überprüfe die Änderungen.
      final updatedItem = box.get(item.id)!;

      expect(updatedItem.rawText, 'Joghurt (fast leer)');
      expect(updatedItem.isConsumed, isTrue);
      expect(updatedItem.storeName, 'Netto (Updated)');
      // Vergleiche Millisekunden, da die Präzision beim Speichern variieren kann.
      expect(
        updatedItem.consumptionDate!.millisecondsSinceEpoch,
        consumptionTime.millisecondsSinceEpoch,
      );
    });

    test('can be deleted from a Hive box', () async {
      // Arrange: Erstelle ein Item und speichere es.
      final item = FridgeItem.create(rawText: 'Alte Socken', storeName: 'Home');
      await box.put(item.id, item);

      // Stelle sicher, dass das Item vor dem Löschen vorhanden ist.
      final itemToDelete = box.get(item.id);
      expect(itemToDelete, isNotNull);

      // Act: Lösche das Item.
      await itemToDelete!.delete();

      // Assert: Überprüfe, ob das Item nicht mehr in der Box ist.
      final deletedItem = box.get(item.id);
      expect(deletedItem, isNull);
    });

    test('persists receiptId correctly', () async {
      const receiptId = 'receipt-uuid-123';
      final item = FridgeItem.create(
        rawText: 'Item from Receipt',
        storeName: 'Test Store',
        receiptId: receiptId,
      );

      await box.put(item.id, item);
      final retrievedItem = box.get(item.id);

      expect(retrievedItem, isNotNull);
      expect(retrievedItem!.receiptId, receiptId);
    });
  });
}
