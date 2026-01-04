import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/firestore_service.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFirestoreService extends Mock implements FirestoreService {}

void main() {
  late FridgeRepository repository;
  late MockFirestoreService mockFirestoreService;

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    repository = FridgeRepository(firestoreService: mockFirestoreService);
    registerFallbackValue(
      FridgeItem.create(name: 'fallback', storeName: 'fallback'),
    );
  });

  group('FridgeRepository', () {
    test('updateQuantity updates item via firestoreService', () async {
      final item = FridgeItem.create(
        name: 'TestItem',
        storeName: 'TestStore',
        quantity: 1,
        unitPrice: 1.0,
      );

      when(
        () => mockFirestoreService.updateItem(any()),
      ).thenAnswer((_) async {});

      await repository.updateQuantity(item, -1);

      final captured = verify(
        () => mockFirestoreService.updateItem(captureAny()),
      ).captured;
      final updatedItem = captured.first as FridgeItem;

      expect(updatedItem.quantity, 0);
      expect(updatedItem.isConsumed, true);
    });

    test('getItems returns items from service', () async {
      final items = [
        FridgeItem.create(name: 'Apple', storeName: 'Store', quantity: 5),
      ];
      when(
        () => mockFirestoreService.getItems(),
      ).thenAnswer((_) async => items);

      final result = await repository.getItems();

      expect(result, items);
      verify(() => mockFirestoreService.getItems()).called(1);
    });

    test('getItems rethrows exceptions', () async {
      when(
        () => mockFirestoreService.getItems(),
      ).thenThrow(Exception('Storage error'));

      expect(() => repository.getItems(), throwsException);
    });

    test('addItems uses batch to add items', () async {
      final newItem = FridgeItem.create(
        name: 'Banana',
        storeName: 'Store',
        quantity: 3,
      );
      final items = [newItem];

      when(
        () => mockFirestoreService.addItemsBatch(any()),
      ).thenAnswer((_) async {});

      await repository.addItems(items);

      verify(() => mockFirestoreService.addItemsBatch(items)).called(1);
    });

    test('updateItem calls updateItem on service', () async {
      final item = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
      );

      when(
        () => mockFirestoreService.updateItem(any()),
      ).thenAnswer((_) async {});

      await repository.updateItem(item);

      verify(() => mockFirestoreService.updateItem(item)).called(1);
    });

    test('deleteItem calls deleteItem on service', () async {
      const id = 'some-id';
      when(() => mockFirestoreService.deleteItem(id)).thenAnswer((_) async {});

      await repository.deleteItem(id);

      verify(() => mockFirestoreService.deleteItem(id)).called(1);
    });

    test('deleteAllItems calls deleteAllItems on service', () async {
      when(
        () => mockFirestoreService.deleteAllItems(),
      ).thenAnswer((_) async {});

      await repository.deleteAllItems();

      verify(() => mockFirestoreService.deleteAllItems()).called(1);
    });

    test('getAvailableItems returns filtered items', () async {
      final availableItem = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
      );
      final consumedItem = FridgeItem.create(
        name: 'Banana',
        storeName: 'Store',
        quantity: 1,
      ).copyWith(quantity: 0);

      when(
        () => mockFirestoreService.getItems(),
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
        receiptId: 'receipt-1',
      );
      final item2 = FridgeItem.create(
        name: 'Banana',
        storeName: 'Store',
        quantity: 3,
        receiptId: 'receipt-1',
      );
      final item3 = FridgeItem.create(
        name: 'Orange',
        storeName: 'Store',
        quantity: 2,
        receiptId: 'receipt-2',
      );

      when(
        () => mockFirestoreService.getItems(),
      ).thenAnswer((_) async => [item1, item2, item3]);

      final result = await repository.getGroupedItems();

      expect(result.length, 2);
    });

    test('addItems rethrows exceptions', () async {
      final item = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 1,
      );
      when(
        () => mockFirestoreService.addItemsBatch(any()),
      ).thenThrow(Exception('Add error'));

      expect(() => repository.addItems([item]), throwsException);
    });

    test('updateItem rethrows exceptions', () async {
      final item = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 1,
      );
      when(
        () => mockFirestoreService.updateItem(any()),
      ).thenThrow(Exception('Update error'));

      expect(() => repository.updateItem(item), throwsException);
    });

    test('updateQuantity rethrows exceptions', () async {
      final item = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 1,
      );
      when(
        () => mockFirestoreService.updateItem(any()),
      ).thenThrow(Exception('Quantity error'));

      expect(() => repository.updateQuantity(item, -1), throwsException);
    });

    test('deleteAllItems rethrows exceptions', () async {
      when(
        () => mockFirestoreService.deleteAllItems(),
      ).thenThrow(Exception('Delete all error'));

      expect(() => repository.deleteAllItems(), throwsException);
    });

    test('deleteItem rethrows exceptions', () async {
      when(
        () => mockFirestoreService.deleteItem(any()),
      ).thenThrow(Exception('Delete error'));

      expect(() => repository.deleteItem('some-id'), throwsException);
    });

    test('getAvailableItems rethrows exceptions', () async {
      when(
        () => mockFirestoreService.getItems(),
      ).thenThrow(Exception('Available error'));

      expect(() => repository.getAvailableItems(), throwsException);
    });

    test('getGroupedItems rethrows exceptions', () async {
      when(
        () => mockFirestoreService.getItems(),
      ).thenThrow(Exception('Grouped error'));

      expect(() => repository.getGroupedItems(), throwsException);
    });
  });
}
