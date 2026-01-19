import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/shopping_list_item_row.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/action_button.dart';

// Fake Repo for toggle
class FakeShoppingListRepository implements ShoppingListRepository {
  ShoppingListItem? updatedItem;

  List<ShoppingListItem> items = [];

  @override
  Stream<List<ShoppingListItem>> watchItems() => Stream.value(items);
  @override
  Future<void> addItem(ShoppingListItem item) async {}
  @override
  Future<void> deleteItem(String id) async {}
  @override
  Future<void> updateItem(ShoppingListItem item) async {
    updatedItem = item;
  }

  @override
  Future<void> clearList() async {}
}

void main() {
  testWidgets('renders item details correctly', (tester) async {
    const item = ShoppingListItem(
      id: '1',
      name: 'Milk',
      brand: 'FarmFresh',
      quantity: 2,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProviderScope(child: ShoppingListItemRow(item: item)),
        ),
      ),
    );

    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('FarmFresh'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.byType(ActionButton), findsNWidgets(2)); // + and -
  });

  testWidgets('toggling checkbox updates item', (tester) async {
    const item = ShoppingListItem(id: '1', name: 'Milk');
    final repository = FakeShoppingListRepository();
    repository.items = [item];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ShoppingListItemRow(item: item)),
        ),
      ),
    );

    // Find and tap checkbox (now on the left)
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    // Verify repository update
    expect(repository.updatedItem!.isChecked, true);
  });

  testWidgets('tapping plus button increases quantity', (tester) async {
    const item = ShoppingListItem(id: '1', name: 'Milk', quantity: 1);
    final repository = FakeShoppingListRepository();
    repository.items = [item];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ShoppingListItemRow(item: item)),
        ),
      ),
    );

    // Tap + button (second ActionButton)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(repository.updatedItem!.quantity, 2);
  });
}
