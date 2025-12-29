import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list.dart';

import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_viewmodel.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/models/fridge_item.dart';

class MockInventoryFilter extends InventoryFilter {
  final bool initialValue;
  MockInventoryFilter(this.initialValue);
  @override
  bool build() => initialValue;
}

FridgeItem createItem(String id) => FridgeItem(
  id: id,
  name: 'Item $id',
  quantity: 1,
  storeName: 'Store',
  entryDate: DateTime(2023, 1, 1),
);

class MockFridgeItems extends FridgeItems {
  final List<FridgeItem> items;
  MockFridgeItems(this.items);
  @override
  Future<List<FridgeItem>> build() async => items;
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
              () => MockInventoryFilter(true),
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
              () => MockInventoryFilter(false),
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
      InventoryHeaderItem(storeName: 'Test Store', entryDate: entryDate),
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
            () => MockInventoryFilter(false),
          ),
          fridgeItemsProvider.overrideWith(() => MockFridgeItems([item1])),
        ],
        child: const MaterialApp(home: Scaffold(body: InventoryList())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
  });
}
