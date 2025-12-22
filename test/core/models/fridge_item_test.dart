import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:uuid/uuid.dart';

class MockUuid extends Mock implements Uuid {}

void main() {
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
        'two instances with different properties via helper should not be equal',
        () {
          // ignore: invalid_use_of_internal_member
          FridgeItem createItem({
            String storeName = 'S',
            int quantity = 1,
            double? unitPrice,
            String? weight,
          }) => FridgeItem(
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
        },
      );

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

    group('copyWith', () {
      test('creates a copy with updated values', () {
        // Arrange
        final item = FridgeItem.create(rawText: 'Käse', storeName: 'Aldi');
        final newDate = DateTime(2025, 12, 24);

        // Act
        final updatedItem = item.copyWith(
          rawText: 'Käse (alt)',
          isConsumed: true,
          consumptionDate: newDate,
        );

        // Assert
        expect(updatedItem.id, item.id);
        expect(updatedItem.rawText, 'Käse (alt)');
        expect(updatedItem.isConsumed, isTrue);
        expect(updatedItem.consumptionDate, newDate);
        // Unchanged properties
        expect(updatedItem.storeName, item.storeName);
        expect(updatedItem.quantity, item.quantity);
      });

      test('creates an identical copy when no arguments are provided', () {
        final item = FridgeItem.create(rawText: 'Käse', storeName: 'Aldi');
        final copiedItem = item.copyWith();

        expect(copiedItem, item);
        expect(copiedItem.hashCode, item.hashCode);
        expect(identical(copiedItem, item), isFalse);
      });

      test('copies values correctly when other properties are updated', () {
        // Arrange
        final consumptionDate = DateTime(2025, 11, 30);
        // ignore: invalid_use_of_internal_member
        final item = FridgeItem(
          id: 'test-id',
          rawText: 'Joghurt',
          entryDate: DateTime(2025, 11, 20),
          storeName: 'Rewe',
          quantity: 4,
          isConsumed: true,
          consumptionDate: consumptionDate,
        );

        // Act
        final updatedItem = item.copyWith(
          storeName: 'Rewe Center',
          quantity: 2,
        );

        // Assert: Check that the properties in question were copied correctly.
        expect(updatedItem.rawText, 'Joghurt');
        expect(updatedItem.isConsumed, isTrue);
        expect(updatedItem.consumptionDate, consumptionDate);

        // Assert: Check that the other properties were updated correctly.
        expect(updatedItem.storeName, 'Rewe Center');
        expect(updatedItem.quantity, 2);
      });
    });

    group('Bug Fixes & Edge Cases', () {
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
    });

    group('Serialization', () {
      final entryDate = DateTime(2025, 12, 1, 10, 30);
      final consumptionDate = DateTime(2025, 12, 5, 18, 0);
      final discounts = {'Aktion': 0.5, 'Treuebonus': 1.0};

      // ignore: invalid_use_of_internal_member
      final fullItem = FridgeItem(
        id: 'test-uuid-123',
        rawText: 'Bio Eier 6er',
        entryDate: entryDate,
        isConsumed: true,
        consumptionDate: consumptionDate,
        storeName: 'Alnatura',
        quantity: 1,
        unitPrice: 3.49,
        weight: '6 Stk',
        discounts: discounts,
        receiptId: 'receipt-abc',
        brand: 'Alnatura',
      );

      // ignore: invalid_use_of_internal_member
      final minimalItem = FridgeItem(
        id: 'test-uuid-456',
        rawText: 'Wasser',
        entryDate: entryDate,
        storeName: 'Supermarkt',
        quantity: 6,
      );

      test('toJson returns a valid map for a full item', () {
        final json = fullItem.toJson();

        expect(json, {
          'id': 'test-uuid-123',
          'rawText': 'Bio Eier 6er',
          'entryDate': entryDate.toIso8601String(),
          'isConsumed': true,
          'consumptionDate': consumptionDate.toIso8601String(),
          'storeName': 'Alnatura',
          'quantity': 1,
          'unitPrice': 3.49,
          'weight': '6 Stk',
          'discounts': discounts,
          'receiptId': 'receipt-abc',
          'brand': 'Alnatura',
        });
      });

      test('toJson returns a valid map for a minimal item', () {
        final json = minimalItem.toJson();

        expect(json, {
          'id': 'test-uuid-456',
          'rawText': 'Wasser',
          'entryDate': entryDate.toIso8601String(),
          'isConsumed': false,
          'consumptionDate': null,
          'storeName': 'Supermarkt',
          'quantity': 6,
          'unitPrice': null,
          'weight': null,
          'discounts': const {},
          'receiptId': null,
          'brand': null,
        });
      });

      test('fromJson creates a valid full item from a map', () {
        final json = fullItem.toJson();
        final itemFromJson = FridgeItem.fromJson(json);

        expect(itemFromJson, fullItem);
      });

      test('fromJson creates a valid minimal item from a map', () {
        final json = minimalItem.toJson();
        final itemFromJson = FridgeItem.fromJson(json);

        expect(itemFromJson, minimalItem);
      });

      test('fromJson handles missing optional fields gracefully', () {
        final json = {
          'id': 'test-uuid-789',
          'rawText': 'Kaffee',
          'entryDate': entryDate.toIso8601String(),
          'storeName': 'Tchibo',
          'quantity': 1,
        };

        final itemFromJson = FridgeItem.fromJson(json);

        // ignore: invalid_use_of_internal_member
        final expectedItem = FridgeItem(
          id: 'test-uuid-789',
          rawText: 'Kaffee',
          entryDate: entryDate,
          storeName: 'Tchibo',
          quantity: 1,
        );

        expect(itemFromJson, expectedItem);
      });
    });
  });
}
