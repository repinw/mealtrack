import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mocktail/mocktail.dart';
import '../../../shared/test_helpers.dart';

class MockFridgeRepository extends Mock implements FridgeRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockFridgeRepository mockRepository;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockRepository = MockFridgeRepository();
    mockSharedPreferences = MockSharedPreferences();

    when(
      () => mockRepository.watchItems(),
    ).thenAnswer((_) => Stream.value(<FridgeItem>[]));
    registerFallbackValue(<FridgeItem>[]);
    registerFallbackValue(
      createTestFridgeItem(name: 'fallback', storeName: 'fallback'),
    );

    when(() => mockSharedPreferences.getStringList(any())).thenReturn(null);
    when(
      () => mockSharedPreferences.setStringList(any(), any()),
    ).thenAnswer((_) async => true);
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        fridgeRepositoryProvider.overrideWithValue(mockRepository),
        sharedPreferencesProvider.overrideWith(
          (ref) => Future.value(mockSharedPreferences),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('FridgeItems Notifier', () {
    final fixedDate = DateTime(2023, 1, 1);
    final item1 = createTestFridgeItem(
      name: 'Item 1',
      storeName: 'Store A',
      quantity: 1,
      now: () => fixedDate,
    );
    final item2 = createTestFridgeItem(
      name: 'Item 2',
      storeName: 'Store B',
      quantity: 2,
      now: () => fixedDate,
    );

    test('build loads items from repository', () async {
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item1, item2]));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});

      final items = await container.read(fridgeItemsProvider.future);

      expect(items, [item1, item2]);
      verify(() => mockRepository.watchItems()).called(1);
    });

    test('reload re-fetches items from repository', () async {
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item1]));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});

      await container.read(fridgeItemsProvider.future);

      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item1, item2]));

      await container.read(fridgeItemsProvider.notifier).reload();

      final items = await container.read(fridgeItemsProvider.future);
      expect(items, [item1, item2]);
      verify(() => mockRepository.watchItems()).called(2);
    });

    test('addItems calls repository addItems and invalidates', () async {
      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});

      when(() => mockRepository.addItems(any())).thenAnswer((_) async {});

      await container.read(fridgeItemsProvider.notifier).addItems([item1]);

      verify(() => mockRepository.addItems([item1])).called(1);
    });

    test('updateItem calls repository updateItem and invalidates', () async {
      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});

      when(() => mockRepository.updateItem(any())).thenAnswer((_) async {});

      final updatedItem1 = item1.copyWith(quantity: 5);
      await container
          .read(fridgeItemsProvider.notifier)
          .updateItem(updatedItem1);

      verify(() => mockRepository.updateItem(updatedItem1)).called(1);
    });

    test('deleteItemsByReceipt calls deleteItem for matching items', () async {
      final itemWithReceipt1 = createTestFridgeItem(
        name: 'Item A',
        storeName: 'Store',
        quantity: 1,
        now: () => fixedDate,
        receiptId: 'receipt-1',
      );
      final itemWithReceipt2 = createTestFridgeItem(
        name: 'Item B',
        storeName: 'Store',
        quantity: 1,
        now: () => fixedDate,
        receiptId: 'receipt-1',
      );
      final itemWithDifferentReceipt = createTestFridgeItem(
        name: 'Item C',
        storeName: 'Store',
        quantity: 1,
        now: () => fixedDate,
        receiptId: 'receipt-2',
      );

      // Set up mock BEFORE creating container
      when(() => mockRepository.watchItems()).thenAnswer(
        (_) => Stream.value([
          itemWithReceipt1,
          itemWithReceipt2,
          itemWithDifferentReceipt,
        ]),
      );
      when(() => mockRepository.deleteItem(any())).thenAnswer((_) async {});

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});

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
      final container = makeContainer();
      final filter = container.read(inventoryFilterProvider);
      expect(filter, InventoryFilterType.all);
    });

    test('toggle switches state', () {
      final container = makeContainer();
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
      final item1 = createTestFridgeItem(
        name: 'A',
        storeName: 'S',
        quantity: 1,
      );
      final item2 = createTestFridgeItem(
        name: 'B',
        storeName: 'S',
        quantity: 1,
      ).copyWith(quantity: 0);

      // Set up mock BEFORE creating container
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item1, item2]));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});

      final available = await container.read(
        availableFridgeItemsProvider.future,
      );
      expect(available.length, 1);
      expect(available.first.name, 'A');
    });
  });

  group('groupedFridgeItems', () {
    test('groups items by receiptId', () async {
      final item1 = createTestFridgeItem(
        name: 'A',
        storeName: 'S',
        receiptId: 'R1',
      );
      final item2 = createTestFridgeItem(
        name: 'B',
        storeName: 'S',
        receiptId: 'R1',
      );
      final item3 = createTestFridgeItem(
        name: 'C',
        storeName: 'S',
        receiptId: 'R2',
      );
      final item4 = createTestFridgeItem(
        name: 'D',
        storeName: 'S',
      ); // Null receiptId

      // Set up mock BEFORE creating container
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item1, item2, item3, item4]));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});

      final grouped = await container.read(groupedFridgeItemsProvider.future);

      expect(grouped.length, 3);
      expect(grouped.any((e) => e.key == 'R1' && e.value.length == 2), isTrue);
      expect(grouped.any((e) => e.key == 'R2' && e.value.length == 1), isTrue);
      expect(grouped.any((e) => e.key == '' && e.value.length == 1), isTrue);
    });
  });

  group('updateQuantity optimistic update', () {
    test('updates state immediately', () async {
      final item = createTestFridgeItem(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
      );

      // Set up mock BEFORE creating container
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item]));
      when(() => mockRepository.updateQuantity(any(), any())).thenAnswer((
        _,
      ) async {
        await Future.delayed(const Duration(milliseconds: 50));
      });

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});

      await container.read(fridgeItemsProvider.future);

      container.read(fridgeItemsProvider.notifier).updateQuantity(item, -1);

      final state = container.read(fridgeItemsProvider);
      expect(state.asData?.value.first.quantity, 4);
    });

    test('rolls back on error', () async {
      final item = createTestFridgeItem(
        name: 'Apple',
        storeName: 'Store',
        quantity: 5,
      );

      // Set up mock BEFORE creating container
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item]));
      when(
        () => mockRepository.updateQuantity(any(), any()),
      ).thenThrow(Exception('Fail'));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});

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
      final container = makeContainer();
      final stats = container.read(inventoryStatsProvider);
      expect(stats.articleCount, 0);
      expect(stats.scanCount, 0);
      expect(stats.totalValue, 0);
    });

    test('calculates stats correctly for active items', () async {
      final item1 = createTestFridgeItem(
        name: 'Item 1',
        storeName: 'Store A',
        quantity: 2,
        unitPrice: 1.5,
        receiptId: 'R1',
      );
      final item2 = createTestFridgeItem(
        name: 'Item 2',
        storeName: 'Store B',
        quantity: 3,
        unitPrice: 2.0,
        receiptId: 'R2',
      );

      // Set up mock BEFORE creating container
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item1, item2]));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});

      // Trigger load
      await container.read(fridgeItemsProvider.future);

      final stats = container.read(inventoryStatsProvider);

      expect(stats.articleCount, 5); // 2 + 3
      expect(stats.totalValue, 9.0); // (2 * 1.5) + (3 * 2.0) = 3 + 6 = 9
      expect(stats.scanCount, 2);
    });

    test('ignores items with quantity 0', () async {
      final item1 = createTestFridgeItem(
        name: 'Item 1',
        storeName: 'Store A',
        quantity: 2,
        unitPrice: 10.0,
      );
      final item2 = createTestFridgeItem(
        name: 'Item 2',
        storeName: 'Store B',
        quantity: 1,
        unitPrice: 5.0,
      ).copyWith(quantity: 0);

      // Set up mock BEFORE creating container
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item1, item2]));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});

      await container.read(fridgeItemsProvider.future);

      final stats = container.read(inventoryStatsProvider);

      expect(stats.articleCount, 2);
      expect(stats.totalValue, 20.0);
    });

    test('counts unique receipts correctly', () async {
      final item1 = createTestFridgeItem(
        name: 'A',
        storeName: 'S',
        quantity: 1,
        receiptId: 'R1',
      );
      final item2 = createTestFridgeItem(
        name: 'B',
        storeName: 'S',
        quantity: 1,
        receiptId: 'R1',
      );
      final item3 = createTestFridgeItem(
        name: 'C',
        storeName: 'S',
        quantity: 1,
        receiptId: 'R2',
      );
      final item4 = createTestFridgeItem(
        name: 'D',
        storeName: 'S',
        quantity: 1,
      ); // No receipt

      // Set up mock BEFORE creating container
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item1, item2, item3, item4]));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});

      await container.read(fridgeItemsProvider.future);

      final stats = container.read(inventoryStatsProvider);

      expect(stats.scanCount, 2); // R1 and R2
    });

    test('excludes consumed items from scanCount and articleCount', () async {
      final itemActive = createTestFridgeItem(
        name: 'Active',
        storeName: 'S',
        quantity: 1,
        receiptId: 'R1',
      );
      final itemConsumed = createTestFridgeItem(
        name: 'Consumed',
        storeName: 'S',
        quantity: 1,
        receiptId: 'R2',
      ).copyWith(quantity: 0);

      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([itemActive, itemConsumed]));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      await container.read(fridgeItemsProvider.future);

      final stats = container.read(inventoryStatsProvider);

      expect(stats.articleCount, 1);
      expect(stats.scanCount, 1); // Only R1 counts
    });

    test(
      'counts receipt once if it has both active and consumed items',
      () async {
        final item1 = createTestFridgeItem(
          name: 'Active',
          storeName: 'S',
          quantity: 1,
          receiptId: 'R1',
        );
        final item2 = createTestFridgeItem(
          name: 'Consumed',
          storeName: 'S',
          quantity: 1,
          receiptId: 'R1',
        ).copyWith(quantity: 0);

        when(
          () => mockRepository.watchItems(),
        ).thenAnswer((_) => Stream.value([item1, item2]));

        final container = makeContainer();
        container.listen(fridgeItemsProvider, (_, _) {});
        await container.read(fridgeItemsProvider.future);

        final stats = container.read(inventoryStatsProvider);

        expect(stats.articleCount, 1);
        expect(stats.scanCount, 1); // R1 counts because item1 is active
      },
    );
  });

  group('archiveReceipt and unarchiveReceipt state persistence', () {
    final fixedDate = DateTime(2023, 1, 1);
    final item = createTestFridgeItem(
      name: 'Item',
      storeName: 'Store',
      receiptId: 'R1',
      now: () => fixedDate,
    );

    test('always collapses on archive and expands on unarchive', () async {
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item]));
      when(
        () => mockRepository.updateItemsBatch(any()),
      ).thenAnswer((_) async {});

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      container.listen(collapsedReceiptGroupsProvider, (_, _) {});

      // Ensure data is loaded
      await container.read(fridgeItemsProvider.future);
      await container.read(collapsedReceiptGroupsProvider.future);

      // 1. Initially Expanded (not in collapsed set)
      expect(
        container
            .read(collapsedReceiptGroupsProvider)
            .asData
            ?.value
            .contains('R1'),
        isFalse,
      );

      // 2. Archive
      container.read(fridgeItemsProvider.notifier).archiveReceipt('R1');
      await container.pump(); // Pump to propagate state changes

      // Check item state updated
      final archivedItem = container.read(fridgeItemsProvider).value!.first;
      expect(archivedItem.isArchived, isTrue);

      // Check UI collapsed - Should simplify logic to always collapse
      expect(
        container
            .read(collapsedReceiptGroupsProvider)
            .asData
            ?.value
            .contains('R1'),
        isTrue,
      );

      // 3. Unarchive
      container.read(fridgeItemsProvider.notifier).unarchiveReceipt('R1');
      await container.pump();

      // Check item state restored
      final unarchivedItem = container.read(fridgeItemsProvider).value!.first;
      expect(unarchivedItem.isArchived, isFalse);

      // Check UI expanded (restored) - Should simplify logic to always expand
      expect(
        container
            .read(collapsedReceiptGroupsProvider)
            .asData
            ?.value
            .contains('R1'),
        isFalse,
      );
    });
  });

  group('archiveReceipt error handling', () {
    final fixedDate = DateTime(2023, 1, 1);
    final item = createTestFridgeItem(
      name: 'Item',
      storeName: 'Store',
      receiptId: 'R1',
      now: () => fixedDate,
    );

    test('rolls back state and restores collapsed state on error', () async {
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item]));
      when(
        () => mockRepository.updateItemsBatch(any()),
      ).thenAnswer((_) async => throw Exception('Network Error'));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      container.listen(collapsedReceiptGroupsProvider, (_, _) {});

      await container.read(fridgeItemsProvider.future);
      await container.read(collapsedReceiptGroupsProvider.future);

      expect(
        container
            .read(collapsedReceiptGroupsProvider)
            .asData
            ?.value
            .contains('R1'),
        isFalse,
      );

      container.read(fridgeItemsProvider.notifier).archiveReceipt('R1');

      await container.pump();

      final currentItem = container.read(fridgeItemsProvider).value!.first;
      expect(currentItem.isArchived, isFalse);
      expect(
        container
            .read(collapsedReceiptGroupsProvider)
            .asData
            ?.value
            .contains('R1'),
        isFalse,
      );
    });
  });

  group('unarchiveReceipt error handling', () {
    final fixedDate = DateTime(2023, 1, 1);
    final item = createTestFridgeItem(
      name: 'Item',
      storeName: 'Store',
      receiptId: 'R1',
      now: () => fixedDate,
    ).copyWith(isArchived: true);

    test('rolls back state on error', () async {
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item]));
      when(
        () => mockRepository.updateItemsBatch(any()),
      ).thenAnswer((_) async => throw Exception('Network Error'));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});

      await container.read(fridgeItemsProvider.future);

      // Trigger unarchive
      container.read(fridgeItemsProvider.notifier).unarchiveReceipt('R1');

      await container.pump();

      // Verify rollback:
      final currentItem = container.read(fridgeItemsProvider).value!.first;
      expect(currentItem.isArchived, isTrue);
    });

    test('verifies batch update call contains all items', () async {
      final item1 = createTestFridgeItem(
        name: 'A',
        storeName: 'S',
        receiptId: 'R1',
      ).copyWith(isArchived: true);
      final item2 = createTestFridgeItem(
        name: 'B',
        storeName: 'S',
        receiptId: 'R1',
      ).copyWith(isArchived: true);

      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item1, item2]));
      when(
        () => mockRepository.updateItemsBatch(any()),
      ).thenAnswer((_) async {});

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      await container.read(fridgeItemsProvider.future);

      container.read(fridgeItemsProvider.notifier).unarchiveReceipt('R1');
      await container.pump();

      final captured =
          verify(
                () => mockRepository.updateItemsBatch(captureAny()),
              ).captured.single
              as List<FridgeItem>;
      expect(captured.length, 2);
      expect(captured[0].id, item1.id);
      expect(captured[1].id, item2.id);
      expect(captured[0].isArchived, isFalse);
      expect(captured[1].isArchived, isFalse);
    });
  });
}
