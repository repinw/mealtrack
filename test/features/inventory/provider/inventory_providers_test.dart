import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mocktail/mocktail.dart';

class MockFridgeRepository extends Mock implements FridgeRepository {}

void main() {
  late MockFridgeRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockFridgeRepository();
    container = ProviderContainer(
      overrides: [fridgeRepositoryProvider.overrideWithValue(mockRepository)],
    );
    registerFallbackValue(<FridgeItem>[]);
    registerFallbackValue(
      FridgeItem.create(name: 'fallback', storeName: 'fallback'),
    );
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

    test('build loads items from repository', () async {
      when(
        () => mockRepository.getItems(),
      ).thenAnswer((_) async => [item1, item2]);

      final items = await container.read(fridgeItemsProvider.future);

      expect(items, [item1, item2]);
      verify(() => mockRepository.getItems()).called(1);
    });

    test('reload re-fetches items from repository', () async {
      when(() => mockRepository.getItems()).thenAnswer((_) async => [item1]);

      await container.read(fridgeItemsProvider.future);

      when(
        () => mockRepository.getItems(),
      ).thenAnswer((_) async => [item1, item2]);

      await container.read(fridgeItemsProvider.notifier).reload();

      final items = await container.read(fridgeItemsProvider.future);
      expect(items, [item1, item2]);
      verify(() => mockRepository.getItems()).called(2);
    });

    test('addItems calls repository addItems and invalidates', () async {
      when(() => mockRepository.getItems()).thenAnswer((_) async => []);
      when(() => mockRepository.addItems(any())).thenAnswer((_) async {});

      await container.read(fridgeItemsProvider.notifier).addItems([item1]);

      verify(() => mockRepository.addItems([item1])).called(1);
    });

    test('updateItem calls repository updateItem and invalidates', () async {
      when(() => mockRepository.getItems()).thenAnswer((_) async => [item1]);
      when(() => mockRepository.updateItem(any())).thenAnswer((_) async {});

      final updatedItem1 = item1.copyWith(quantity: 5);
      await container
          .read(fridgeItemsProvider.notifier)
          .updateItem(updatedItem1);

      verify(() => mockRepository.updateItem(updatedItem1)).called(1);
    });

    test('deleteItemsByReceipt calls deleteItem for matching items', () async {
      final itemWithReceipt1 = FridgeItem.create(
        name: 'Item A',
        storeName: 'Store',
        quantity: 1,
        now: () => fixedDate,
        receiptId: 'receipt-1',
      );
      final itemWithReceipt2 = FridgeItem.create(
        name: 'Item B',
        storeName: 'Store',
        quantity: 1,
        now: () => fixedDate,
        receiptId: 'receipt-1',
      );
      final itemWithDifferentReceipt = FridgeItem.create(
        name: 'Item C',
        storeName: 'Store',
        quantity: 1,
        now: () => fixedDate,
        receiptId: 'receipt-2',
      );

      when(() => mockRepository.getItems()).thenAnswer(
        (_) async => [
          itemWithReceipt1,
          itemWithReceipt2,
          itemWithDifferentReceipt,
        ],
      );
      when(() => mockRepository.deleteItem(any())).thenAnswer((_) async {});

      await container.read(fridgeItemsProvider.future); // Ensure loaded

      await container
          .read(fridgeItemsProvider.notifier)
          .deleteItemsByReceipt('receipt-1');

      verify(() => mockRepository.deleteItem(itemWithReceipt1.id)).called(1);
      verify(() => mockRepository.deleteItem(itemWithReceipt2.id)).called(1);
      verifyNever(() => mockRepository.deleteItem(itemWithDifferentReceipt.id));
    });
  });

  group('InventoryFilter', () {
    test('initial state is all', () {
      final filter = container.read(inventoryFilterProvider);
      expect(filter, InventoryFilterType.all);
    });

    test('toggle switches state', () {
      container
          .read(inventoryFilterProvider.notifier)
          .setFilter(InventoryFilterType.available);
      expect(
        container.read(inventoryFilterProvider),
        InventoryFilterType.available,
      );

      container
          .read(inventoryFilterProvider.notifier)
          .setFilter(InventoryFilterType.all);
      expect(container.read(inventoryFilterProvider), InventoryFilterType.all);
    });
  });

  group('availableFridgeItems', () {
    test('returns only items with quantity > 0', () async {
      final item1 = FridgeItem.create(name: 'A', storeName: 'S', quantity: 1);
      final item2 = FridgeItem.create(
        name: 'B',
        storeName: 'S',
        quantity: 1,
      ).copyWith(quantity: 0);

      when(
        () => mockRepository.getItems(),
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
        storeName: 'S',
        receiptId: 'R1',
      );
      final item2 = FridgeItem.create(
        name: 'B',
        storeName: 'S',
        receiptId: 'R1',
      );
      final item3 = FridgeItem.create(
        name: 'C',
        storeName: 'S',
        receiptId: 'R2',
      );
      final item4 = FridgeItem.create(
        name: 'D',
        storeName: 'S',
      ); // Null receiptId

      when(
        () => mockRepository.getItems(),
      ).thenAnswer((_) async => [item1, item2, item3, item4]);

      final grouped = await container.read(groupedFridgeItemsProvider.future);

      expect(grouped.length, 3);
      expect(grouped.any((e) => e.key == 'R1' && e.value.length == 2), isTrue);
      expect(grouped.any((e) => e.key == 'R2' && e.value.length == 1), isTrue);
      expect(grouped.any((e) => e.key == '' && e.value.length == 1), isTrue);
    });
  });

  group('updateQuantity optimistic update', () {
    test('updates state immediately', () async {
      final item = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
      );

      when(() => mockRepository.getItems()).thenAnswer((_) async => [item]);
      when(() => mockRepository.updateQuantity(any(), any())).thenAnswer((
        _,
      ) async {
        await Future.delayed(const Duration(milliseconds: 50));
      });

      await container.read(fridgeItemsProvider.future);

      container.read(fridgeItemsProvider.notifier).updateQuantity(item, -1);

      final state = container.read(fridgeItemsProvider);
      expect(state.asData?.value.first.quantity, 4);
    });

    test('rolls back on error', () async {
      final item = FridgeItem.create(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
      );

      when(() => mockRepository.getItems()).thenAnswer((_) async => [item]);
      when(
        () => mockRepository.updateQuantity(any(), any()),
      ).thenThrow(Exception('Fail'));

      await container.read(fridgeItemsProvider.future);

      try {
        await container
            .read(fridgeItemsProvider.notifier)
            .updateQuantity(item, -1);
      } catch (_) {}

      final state = container.read(fridgeItemsProvider);
      expect(state.asData?.value.first.quantity, 5);
    });
  });

  group('inventoryStatsProvider', () {
    test('returns empty stats initially', () {
      final stats = container.read(inventoryStatsProvider);
      expect(stats, InventoryStats.empty);
    });

    test('calculates stats correctly for active items', () async {
      final item1 = FridgeItem.create(
        name: 'Item 1',
        storeName: 'Store A',
        quantity: 2,
        unitPrice: 1.5,
        receiptId: 'R1',
      );
      final item2 = FridgeItem.create(
        name: 'Item 2',
        storeName: 'Store B',
        quantity: 3,
        unitPrice: 2.0,
        receiptId: 'R2',
      );

      when(
        () => mockRepository.getItems(),
      ).thenAnswer((_) async => [item1, item2]);

      // Trigger load
      await container.read(fridgeItemsProvider.future);

      final stats = container.read(inventoryStatsProvider);

      expect(stats.articleCount, 5); // 2 + 3
      expect(stats.totalValue, 9.0); // (2 * 1.5) + (3 * 2.0) = 3 + 6 = 9
      expect(stats.scanCount, 2);
    });

    test('ignores items with quantity 0', () async {
      final item1 = FridgeItem.create(
        name: 'Item 1',
        storeName: 'Store A',
        quantity: 2,
        unitPrice: 10.0,
      );
      final item2 = FridgeItem.create(
        name: 'Item 2',
        storeName: 'Store B',
        quantity: 1,
        unitPrice: 5.0,
      ).copyWith(quantity: 0);

      when(
        () => mockRepository.getItems(),
      ).thenAnswer((_) async => [item1, item2]);

      await container.read(fridgeItemsProvider.future);

      final stats = container.read(inventoryStatsProvider);

      expect(stats.articleCount, 2);
      expect(stats.totalValue, 20.0);
    });

    test('counts unique receipts correctly', () async {
      final item1 = FridgeItem.create(
        name: 'A',
        storeName: 'S',
        quantity: 1,
        receiptId: 'R1',
      );
      final item2 = FridgeItem.create(
        name: 'B',
        storeName: 'S',
        quantity: 1,
        receiptId: 'R1',
      );
      final item3 = FridgeItem.create(
        name: 'C',
        storeName: 'S',
        quantity: 1,
        receiptId: 'R2',
      );
      final item4 = FridgeItem.create(
        name: 'D',
        storeName: 'S',
        quantity: 1,
      ); // No receipt

      when(
        () => mockRepository.getItems(),
      ).thenAnswer((_) async => [item1, item2, item3, item4]);

      await container.read(fridgeItemsProvider.future);

      final stats = container.read(inventoryStatsProvider);

      expect(stats.scanCount, 2); // R1 and R2
    });
  });
}
