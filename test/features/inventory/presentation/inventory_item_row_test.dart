import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/presentation/category_icon.dart';
import 'package:mealtrack/features/inventory/presentation/counter_pill.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_item_row.dart';
import 'package:mealtrack/features/inventory/presentation/item_details.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';

class MockFridgeItems extends TitleNotifier<List<FridgeItem>>
    with Mock
    implements FridgeItems {
  // Track updateQuantity calls manually since we need to override the method
  final List<(FridgeItem, int)> updateQuantityCalls = [];

  @override
  Future<List<FridgeItem>> build() async => [];

  // Override updateQuantity since it accesses state.asData which isn't set up
  @override
  Future<void> updateQuantity(FridgeItem item, int delta) async {
    updateQuantityCalls.add((item, delta));
  }

  @override
  Future<void> deleteAll() async {}

  @override
  Future<void> deleteItem(String id) async {}

  @override
  Future<void> addItems(List<FridgeItem> items) async {}

  @override
  Future<void> reload() async {}

  @override
  Future<void> updateItem(FridgeItem item) async {}
}

class TitleNotifier<T> extends AsyncNotifier<T> {
  @override
  Future<T> build() async => throw UnimplementedError();
}

class FakeFridgeItem extends Fake implements FridgeItem {}

void main() {
  late MockFridgeItems mockNotifier;

  setUpAll(() {
    registerFallbackValue(FakeFridgeItem());
  });

  final testItem = FridgeItem(
    id: '1',
    name: 'Test Apple',
    quantity: 5,
    storeName: 'Test Store',
    entryDate: DateTime.now(),
  );

  setUp(() {
    mockNotifier = MockFridgeItems();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        fridgeItemsProvider.overrideWith(() {
          return mockNotifier;
        }),
      ],
      child: MaterialApp(
        home: Scaffold(body: InventoryItemRow(itemId: testItem.id)),
      ),
    );
  }

  group('InventoryItemRow Tests', () {
    testWidgets('renders all child components correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeItemProvider(testItem.id).overrideWithValue(testItem),
            fridgeItemsProvider.overrideWith(
              () => mockNotifier,
            ), // For updateQuantity
          ],
          child: MaterialApp(
            home: Scaffold(body: InventoryItemRow(itemId: testItem.id)),
          ),
        ),
      );

      expect(find.byType(CategoryIcon), findsOneWidget);
      expect(find.byType(ItemDetails), findsOneWidget);
      expect(find.byType(CounterPill), findsOneWidget);

      final categoryIcon = tester.widget<CategoryIcon>(
        find.byType(CategoryIcon),
      );
      expect(categoryIcon.name, testItem.name);
    });

    testWidgets('calls updateQuantity on notifier when pill updates', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeItemProvider(testItem.id).overrideWithValue(testItem),
            fridgeItemsProvider.overrideWith(() => mockNotifier),
          ],
          child: MaterialApp(
            home: Scaffold(body: InventoryItemRow(itemId: testItem.id)),
          ),
        ),
      );

      final CounterPill counterPill = tester.widget(find.byType(CounterPill));
      counterPill.onUpdate(1);

      // Verify the call was tracked (can't use mocktail verify with overridden method)
      expect(mockNotifier.updateQuantityCalls.length, 1);
      expect(mockNotifier.updateQuantityCalls.first.$2, 1);
    });
  });
}
