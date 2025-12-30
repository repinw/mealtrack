import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/presentation/category_icon.dart';
import 'package:mealtrack/features/inventory/presentation/counter_pill.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_item_row.dart';
import 'package:mealtrack/features/inventory/presentation/item_details.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';

class MockFridgeItems extends TitleNotifier<List<FridgeItem>>
    with Mock
    implements FridgeItems {
  final List<(FridgeItem, int)> updateQuantityCalls = [];
  bool shouldThrowOnUpdate = false;

  @override
  Future<List<FridgeItem>> build() async => [];

  @override
  Future<void> updateQuantity(FridgeItem item, int delta) async {
    updateQuantityCalls.add((item, delta));
    if (shouldThrowOnUpdate) {
      throw Exception('Network error');
    }
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
        fridgeItemProvider(testItem.id).overrideWithValue(testItem),
        fridgeItemsProvider.overrideWith(() => mockNotifier),
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
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CategoryIcon), findsOneWidget);
      expect(find.byType(ItemDetails), findsOneWidget);
      expect(find.byType(CounterPill), findsOneWidget);

      final categoryIcon = tester.widget<CategoryIcon>(
        find.byType(CategoryIcon),
      );
      expect(categoryIcon.name, testItem.name);
    });

    testWidgets('renders empty widget when item is loading placeholder', (
      WidgetTester tester,
    ) async {
      final loadingItem = FridgeItem(
        id: 'loading',
        name: 'Loading...',
        quantity: 0,
        storeName: '',
        entryDate: DateTime(1970),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeItemProvider('some-id').overrideWithValue(loadingItem),
            fridgeItemsProvider.overrideWith(() => mockNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(body: InventoryItemRow(itemId: 'some-id')),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(CategoryIcon), findsNothing);
      expect(find.byType(ItemDetails), findsNothing);
      expect(find.byType(CounterPill), findsNothing);
    });

    testWidgets('calls updateQuantity on notifier when pill updates', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final CounterPill counterPill = tester.widget(find.byType(CounterPill));
      counterPill.onUpdate(1);

      expect(mockNotifier.updateQuantityCalls.length, 1);
      expect(mockNotifier.updateQuantityCalls.first.$2, 1);
    });

    testWidgets('shows SnackBar when updateQuantity fails', (
      WidgetTester tester,
    ) async {
      mockNotifier.shouldThrowOnUpdate = true;

      await tester.pumpWidget(createWidgetUnderTest());

      // Tap the add button to trigger updateQuantity
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify SnackBar is shown with correct message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(AppLocalizations.quantityUpdateFailed), findsOneWidget);
    });

    testWidgets('SnackBar has floating behavior on error', (
      WidgetTester tester,
    ) async {
      mockNotifier.shouldThrowOnUpdate = true;

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.behavior, SnackBarBehavior.floating);
    });

    testWidgets('no SnackBar shown when updateQuantity succeeds', (
      WidgetTester tester,
    ) async {
      mockNotifier.shouldThrowOnUpdate = false;

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
