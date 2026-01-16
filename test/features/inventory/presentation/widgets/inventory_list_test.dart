import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list.dart';

import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_viewmodel.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_display_item.dart';

import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  List<String> archivedReceiptIds = [];

  MockFridgeItems(this.items);

  @override
  Stream<List<FridgeItem>> build() => Stream.value(items);

  @override
  Future<void> archiveReceipt(String receiptId) async {
    archivedReceiptIds.add(receiptId);
  }
}

class MockCollapsedReceiptGroups extends CollapsedReceiptGroups {
  @override
  Future<Set<String>> build() async => {};
}

void main() {
  Widget createWidgetUnderTest({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('de'),
        home: Scaffold(body: InventoryList()),
      ),
    );
  }

  testWidgets('InventoryList shows loading indicator', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => const AsyncValue.loading(),
          ),
        ],
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('InventoryList shows error message', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => const AsyncValue.error('Failed', StackTrace.empty),
          ),
        ],
      ),
    );

    expect(find.text('Error: Failed'), findsOneWidget);
  });

  testWidgets(
    'InventoryList shows no available items message when empty and filtering available',
    (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          overrides: [
            inventoryDisplayListProvider.overrideWith(
              (ref) => const AsyncValue.data([]),
            ),
            inventoryFilterProvider.overrideWith(
              () => MockInventoryFilter(InventoryFilterType.available),
            ),
          ],
        ),
      );
      expect(find.text('Keine verfügbaren Artikel'), findsOneWidget);
    },
  );

  testWidgets(
    'InventoryList shows no items found message when empty and not filtering',
    (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          overrides: [
            inventoryDisplayListProvider.overrideWith(
              (ref) => const AsyncValue.data([]),
            ),
            inventoryFilterProvider.overrideWith(
              () => MockInventoryFilter(InventoryFilterType.all),
            ),
          ],
        ),
      );
      expect(find.text('Keine Artikel gefunden'), findsOneWidget);
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
      const InventoryProductItem('1'),
      const InventorySpacerItem(),
    ];

    await tester.pumpWidget(
      createWidgetUnderTest(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => AsyncValue.data(items),
          ),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilter(InventoryFilterType.all),
          ),
          fridgeItemsProvider.overrideWith(() => MockFridgeItems([item1])),
        ],
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
        const InventoryProductItem('1'),
        const InventorySpacerItem(),
      ];

      await tester.pumpWidget(
        createWidgetUnderTest(
          overrides: [
            inventoryDisplayListProvider.overrideWith(
              (ref) => AsyncValue.data(items),
            ),
            inventoryFilterProvider.overrideWith(
              () => MockInventoryFilter(InventoryFilterType.all),
            ),
            fridgeItemsProvider.overrideWith(() => mockFridgeItems),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Archivieren'), findsOneWidget);
      expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
    },
  );

  testWidgets('Tapping archive button calls archiveReceipt', (tester) async {
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
      const InventoryProductItem('1'),
      const InventorySpacerItem(),
    ];

    await tester.pumpWidget(
      createWidgetUnderTest(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => AsyncValue.data(items),
          ),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilter(InventoryFilterType.all),
          ),
          fridgeItemsProvider.overrideWith(() => mockFridgeItems),
        ],
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Archivieren'));
    await tester.pumpAndSettle();

    expect(mockFridgeItems.archivedReceiptIds, contains('receipt-1'));
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
      const InventoryProductItem('1'),
      const InventorySpacerItem(),
    ];

    await tester.pumpWidget(
      createWidgetUnderTest(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => AsyncValue.data(items),
          ),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilter(InventoryFilterType.all),
          ),
          fridgeItemsProvider.overrideWith(() => MockFridgeItems([item1])),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Archivieren'), findsNothing);
    expect(find.byIcon(Icons.archive_outlined), findsNothing);
  });

  testWidgets('Tapping archived section header toggles expansion state', (
    tester,
  ) async {
    final archivedItem = createItem('archived-1', quantity: 0).copyWith(
      isArchived: true,
      receiptId: 'receipt-1',
      storeName: 'Archived Store',
    );
    final mockFridgeItems = MockFridgeItems([archivedItem]);

    await tester.pumpWidget(
      createWidgetUnderTest(
        overrides: [
          fridgeItemsProvider.overrideWith(() => mockFridgeItems),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilter(InventoryFilterType.all),
          ),
          fridgeItemProvider('archived-1').overrideWithValue(archivedItem),
          collapsedReceiptGroupsProvider.overrideWith(
            () => MockCollapsedReceiptGroups(),
          ),
        ],
      ),
    );

    // Initial state: Header visible, Item hidden (default collapsed)
    // "1 archivierte Kassenbons" or similar.
    expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
    expect(find.text('Item archived-1'), findsNothing);

    // Tap header
    final headerIcon = find.byIcon(Icons.archive_outlined);
    final headerInkWell = find.ancestor(
      of: headerIcon,
      matching: find.byType(InkWell),
    );

    await tester.tap(headerInkWell);
    await tester.pumpAndSettle();

    // Verification: Item should now be visible
    expect(find.text('Item archived-1'), findsOneWidget);

    // Tap header again to collapse
    await tester.tap(headerInkWell);
    await tester.pumpAndSettle();

    // Verification: Item should be hidden again
    expect(find.text('Item archived-1'), findsNothing);
  });
}
