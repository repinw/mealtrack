import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/core/provider/local_storage_service.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockLocalStorageService mockStorageService;
  late ProviderContainer container;

  setUp(() {
    mockStorageService = MockLocalStorageService();
    container = ProviderContainer(
      overrides: [
        localStorageServiceProvider.overrideWithValue(mockStorageService),
      ],
    );
    registerFallbackValue(<FridgeItem>[]);
  });

  tearDown(() {
    container.dispose();
  });

  group('FridgeItems Notifier', () {
    final fixedDate = DateTime(2023, 1, 1);
    final item1 = FridgeItem.create(
      name: 'Item 1',
      storeName: 'Store A',
      quantity: 1,
      now: () => fixedDate,
    );
    final item2 = FridgeItem.create(
      name: 'Item 2',
      storeName: 'Store B',
      quantity: 2,
      now: () => fixedDate,
    );

    test('build loads items from storage', () async {
      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2]);

      final items = await container.read(fridgeItemsProvider.future);

      expect(items, [item1, item2]);
      verify(() => mockStorageService.loadItems()).called(1);
    });

    test('reload re-fetches items from storage', () async {
      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1]);

      await container.read(fridgeItemsProvider.future);

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2]);

      await container.read(fridgeItemsProvider.notifier).reload();

      final items = await container.read(fridgeItemsProvider.future);
      expect(items, [item1, item2]);
      verify(() => mockStorageService.loadItems()).called(2);
    });

    test('addItems appends items to existing list and saves', () async {
      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item2]);
      when(() => mockStorageService.saveItems(any())).thenAnswer((_) async {});

      await container.read(fridgeItemsProvider.notifier).addItems([item1]);

      verify(() => mockStorageService.loadItems()).called(2);
      verify(() => mockStorageService.saveItems([item2, item1])).called(1);
    });

    test('updateItem updates specific item and saves list', () async {
      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2]);
      when(() => mockStorageService.saveItems(any())).thenAnswer((_) async {});

      await container.read(fridgeItemsProvider.future);

      final updatedItem1 = item1.copyWith(quantity: 5);
      await container
          .read(fridgeItemsProvider.notifier)
          .updateItem(updatedItem1);

      verify(
        () => mockStorageService.saveItems([updatedItem1, item2]),
      ).called(1);
    });

    test('updateItem does nothing if item not found', () async {
      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1]);

      await container.read(fridgeItemsProvider.future);

      final newItem = FridgeItem.create(name: 'New', storeName: 'Store');

      await container.read(fridgeItemsProvider.notifier).updateItem(newItem);

      verifyNever(() => mockStorageService.saveItems(any()));
    });

    test('updateQuantity updates quantity and handles consumption', () async {
      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1]);
      when(() => mockStorageService.saveItems(any())).thenAnswer((_) async {});

      await container.read(fridgeItemsProvider.future);

      await container
          .read(fridgeItemsProvider.notifier)
          .updateQuantity(item1, -1);

      final captured = verify(
        () => mockStorageService.saveItems(captureAny()),
      ).captured;
      final savedList = captured.first as List<FridgeItem>;
      expect(savedList.first.quantity, 0);
      expect(savedList.first.isConsumed, true);
    });

    test('updateQuantity revives consumed item', () async {
      final consumptionDate = DateTime.now();
      final item = FridgeItem.create(
        name: 'Item',
        storeName: 'Store',
        quantity: 1,
      ).copyWith(isConsumed: true, consumptionDate: consumptionDate);

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item]);
      when(() => mockStorageService.saveItems(any())).thenAnswer((_) async {});

      await container.read(fridgeItemsProvider.future);
      await container
          .read(fridgeItemsProvider.notifier)
          .updateQuantity(item, 1);

      final captured = verify(
        () => mockStorageService.saveItems(captureAny()),
      ).captured;
      final saved = captured.first as List<FridgeItem>;
      expect(saved.first.quantity, 2);
      expect(saved.first.isConsumed, false);
      expect(saved.first.consumptionDate, consumptionDate);
    });

    test('updateQuantity clamps negative quantity to 0 and consumes', () async {
      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item2]);
      when(() => mockStorageService.saveItems(any())).thenAnswer((_) async {});

      await container.read(fridgeItemsProvider.future);

      await container
          .read(fridgeItemsProvider.notifier)
          .updateQuantity(item2, -5);

      final captured = verify(
        () => mockStorageService.saveItems(captureAny()),
      ).captured;
      final savedList = captured.first as List<FridgeItem>;
      expect(savedList.first.quantity, 0);
      expect(savedList.first.isConsumed, true);
    });
  });

  group('InventoryFilter', () {
    test('initial state is false', () {
      final filter = container.read(inventoryFilterProvider);
      expect(filter, false);
    });

    test('toggle switches state', () {
      container.read(inventoryFilterProvider.notifier).toggle();
      expect(container.read(inventoryFilterProvider), true);
      container.read(inventoryFilterProvider.notifier).toggle();
      expect(container.read(inventoryFilterProvider), false);
    });
  });

  group('availableFridgeItems', () {
    test('returns only items with quantity > 0', () async {
      final item1 = FridgeItem.create(
        name: 'A',
        storeName: 'S',
        quantity: 1,
        now: () => DateTime.now(),
      );
      final item2 = FridgeItem.create(
        name: 'B',
        storeName: 'S',
        quantity: 1,
        now: () => DateTime.now(),
      ).copyWith(quantity: 0);

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2]);

      final available = await container.read(
        availableFridgeItemsProvider.future,
      );
      expect(available.length, 1);
      expect(available.first.name, 'A');
    });
  });

  group('groupedFridgeItems', () {
    test('groups items by receiptId', () async {
      final item1 = FridgeItem.create(
        name: 'A',
        storeName: 'Store1',
        receiptId: 'R1',
      );
      final item2 = FridgeItem.create(
        name: 'B',
        storeName: 'Store1',
        receiptId: 'R1',
      );
      final item3 = FridgeItem.create(
        name: 'C',
        storeName: 'Store1',
        receiptId: 'R2',
      );
      final item4 = FridgeItem.create(
        name: 'D',
        storeName: 'Store2',
        // receiptId is null
      );

      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item1, item2, item3, item4]);

      final grouped = await container.read(groupedFridgeItemsProvider.future);

      expect(grouped.length, 3);
      expect(grouped.firstWhere((e) => e.key == 'R1').value.length, 2);
      expect(grouped.firstWhere((e) => e.key == 'R2').value.length, 1);
      expect(grouped.firstWhere((e) => e.key == 'null').value.length, 1);
    });
  });
}
