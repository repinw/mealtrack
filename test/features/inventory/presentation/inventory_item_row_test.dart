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

class MockFridgeItems extends Mock implements FridgeItems {}

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
      overrides: [fridgeItemsProvider.overrideWith(() => mockNotifier)],
      child: MaterialApp(
        home: Scaffold(body: InventoryItemRow(item: testItem)),
      ),
    );
  }

  group('InventoryItemRow Tests', () {
    testWidgets('renders all child components correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CategoryIcon), findsOneWidget);
      expect(find.byType(ItemDetails), findsOneWidget);
      expect(find.byType(CounterPill), findsOneWidget);

      final categoryIcon = tester.widget<CategoryIcon>(
        find.byType(CategoryIcon),
      );
      expect(categoryIcon.name, testItem.name);
    });

    testWidgets('shows SnackBar when updateQuantity fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockNotifier.updateQuantity(any(), any()),
      ).thenAnswer((_) => Future.error(Exception('Network error')));

      await tester.pumpWidget(createWidgetUnderTest());

      final CounterPill counterPill = tester.widget(find.byType(CounterPill));
      counterPill.onUpdate(1);

      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Failed to update item. Please try again.'),
        findsOneWidget,
      );
    }, skip: true); 

    testWidgets('passes correct out-of-stock state to children', (
      WidgetTester tester,
    ) async {
      final outOfStockItem = FridgeItem(
        id: '2',
        name: 'Empty Milk',
        quantity: 0,
        storeName: 'Test Store',
        entryDate: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [fridgeItemsProvider.overrideWith(() => mockNotifier)],
          child: MaterialApp(
            home: Scaffold(body: InventoryItemRow(item: outOfStockItem)),
          ),
        ),
      );

      final itemDetails = tester.widget<ItemDetails>(find.byType(ItemDetails));
      expect(itemDetails.isOutOfStock, isTrue);

      final counterPill = tester.widget<CounterPill>(find.byType(CounterPill));
      expect(counterPill.isOutOfStock, isTrue);
    });
  });
}
