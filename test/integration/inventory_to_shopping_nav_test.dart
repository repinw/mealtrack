import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/home/presentation/home_menu.dart';
import 'package:mealtrack/features/home/presentation/widgets/home_navigation_bar.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_item_row.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_display_item.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_viewmodel.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:rxdart/rxdart.dart';

class FakeShoppingListRepository implements ShoppingListRepository {
  final _itemsSubject = BehaviorSubject<List<ShoppingListItem>>.seeded([]);

  @override
  Future<void> addItem(ShoppingListItem item) async {
    final current = _itemsSubject.value;
    _itemsSubject.add([...current, item]);
  }

  @override
  Future<void> deleteItem(String id) async {
    final current = _itemsSubject.value;
    _itemsSubject.add(current.where((item) => item.id != id).toList());
  }

  @override
  Future<void> updateItem(ShoppingListItem item) async {
    final current = _itemsSubject.value;
    _itemsSubject.add(current.map((i) => i.id == item.id ? item : i).toList());
  }

  @override
  Future<void> clearList() async {
    _itemsSubject.add([]);
  }

  @override
  Stream<List<ShoppingListItem>> watchItems() => _itemsSubject.stream;
}

void main() {
  testWidgets(
    'Integration: Add item from Inventory then verify in Shopping List',
    (tester) async {
      final testItem = FridgeItem(
        id: 'inv-1',
        name: 'Integration Apple',
        quantity: 1,
        storeName: 'Test Store',
        brand: 'Test Brand',
        entryDate: DateTime.now(),
        initialQuantity: 5,
      );

      final fakeShoppingRepo = FakeShoppingListRepository();

      // 2. Pump App
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryDisplayListProvider.overrideWith(
              (ref) => AsyncValue.data([InventoryProductItem(testItem.id)]),
            ),
            // Also override this so the row can find the item data
            fridgeItemProvider(testItem.id).overrideWithValue(testItem),
            shoppingListRepositoryProvider.overrideWithValue(fakeShoppingRepo),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeMenu(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100)); // Small wait

      expect(find.text('Integration Apple'), findsOneWidget);

      await tester.longPress(
        find.widgetWithText(InventoryItemRow, 'Integration Apple'),
      );

      // Pump to trigger confirmDismiss logic and SnackBar animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // Wait for snackbar

      // Verify SnackBar appears (confirmation that addItem was called)
      expect(find.byType(SnackBar), findsOneWidget);

      final navIcons = find.descendant(
        of: find.byType(HomeNavigationBar),
        matching: find.byType(Icon),
      );

      expect(navIcons, findsAtLeastNWidgets(2));
      await tester.tap(navIcons.at(1), warnIfMissed: false);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Integration Apple'), findsOneWidget);
      expect(find.text('Test Brand'), findsOneWidget);
    },
  );
}
