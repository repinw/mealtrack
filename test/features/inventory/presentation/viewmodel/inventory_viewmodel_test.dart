import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_viewmodel.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_display_item.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mealtrack/core/provider/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  group('InventoryViewModel', () {
    test('initial state is AsyncData(null)', () {
      final container = makeContainer();
      final state = container.read(inventoryViewModelProvider);
      expect(state, const AsyncData<void>(null));
    });

    test('deleteAllItems calls repository and invalidates providers', () async {
      final initialItem = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Test Store',
        quantity: 1,
        now: () => DateTime.now(),
      );

      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([initialItem]));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      container.listen(archivedItemsExpandedProvider, (_, _) {});

      await container.read(fridgeItemsProvider.future);

      when(() => mockRepository.deleteAllItems()).thenAnswer((_) async {});
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([]));

      await container
          .read(inventoryViewModelProvider.notifier)
          .deleteAllItems();

      verify(() => mockRepository.deleteAllItems()).called(1);

      final newItems = await container.read(fridgeItemsProvider.future);
      expect(newItems, isEmpty);
    });

    test('deleteItem calls repository and updates state correctly', () async {
      final item1 = FridgeItem.create(
        name: 'Item 1',
        storeName: 'Store',
        quantity: 2,
        unitPrice: 10.0,
      );
      final item2 = FridgeItem.create(
        name: 'Item 2',
        storeName: 'Store',
        quantity: 3,
        unitPrice: 5.0,
      );

      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item1, item2]));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      container.listen(archivedItemsExpandedProvider, (_, _) {});

      await container.read(fridgeItemsProvider.future);

      when(() => mockRepository.deleteItem(item1.id)).thenAnswer((_) async {});
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item2]));

      await container
          .read(inventoryViewModelProvider.notifier)
          .deleteItem(item1.id);

      verify(() => mockRepository.deleteItem(item1.id)).called(1);

      final currentItems = await container.read(fridgeItemsProvider.future);
      expect(currentItems, hasLength(1));
      expect(currentItems.first.id, item2.id);
    });
  });

  group('inventoryDisplayListProvider', () {
    final fixedDate = DateTime(2023, 1, 1, 12, 0, 0);
    final sharedReceiptId = 'receipt-123';
    final item1 = FridgeItem.create(
      name: 'Apple',
      storeName: 'Store A',
      quantity: 5,
      now: () => fixedDate,
    ).copyWith(receiptId: sharedReceiptId);
    final item2 = FridgeItem.create(
      name: 'Banana',
      storeName: 'Store A',
      quantity: 1,
      now: () => fixedDate,
    ).copyWith(quantity: 0, isConsumed: true, receiptId: sharedReceiptId);
    final item3 = FridgeItem.create(
      name: 'Carrot',
      storeName: 'Store B',
      quantity: 2,
      now: () => fixedDate,
    ).copyWith(receiptId: 'receipt-456');

    test(
      'returns grouped items including consumed ones when filter is disabled',
      () async {
        when(
          () => mockRepository.watchItems(),
        ).thenAnswer((_) => Stream.value([item1, item2, item3]));

        final container = makeContainer();
        container.listen(fridgeItemsProvider, (_, _) {});
        container.listen(archivedItemsExpandedProvider, (_, _) {});

        await container.read(fridgeItemsProvider.future);

        final displayListAsync = container.read(inventoryDisplayListProvider);
        final displayList = displayListAsync.value!;

        expect(displayList.length, 7);

        expect(displayList[0], isA<InventoryHeaderItem>());
        expect((displayList[0] as InventoryHeaderItem).storeName, 'Store A');
        expect(displayList[1], isA<InventoryProductItem>());
        expect((displayList[1] as InventoryProductItem).itemId, item1.id);
        expect(displayList[2], isA<InventoryProductItem>());
        expect((displayList[2] as InventoryProductItem).itemId, item2.id);
        expect(displayList[3], isA<InventorySpacerItem>());

        expect(displayList[4], isA<InventoryHeaderItem>());
        expect((displayList[4] as InventoryHeaderItem).storeName, 'Store B');
        expect(displayList[5], isA<InventoryProductItem>());
        expect((displayList[5] as InventoryProductItem).itemId, item3.id);
        expect(displayList[6], isA<InventorySpacerItem>());
      },
    );

    test('returns only available items when filter is enabled', () async {
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item1, item2, item3]));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      container.listen(archivedItemsExpandedProvider, (_, _) {});

      container
          .read(inventoryFilterProvider.notifier)
          .setFilter(InventoryFilterType.available);

      await container.read(fridgeItemsProvider.future);

      final displayListAsync = container.read(inventoryDisplayListProvider);
      final displayList = displayListAsync.value!;

      expect(displayList.length, 6);

      expect(displayList[0], isA<InventoryHeaderItem>());
      expect((displayList[0] as InventoryHeaderItem).storeName, 'Store A');
      expect(displayList[1], isA<InventoryProductItem>());
      expect((displayList[1] as InventoryProductItem).itemId, item1.id);
      expect(displayList[2], isA<InventorySpacerItem>());

      expect(displayList[3], isA<InventoryHeaderItem>());
      expect((displayList[3] as InventoryHeaderItem).storeName, 'Store B');
      expect(displayList[4], isA<InventoryProductItem>());
      expect((displayList[4] as InventoryProductItem).itemId, item3.id);
      expect(displayList[5], isA<InventorySpacerItem>());
    });

    test('returns only empty items when filter is empty', () async {
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item1, item2, item3]));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      container.listen(archivedItemsExpandedProvider, (_, _) {});

      container
          .read(inventoryFilterProvider.notifier)
          .setFilter(InventoryFilterType.consumed);

      await container.read(fridgeItemsProvider.future);

      final displayListAsync = container.read(inventoryDisplayListProvider);
      final displayList = displayListAsync.value!;

      expect(displayList.length, 3);

      expect(displayList[0], isA<InventoryHeaderItem>());
      expect((displayList[0] as InventoryHeaderItem).storeName, 'Store A');
      expect(displayList[1], isA<InventoryProductItem>());
      expect(
        (displayList[1] as InventoryProductItem).itemId,
        item2.id,
      ); // item2 is the empty one
      expect(displayList[2], isA<InventorySpacerItem>());

      // Store B header should NOT be present because item3 is available (quantity 2) and we filter for empty
    });

    test(
      'does not generate header if all items in group are filtered out',
      () async {
        when(
          () => mockRepository.watchItems(),
        ).thenAnswer((_) => Stream.value([item1, item2, item3]));

        final container = makeContainer();
        container.listen(fridgeItemsProvider, (_, _) {});
        container.listen(archivedItemsExpandedProvider, (_, _) {});

        // Set to Empty filter
        container
            .read(inventoryFilterProvider.notifier)
            .setFilter(InventoryFilterType.consumed);

        await container.read(fridgeItemsProvider.future);

        final displayListAsync = container.read(inventoryDisplayListProvider);
        final displayList = displayListAsync.value!;

        final storeNames = displayList
            .whereType<InventoryHeaderItem>()
            .map((e) => e.storeName)
            .toList();

        expect(storeNames, contains('Store A'));
        expect(storeNames, isNot(contains('Store B')));
      },
    );

    test('returns empty list when no items exist', () async {
      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      container.listen(archivedItemsExpandedProvider, (_, _) {});

      await container.read(fridgeItemsProvider.future);

      final displayListAsync = container.read(inventoryDisplayListProvider);
      final displayList = displayListAsync.value!;

      expect(displayList, isEmpty);
    });

    test(
      'groups items with null receiptId together and shows valid header',
      () async {
        final fixedDate = DateTime(2023, 6, 15, 10, 30, 0);
        final itemWithNullReceipt1 = FridgeItem.create(
          name: 'Milk',
          storeName: 'Local Shop',
          quantity: 2,
          now: () => fixedDate,
        );
        final itemWithNullReceipt2 = FridgeItem.create(
          name: 'Bread',
          storeName: 'Local Shop',
          quantity: 1,
          now: () => fixedDate,
        );
        final itemWithReceipt = FridgeItem.create(
          name: 'Apple',
          storeName: 'Supermarket',
          quantity: 3,
          now: () => fixedDate,
        ).copyWith(receiptId: 'receipt-abc');

        when(() => mockRepository.watchItems()).thenAnswer(
          (_) => Stream.value([
            itemWithNullReceipt1,
            itemWithNullReceipt2,
            itemWithReceipt,
          ]),
        );

        final container = makeContainer();
        container.listen(fridgeItemsProvider, (_, _) {});
        container.listen(archivedItemsExpandedProvider, (_, _) {});

        await container.read(fridgeItemsProvider.future);

        final displayListAsync = container.read(inventoryDisplayListProvider);
        final displayList = displayListAsync.value!;

        expect(displayList.length, 7);

        expect(displayList[0], isA<InventoryHeaderItem>());
        final header1 = displayList[0] as InventoryHeaderItem;
        expect(header1.storeName, 'Local Shop');
        expect(header1.entryDate, fixedDate);
        expect(displayList[1], isA<InventoryProductItem>());
        expect(displayList[2], isA<InventoryProductItem>());
        expect(displayList[3], isA<InventorySpacerItem>());

        expect(displayList[4], isA<InventoryHeaderItem>());
        final header2 = displayList[4] as InventoryHeaderItem;
        expect(header2.storeName, 'Supermarket');
      },
    );

    test('items with empty string receiptId grouped same as null', () async {
      final fixedDate = DateTime(2023, 6, 15);
      final itemWithNullReceipt = FridgeItem.create(
        name: 'Item A',
        storeName: 'Store',
        quantity: 1,
        now: () => fixedDate,
      );
      final itemWithEmptyReceipt = FridgeItem.create(
        name: 'Item B',
        storeName: 'Store',
        quantity: 1,
        now: () => fixedDate,
      ).copyWith(receiptId: '');

      when(() => mockRepository.watchItems()).thenAnswer(
        (_) => Stream.value([itemWithNullReceipt, itemWithEmptyReceipt]),
      );

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      container.listen(archivedItemsExpandedProvider, (_, _) {});

      await container.read(fridgeItemsProvider.future);

      final displayListAsync = container.read(inventoryDisplayListProvider);
      final displayList = displayListAsync.value!;

      expect(displayList.length, 4);
      expect(displayList[0], isA<InventoryHeaderItem>());
      expect(displayList[1], isA<InventoryProductItem>());
      expect(displayList[2], isA<InventoryProductItem>());
      expect(displayList[3], isA<InventorySpacerItem>());
    });
  });

  group('Collapsing Logic', () {
    final fixedDate = DateTime(2023, 1, 1);
    final item1 = FridgeItem.create(
      name: 'Item 1',
      storeName: 'Store',
      receiptId: 'R1',
      now: () => fixedDate,
    );
    final item2 = FridgeItem.create(
      name: 'Item 2',
      storeName: 'Store',
      receiptId: 'R1',
      now: () => fixedDate,
    );

    test('collapsed group shows only header and spacer', () async {
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([item1, item2]));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      container.listen(archivedItemsExpandedProvider, (_, _) {});
      container.listen(collapsedReceiptGroupsProvider, (_, _) {});

      await container.read(fridgeItemsProvider.future);
      await container.read(collapsedReceiptGroupsProvider.future);

      // Collapse the group
      container.read(collapsedReceiptGroupsProvider.notifier).collapse('R1');
      await container.pump();

      final displayListAsync = container.read(inventoryDisplayListProvider);
      final displayList = displayListAsync.value!;

      // Header + Spacer (Items are hidden)
      expect(
        displayList.length,
        2,
        reason: 'Expected 2 items, got ${displayList.length}',
      );
      expect(displayList[0], isA<InventoryHeaderItem>());
      final header = displayList[0] as InventoryHeaderItem;
      expect(header.receiptId, 'R1');
      expect(header.isCollapsed, isTrue);
      expect(displayList[1], isA<InventorySpacerItem>());
    });
  });

  group('Archived Section Visibility', () {
    final fixedDate = DateTime(2023, 1, 1);
    final activeItem = FridgeItem.create(
      name: 'Active',
      storeName: 'Store',
      receiptId: 'R1',
      now: () => fixedDate,
    );
    final archivedItem = FridgeItem.create(
      name: 'Archived',
      storeName: 'Store',
      receiptId: 'R2',
      now: () => fixedDate,
    ).copyWith(isArchived: true);

    test('shows archived section only when archived items exist', () async {
      // Case 1: Active and Archived items
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([activeItem, archivedItem]));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      container.listen(archivedItemsExpandedProvider, (_, _) {});
      await container.read(fridgeItemsProvider.future);

      var displayList = container.read(inventoryDisplayListProvider).value!;
      expect(displayList.any((i) => i is InventoryArchivedSectionItem), isTrue);

      // Case 2: Only Active items
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([activeItem]));
      // Trigger update
      await container.read(fridgeItemsProvider.notifier).reload();
      await container.read(fridgeItemsProvider.future);
      await container.read(collapsedReceiptGroupsProvider.future);
      await container.read(collapsedReceiptGroupsProvider.future);
      await container.pump();

      displayList = container.read(inventoryDisplayListProvider).value!;
      expect(
        displayList.any((i) => i is InventoryArchivedSectionItem),
        isFalse,
      );
    });

    test('archived section contents shown only when expanded', () async {
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([archivedItem]));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      container.listen(archivedItemsExpandedProvider, (_, _) {});
      await container.read(fridgeItemsProvider.future);
      await container.read(collapsedReceiptGroupsProvider.future);

      // Initially collapsed (default)
      var displayList = container.read(inventoryDisplayListProvider).value!;
      expect(displayList.length, 1);
      expect(displayList[0], isA<InventoryArchivedSectionItem>());
      expect(
        (displayList[0] as InventoryArchivedSectionItem).isExpanded,
        isFalse,
      );

      // Expand
      container.read(archivedItemsExpandedProvider.notifier).toggle();
      await container.pump();

      displayList = container.read(inventoryDisplayListProvider).value!;
      // Section Item + Header + Item + Spacer
      expect(
        displayList.length,
        4,
        reason:
            'Expected 4 items, got ${displayList.map((e) => e.runtimeType).toList()}',
      );
      expect(displayList[0], isA<InventoryArchivedSectionItem>());
      expect(
        (displayList[0] as InventoryArchivedSectionItem).isExpanded,
        isTrue,
      );
      expect(displayList[1], isA<InventoryHeaderItem>());
      expect((displayList[1] as InventoryHeaderItem).isArchived, isTrue);
    });

    test(
      'does not show archived section when filter is available even if archived items exist',
      () async {
        when(
          () => mockRepository.watchItems(),
        ).thenAnswer((_) => Stream.value([activeItem, archivedItem]));

        final container = makeContainer();
        container.listen(fridgeItemsProvider, (_, _) {});
        container.listen(archivedItemsExpandedProvider, (_, _) {});
        container.listen(inventoryFilterProvider, (_, _) {});

        // Set Filter to Available
        container
            .read(inventoryFilterProvider.notifier)
            .setFilter(InventoryFilterType.available);

        expect(
          container.read(inventoryFilterProvider),
          InventoryFilterType.available,
        );

        await container.read(fridgeItemsProvider.future);

        var displayList = container.read(inventoryDisplayListProvider).value!;
        expect(
          displayList.any((i) => i is InventoryArchivedSectionItem),
          isFalse,
          reason: 'Archived section should be hidden when filter is available',
        );
      },
    );

    test(
      'does not show archived section when filter is consumed even if archived items exist',
      () async {
        when(
          () => mockRepository.watchItems(),
        ).thenAnswer((_) => Stream.value([activeItem, archivedItem]));

        final container = makeContainer();
        container.listen(fridgeItemsProvider, (_, _) {});
        container.listen(archivedItemsExpandedProvider, (_, _) {});
        container.listen(inventoryFilterProvider, (_, _) {});

        // Set Filter to Consumed
        container
            .read(inventoryFilterProvider.notifier)
            .setFilter(InventoryFilterType.consumed);

        await container.read(fridgeItemsProvider.future);

        var displayList = container.read(inventoryDisplayListProvider).value!;
        expect(
          displayList.any((i) => i is InventoryArchivedSectionItem),
          isFalse,
          reason: 'Archived section should be hidden when filter is consumed',
        );
      },
    );
  });

  group('Equatable display items', () {
    test('InventoryHeaderItem equality', () {
      final date = DateTime(2023, 1, 1);
      final header1 = InventoryHeaderItem(
        storeName: 'Store',
        entryDate: date,
        itemCount: 1,
        receiptId: '1',
        isFullyConsumed: false,
      );
      final header2 = InventoryHeaderItem(
        storeName: 'Store',
        entryDate: date,
        itemCount: 1,
        receiptId: '1',
        isFullyConsumed: false,
      );
      final header3 = InventoryHeaderItem(
        storeName: 'Other',
        entryDate: date,
        itemCount: 1,
        receiptId: '1',
        isFullyConsumed: false,
      );

      expect(header1, equals(header2));
      expect(header1, isNot(equals(header3)));
    });

    test('InventoryProductItem equality', () {
      const product1 = InventoryProductItem('item-1');
      const product2 = InventoryProductItem('item-1');
      const product3 = InventoryProductItem('item-2');

      expect(product1, equals(product2));
      expect(product1, isNot(equals(product3)));
      expect(product1.props, ['item-1']);
    });

    test('InventorySpacerItem equality', () {
      const spacer1 = InventorySpacerItem();
      const spacer2 = InventorySpacerItem();

      expect(spacer1, equals(spacer2));
      expect(spacer1.props, isEmpty);
    });
  });
}
