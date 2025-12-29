import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/local_storage_service.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late FridgeRepository repository;
  late MockLocalStorageService mockLocalStorageService;

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    repository = FridgeRepository(localStorageService: mockLocalStorageService);
  });

  group('FridgeRepository', () {
    test('updateQuantity consumes item when quantity reaches 0', () async {
      // Arrange
      final item = FridgeItem.create(
        name: 'TestItem',
        storeName: 'TestStore',
        quantity: 1,
        unitPrice: 1.0,
      );
      final items = [item];

      when(
        () => mockLocalStorageService.loadItems(),
      ).thenAnswer((_) async => items);
      when(
        () => mockLocalStorageService.saveItems(any()),
      ).thenAnswer((_) async {});

      // Act
      // Reduce quantity by 1 (1 - 1 = 0)
      await repository.updateQuantity(item, -1);

      // Assert
      final captured = verify(
        () => mockLocalStorageService.saveItems(captureAny()),
      ).captured;
      final savedItems = captured.first as List<FridgeItem>;
      final updatedItem = savedItems.first;

      expect(updatedItem.quantity, 0);
      expect(updatedItem.isConsumed, true);
    });

    test(
      'updateQuantity unconscumes item when quantity increases from 0',
      () async {
        // Arrange
        final item =
            FridgeItem.create(
              name: 'TestItem',
              storeName: 'TestStore',
              quantity: 1,
              unitPrice: 1.0,
            ).copyWith(
              quantity: 0,
              isConsumed: true,
              consumptionDate: DateTime.now(),
            );
        final items = [item];

        when(
          () => mockLocalStorageService.loadItems(),
        ).thenAnswer((_) async => items);
        when(
          () => mockLocalStorageService.saveItems(any()),
        ).thenAnswer((_) async {});

        // Act
        await repository.updateQuantity(item, 1);

        // Assert
        final captured = verify(
          () => mockLocalStorageService.saveItems(captureAny()),
        ).captured;
        final savedItems = captured.first as List<FridgeItem>;
        final updatedItem = savedItems.first;

        expect(updatedItem.quantity, 1);
        expect(updatedItem.isConsumed, false);
        expect(updatedItem.consumptionDate, null);
      },
    );

    test('getItems returns items from storage', () async {
      final items = [
        FridgeItem.create(
          name: 'Apple',
          storeName: 'Store',
          quantity: 5,
          unitPrice: 1.0,
        ),
      ];
      when(
        () => mockLocalStorageService.loadItems(),
      ).thenAnswer((_) async => items);

      final result = await repository.getItems();

      expect(result, items);
      verify(() => mockLocalStorageService.loadItems()).called(1);
    });

    test('getItems rethrows exceptions', () async {
      when(
        () => mockLocalStorageService.loadItems(),
      ).thenThrow(Exception('Storage error'));

      expect(() => repository.getItems(), throwsException);
    });

    test('saveItems saves to storage', () async {
      final items = [
        FridgeItem.create(
          name: 'Apple',
          storeName: 'Store',
          quantity: 5,
          unitPrice: 1.0,
        ),
      ];
      when(
        () => mockLocalStorageService.saveItems(any()),
      ).thenAnswer((_) async {});

      await repository.saveItems(items);

      verify(() => mockLocalStorageService.saveItems(items)).called(1);
    });

    test('addItems merges new items with existing', () async {
      final existingItem = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
        unitPrice: 1.0,
      );
      final newItem = FridgeItem.create(
        name: 'Banana',
        storeName: 'Store',
        quantity: 3,
        unitPrice: 0.5,
      );

      when(
        () => mockLocalStorageService.loadItems(),
      ).thenAnswer((_) async => [existingItem]);
      when(
        () => mockLocalStorageService.saveItems(any()),
      ).thenAnswer((_) async {});

      await repository.addItems([newItem]);

      final captured = verify(
        () => mockLocalStorageService.saveItems(captureAny()),
      ).captured;
      final savedItems = captured.first as List<FridgeItem>;
      expect(savedItems.length, 2);
      expect(savedItems[0].name, 'Apple');
      expect(savedItems[1].name, 'Banana');
    });

    test('updateItem updates existing item', () async {
      final item = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
        unitPrice: 1.0,
      );
      final updatedItem = item.copyWith(quantity: 10);

      when(
        () => mockLocalStorageService.loadItems(),
      ).thenAnswer((_) async => [item]);
      when(
        () => mockLocalStorageService.saveItems(any()),
      ).thenAnswer((_) async {});

      await repository.updateItem(updatedItem);

      final captured = verify(
        () => mockLocalStorageService.saveItems(captureAny()),
      ).captured;
      final savedItems = captured.first as List<FridgeItem>;
      expect(savedItems.first.quantity, 10);
    });

    test('updateItem does nothing when item not found', () async {
      final existingItem = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
        unitPrice: 1.0,
      );
      final nonExistentItem = FridgeItem.create(
        name: 'Orange',
        storeName: 'Store',
        quantity: 3,
        unitPrice: 2.0,
      );

      when(
        () => mockLocalStorageService.loadItems(),
      ).thenAnswer((_) async => [existingItem]);

      await repository.updateItem(nonExistentItem);

      verifyNever(() => mockLocalStorageService.saveItems(any()));
    });

    test('deleteItem removes item by id', () async {
      final item = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
        unitPrice: 1.0,
      );

      when(
        () => mockLocalStorageService.loadItems(),
      ).thenAnswer((_) async => [item]);
      when(
        () => mockLocalStorageService.saveItems(any()),
      ).thenAnswer((_) async {});

      await repository.deleteItem(item.id);

      final captured = verify(
        () => mockLocalStorageService.saveItems(captureAny()),
      ).captured;
      final savedItems = captured.first as List<FridgeItem>;
      expect(savedItems, isEmpty);
    });

    test('deleteItem does nothing when item not found', () async {
      final item = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
        unitPrice: 1.0,
      );

      when(
        () => mockLocalStorageService.loadItems(),
      ).thenAnswer((_) async => [item]);

      await repository.deleteItem('non-existent-id');

      verifyNever(() => mockLocalStorageService.saveItems(any()));
    });

    test('deleteAllItems calls storage deleteAllItems', () async {
      when(
        () => mockLocalStorageService.deleteAllItems(),
      ).thenAnswer((_) async {});

      await repository.deleteAllItems();

      verify(() => mockLocalStorageService.deleteAllItems()).called(1);
    });

    test('getAvailableItems returns only items with quantity > 0', () async {
      final availableItem = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
        unitPrice: 1.0,
      );
      final consumedItem = FridgeItem.create(
        name: 'Banana',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 0.5,
      ).copyWith(quantity: 0);

      when(
        () => mockLocalStorageService.loadItems(),
      ).thenAnswer((_) async => [availableItem, consumedItem]);

      final result = await repository.getAvailableItems();

      expect(result.length, 1);
      expect(result.first.name, 'Apple');
    });

    test('getGroupedItems groups items by receiptId', () async {
      final item1 = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
        unitPrice: 1.0,
        receiptId: 'receipt-1',
      );
      final item2 = FridgeItem.create(
        name: 'Banana',
        storeName: 'Store',
        quantity: 3,
        unitPrice: 0.5,
        receiptId: 'receipt-1',
      );
      final item3 = FridgeItem.create(
        name: 'Orange',
        storeName: 'Store',
        quantity: 2,
        unitPrice: 2.0,
        receiptId: 'receipt-2',
      );

      when(
        () => mockLocalStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2, item3]);

      final result = await repository.getGroupedItems();

      expect(result.length, 2);
      final receipt1Group = result.firstWhere((e) => e.key == 'receipt-1');
      final receipt2Group = result.firstWhere((e) => e.key == 'receipt-2');
      expect(receipt1Group.value.length, 2);
      expect(receipt2Group.value.length, 1);
    });

    test('getGroupedItems handles items without receiptId', () async {
      final itemWithReceipt = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
        unitPrice: 1.0,
        receiptId: 'receipt-1',
      );
      final itemWithoutReceipt = FridgeItem.create(
        name: 'Banana',
        storeName: 'Store',
        quantity: 3,
        unitPrice: 0.5,
      );

      when(
        () => mockLocalStorageService.loadItems(),
      ).thenAnswer((_) async => [itemWithReceipt, itemWithoutReceipt]);

      final result = await repository.getGroupedItems();

      expect(result.length, 2);
      final emptyKeyGroup = result.firstWhere((e) => e.key == '');
      expect(emptyKeyGroup.value.length, 1);
      expect(emptyKeyGroup.value.first.name, 'Banana');
    });
  });
}
