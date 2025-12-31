import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list.dart';

import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_viewmodel.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/models/fridge_item.dart';

class MockInventoryFilter extends InventoryFilter {
  final InventoryFilterType initialValue;
  MockInventoryFilter(this.initialValue);
  @override
  InventoryFilterType build() => initialValue;

  @override
  void setFilter(InventoryFilterType type) => state = type;
}

FridgeItem createItem(String id, {int quantity = 1}) => FridgeItem(
  id: id,
  name: 'Item $id',
  quantity: quantity,
  storeName: 'Store',
  entryDate: DateTime(2023, 1, 1),
);

class MockFridgeItems extends FridgeItems {
  final List<FridgeItem> items;
  List<String> deletedReceiptIds = [];

  MockFridgeItems(this.items);

  @override
  Future<List<FridgeItem>> build() async => items;

  @override
  Future<void> deleteItemsByReceipt(String receiptId) async {
    deletedReceiptIds.add(receiptId);
  }
}

void main() {
  testWidgets('InventoryList shows loading indicator', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => const AsyncValue.loading(),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: InventoryList())),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('InventoryList shows error message', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => AsyncValue.error('Failed', StackTrace.empty),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: InventoryList())),
      ),
    );

    expect(find.text('Error: Failed'), findsOneWidget);
  });

  testWidgets(
    'InventoryList shows no available items message when empty and filtering available',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryDisplayListProvider.overrideWith(
              (ref) => const AsyncValue.data([]),
            ),
            inventoryFilterProvider.overrideWith(
              () => MockInventoryFilter(InventoryFilterType.available),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: InventoryList())),
        ),
      );

      expect(find.text(AppLocalizations.noAvailableItems), findsOneWidget);
    },
  );

  testWidgets(
    'InventoryList shows no items found message when empty and not filtering',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryDisplayListProvider.overrideWith(
              (ref) => const AsyncValue.data([]),
            ),
            inventoryFilterProvider.overrideWith(
              () => MockInventoryFilter(InventoryFilterType.all),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: InventoryList())),
        ),
      );

      expect(find.text(AppLocalizations.noItemsFound), findsOneWidget);
    },
  );

  testWidgets('InventoryList renders items correctly', (tester) async {
    final entryDate = DateTime(2023, 1, 1);
    final item1 = createItem('1');
    final items = [
      InventoryHeaderItem(
        storeName: 'Test Store',
        entryDate: entryDate,
        itemCount: 1,
        receiptId: '1',
        isFullyConsumed: false,
      ),
      InventoryProductItem('1'),
      const InventorySpacerItem(),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => AsyncValue.data(items),
          ),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilter(InventoryFilterType.all),
          ),
          fridgeItemsProvider.overrideWith(() => MockFridgeItems([item1])),
        ],
        child: const MaterialApp(home: Scaffold(body: InventoryList())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets(
    'InventoryList shows archive button when items are fully consumed',
    (tester) async {
      final entryDate = DateTime(2023, 1, 1);
      final item1 = createItem('1', quantity: 0);
      final mockFridgeItems = MockFridgeItems([item1]);
      final items = [
        InventoryHeaderItem(
          storeName: 'Test Store',
          entryDate: entryDate,
          itemCount: 1,
          receiptId: 'receipt-1',
          isFullyConsumed: true,
        ),
        InventoryProductItem('1'),
        const InventorySpacerItem(),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryDisplayListProvider.overrideWith(
              (ref) => AsyncValue.data(items),
            ),
            inventoryFilterProvider.overrideWith(
              () => MockInventoryFilter(InventoryFilterType.all),
            ),
            fridgeItemsProvider.overrideWith(() => mockFridgeItems),
          ],
          child: const MaterialApp(home: Scaffold(body: InventoryList())),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(AppLocalizations.archive), findsOneWidget);
      expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
    },
  );

  testWidgets('Tapping archive button calls deleteItemsByReceipt', (
    tester,
  ) async {
    final entryDate = DateTime(2023, 1, 1);
    final item1 = createItem('1', quantity: 0);
    final mockFridgeItems = MockFridgeItems([item1]);
    final items = [
      InventoryHeaderItem(
        storeName: 'Test Store',
        entryDate: entryDate,
        itemCount: 1,
        receiptId: 'receipt-1',
        isFullyConsumed: true,
      ),
      InventoryProductItem('1'),
      const InventorySpacerItem(),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => AsyncValue.data(items),
          ),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilter(InventoryFilterType.all),
          ),
          fridgeItemsProvider.overrideWith(() => mockFridgeItems),
        ],
        child: const MaterialApp(home: Scaffold(body: InventoryList())),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text(AppLocalizations.archive));
    await tester.pumpAndSettle();

    expect(mockFridgeItems.deletedReceiptIds, contains('receipt-1'));
  });

  testWidgets('Archive button is not shown when items are not fully consumed', (
    tester,
  ) async {
    final entryDate = DateTime(2023, 1, 1);
    final item1 = createItem('1', quantity: 1);
    final items = [
      InventoryHeaderItem(
        storeName: 'Test Store',
        entryDate: entryDate,
        itemCount: 1,
        receiptId: 'receipt-1',
        isFullyConsumed: false,
      ),
      InventoryProductItem('1'),
      const InventorySpacerItem(),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => AsyncValue.data(items),
          ),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilter(InventoryFilterType.all),
          ),
          fridgeItemsProvider.overrideWith(() => MockFridgeItems([item1])),
        ],
        child: const MaterialApp(home: Scaffold(body: InventoryList())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(AppLocalizations.archive), findsNothing);
    expect(find.byIcon(Icons.archive_outlined), findsNothing);
  });
}
