import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:uuid/uuid.dart';

class MockUuid extends Mock implements Uuid {}

void main() {
  group('FridgeItem', () {
    const id = 'test-uuid';
    const name = '2 Eier';
    final entryDate = DateTime(2025, 12, 1);
    const storeName = 'Supermarkt';
    const quantity = 2;
    const unitPrice = 0.50;
    const weight = '100g';

    test('can be instantiated with default values', () {
      // ignore: invalid_use_of_internal_member
      final item = FridgeItem(
        id: id,
        name: name,
        entryDate: entryDate,
        storeName: storeName,
        quantity: quantity,
        unitPrice: unitPrice,
        weight: weight,
      );

      expect(item.id, id);
      expect(item.name, name);
      expect(item.entryDate, entryDate);
      expect(item.storeName, storeName);
      expect(item.quantity, quantity);
      expect(item.unitPrice, unitPrice);
      expect(item.weight, weight);
      expect(item.isConsumed, isFalse);
      expect(item.consumptionDate, isNull);
      expect(item.discounts, isEmpty);
    });

    group('FridgeItem.create factory', () {
      test('creates an instance with generated values', () {
        final item = FridgeItem.create(name: 'Milch', storeName: 'Lidl');

        expect(item.id, isNotNull);
        expect(
          Uuid.isValidUUID(
            fromString: item.id,
            validationMode: ValidationMode.nonStrict,
          ),
          isTrue,
        );
        expect(item.name, 'Milch');
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
          name: 'Milch',
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
        final mockUuid = MockUuid();
        final specificDate = DateTime(2025, 10, 20, 10, 0, 0);
        DateTime mockNow() => specificDate;
        when(() => mockUuid.v4()).thenReturn('mocked-uuid');

        final item = FridgeItem.create(
          name: 'Test Item',
          storeName: 'Test Store',
          uuid: mockUuid,
          now: mockNow,
        );

        expect(item.id, 'mocked-uuid');
        expect(item.entryDate, specificDate);
        expect(item.storeName, 'Test Store');
      });

      test('throws ArgumentError if name is empty or whitespace', () {
        expect(
          () => FridgeItem.create(name: '', storeName: 'S'),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => FridgeItem.create(name: '   ', storeName: 'S'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError if storeName is empty or whitespace', () {
        expect(
          () => FridgeItem.create(name: 'Milch', storeName: ''),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => FridgeItem.create(name: 'Milch', storeName: '   '),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError if quantity is less than or equal to 0', () {
        expect(
          () =>
              FridgeItem.create(name: 'Milch', storeName: 'Lidl', quantity: 0),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () =>
              FridgeItem.create(name: 'Milch', storeName: 'Lidl', quantity: -1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('initializes with receiptId if provided', () {
        const receiptId = 'receipt-123';
        final item = FridgeItem.create(
          name: 'Milch',
          storeName: 'Lidl',
          receiptId: receiptId,
        );
        expect(item.receiptId, receiptId);
      });
    });

    group('Equality', () {
      test('two instances with the same properties should be equal', () {
        final discounts = {'Rabatt': 1.0};
        // ignore: invalid_use_of_internal_member
        final item1 = FridgeItem(
          id: id,
          name: name,
          entryDate: entryDate,
          storeName: storeName,
          quantity: quantity,
          discounts: discounts,
        );
        // ignore: invalid_use_of_internal_member
        final item2 = FridgeItem(
          id: id,
          name: name,
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
          name: name,
          entryDate: entryDate,
          storeName: storeName,
          quantity: quantity,
        );
        // ignore: invalid_use_of_internal_member
        final item2 = FridgeItem(
          id: 'another-id',
          name: name,
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
            double unitPrice = 0.0,
            String? weight,
          }) => FridgeItem(
            id: '1',
            name: 'a',
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
          name: 'a',
          entryDate: date,
          isConsumed: true,
          consumptionEvents: [date],
          storeName: 'S',
          quantity: 1,
        );
        // ignore: invalid_use_of_internal_member
        final item2 = FridgeItem(
          id: '1',
          name: 'a',
          entryDate: date,
          isConsumed: true,
          consumptionEvents: [date],
          storeName: 'S',
          quantity: 1,
        );
        expect(item1, equals(item2));
      });
    });

    group('toString', () {
      test('returns a string with all properties', () {
        // ignore: invalid_use_of_internal_member
        final item = FridgeItem(
          id: id,
          name: name,
          entryDate: entryDate,
          isConsumed: false,
          storeName: storeName,
          quantity: quantity,
        );

        final itemString = item.toString();

        expect(itemString, contains(id));
        expect(itemString, contains(name));
        expect(itemString, contains(entryDate.toString()));
        expect(itemString, contains(false.toString()));
      });
    });

    group('copyWith', () {
      test('creates a copy with updated values', () {
        final item = FridgeItem.create(name: 'Käse', storeName: 'Aldi');
        final newDate = DateTime(2025, 12, 24);

        final updatedItem = item.copyWith(
          name: 'Käse (alt)',
          isConsumed: true,
          consumptionEvents: [newDate],
        );

        expect(updatedItem.id, item.id);
        expect(updatedItem.name, 'Käse (alt)');
        expect(updatedItem.isConsumed, isTrue);
        expect(updatedItem.consumptionDate, newDate);
        expect(updatedItem.storeName, item.storeName);
        expect(updatedItem.quantity, item.quantity);
      });

      test('creates an identical copy when no arguments are provided', () {
        final item = FridgeItem.create(name: 'Käse', storeName: 'Aldi');
        final copiedItem = item.copyWith();

        expect(copiedItem, item);
        expect(copiedItem.hashCode, item.hashCode);
        expect(identical(copiedItem, item), isFalse);
      });

      test('copies values correctly when other properties are updated', () {
        final consumptionDate = DateTime(2025, 11, 30);
        // ignore: invalid_use_of_internal_member
        final item = FridgeItem(
          id: 'test-id',
          name: 'Joghurt',
          entryDate: DateTime(2025, 11, 20),
          storeName: 'Rewe',
          quantity: 4,
          isConsumed: true,
          consumptionEvents: [consumptionDate],
        );

        final updatedItem = item.copyWith(
          storeName: 'Rewe Center',
          quantity: 2,
        );

        expect(updatedItem.name, 'Joghurt');
        expect(updatedItem.isConsumed, isTrue);
        expect(updatedItem.consumptionDate, consumptionDate);
        expect(updatedItem.storeName, 'Rewe Center');
        expect(updatedItem.quantity, 2);
      });
    });

    group('Bug Fixes & Edge Cases', () {
      test('throws ArgumentError if unitPrice is negative', () {
        expect(
          () => FridgeItem.create(
            name: 'Brot',
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
        name: 'Bio Eier 6er',
        entryDate: entryDate,
        isConsumed: true,
        consumptionEvents: [consumptionDate],
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
        name: 'Wasser',
        entryDate: entryDate,
        storeName: 'Supermarkt',
        quantity: 6,
      );

      test('toJson returns a valid map for a full item', () {
        final json = fullItem.toJson();

        expect(json, {
          'id': 'test-uuid-123',
          'name': 'Bio Eier 6er',
          'entryDate': entryDate.toIso8601String(),
          'isConsumed': true,
          'consumptionEvents': [consumptionDate.toIso8601String()],
          'consumptionDate': consumptionDate.toIso8601String(),
          'storeName': 'Alnatura',
          'quantity': 1,
          'unitPrice': 3.49,
          'weight': '6 Stk',
          'discounts': discounts,
          'receiptId': 'receipt-abc',
          'receiptDate': null,
          'language': null,
          'brand': 'Alnatura',
          'initialQuantity': 1,
        });
      });

      test('toJson returns a valid map for a minimal item', () {
        final json = minimalItem.toJson();

        expect(json, {
          'id': 'test-uuid-456',
          'name': 'Wasser',
          'entryDate': entryDate.toIso8601String(),
          'isConsumed': false,
          'consumptionEvents': [],
          'consumptionDate': null,
          'storeName': 'Supermarkt',
          'quantity': 6,
          'unitPrice': 0.0,
          'weight': null,
          'discounts': const {},
          'receiptId': null,
          'receiptDate': null,
          'language': null,
          'brand': null,
          'initialQuantity': 1,
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
          'name': 'Kaffee',
          'entryDate': entryDate.toIso8601String(),
          'storeName': 'Tchibo',
          'quantity': 1,
        };

        final itemFromJson = FridgeItem.fromJson(json);

        // ignore: invalid_use_of_internal_member
        final expectedItem = FridgeItem(
          id: 'test-uuid-789',
          name: 'Kaffee',
          entryDate: entryDate,
          storeName: 'Tchibo',
          quantity: 1,
        );

        expect(itemFromJson, expectedItem);
      });

      test('fromJson uses DateTime.now() for invalid entryDate', () {
        final json = {
          'id': 'test-uuid-invalid-date',
          'name': 'Test',
          'entryDate': 'not-a-valid-date',
          'storeName': 'Store',
          'quantity': 1,
        };

        final itemFromJson = FridgeItem.fromJson(json);

        expect(
          itemFromJson.entryDate.difference(DateTime.now()).inSeconds.abs(),
          lessThan(2),
        );
      });

      test('fromJson handles legacy consumptionDate field', () {
        final legacyDate = DateTime(2025, 12, 5, 14, 30);
        final json = {
          'id': 'test-uuid-legacy',
          'name': 'Legacy Item',
          'entryDate': entryDate.toIso8601String(),
          'storeName': 'Store',
          'quantity': 1,
          'consumptionDate': legacyDate.toIso8601String(),
        };

        final itemFromJson = FridgeItem.fromJson(json);

        expect(itemFromJson.consumptionEvents.length, 1);
        expect(itemFromJson.consumptionEvents.first, legacyDate);
        expect(itemFromJson.consumptionDate, legacyDate);
      });

      test(
        'fromJson prefers consumptionEvents over legacy consumptionDate',
        () {
          final legacyDate = DateTime(2025, 12, 5, 14, 30);
          final eventsDate1 = DateTime(2025, 12, 6, 10, 0);
          final eventsDate2 = DateTime(2025, 12, 7, 12, 0);
          final json = {
            'id': 'test-uuid-both',
            'name': 'Both Fields Item',
            'entryDate': entryDate.toIso8601String(),
            'storeName': 'Store',
            'quantity': 1,
            'consumptionEvents': [
              eventsDate1.toIso8601String(),
              eventsDate2.toIso8601String(),
            ],
            'consumptionDate': legacyDate.toIso8601String(),
          };

          final itemFromJson = FridgeItem.fromJson(json);

          // Should use consumptionEvents, not legacy field
          expect(itemFromJson.consumptionEvents.length, 2);
          expect(itemFromJson.consumptionEvents[0], eventsDate1);
          expect(itemFromJson.consumptionEvents[1], eventsDate2);
          expect(itemFromJson.consumptionDate, eventsDate2); // Last event
        },
      );
    });
  });
}
