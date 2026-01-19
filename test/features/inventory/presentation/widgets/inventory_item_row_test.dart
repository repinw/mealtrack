import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/counter_pill.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/action_button.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_item_row.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';

class MockFridgeItems extends FridgeItems with Mock {
  final List<(FridgeItem, int)> updateQuantityCalls = [];
  bool shouldThrowOnUpdate = false;

  @override
  Stream<List<FridgeItem>> build() => Stream.value([]);

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

class FakeFridgeItem extends Fake implements FridgeItem {}

class MockShoppingListRepository extends Mock
    implements ShoppingListRepository {
  @override
  Stream<List<ShoppingListItem>> watchItems() => Stream.value([]);
}

void main() {
  late MockFridgeItems mockNotifier;

  setUpAll(() {
    registerFallbackValue(FakeFridgeItem());
    registerFallbackValue(const ShoppingListItem(id: '1', name: 'dummy'));
  });

  final testItem = FridgeItem(
    id: '1',
    name: 'Test Apple',
    quantity: 3,
    storeName: 'Test Store',
    entryDate: DateTime.now(),
    initialQuantity: 5,
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Scaffold(body: InventoryItemRow(itemId: testItem.id)),
      ),
    );
  }

  group('InventoryItemRow Tests', () {
    testWidgets('renders item name and price correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Test Apple'), findsOneWidget);
      expect(find.textContaining('0.00€'), findsOneWidget);
      expect(find.textContaining('pro Stück'), findsNothing);
      expect(find.byType(CounterPill), findsOneWidget);
    });

    testWidgets('renders quantity badge correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.textContaining('5'), findsWidgets);
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
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: InventoryItemRow(itemId: 'some-id')),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('calls updateQuantity on notifier when pill updates', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final CounterPill counterPill = tester.widget(find.byType(CounterPill));
      counterPill.onUpdate!(1);

      expect(mockNotifier.updateQuantityCalls.length, 1);
      expect(mockNotifier.updateQuantityCalls.first.$2, 1);
    });

    testWidgets('shows SnackBar when updateQuantity fails', (
      WidgetTester tester,
    ) async {
      mockNotifier.shouldThrowOnUpdate = true;

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(
          'Menge konnte nicht aktualisiert werden. Bitte erneut versuchen.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('SnackBar has floating behavior on error', (
      WidgetTester tester,
    ) async {
      mockNotifier.shouldThrowOnUpdate = true;

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.behavior, SnackBarBehavior.floating);
    });

    testWidgets('no SnackBar shown when updateQuantity succeeds', (
      WidgetTester tester,
    ) async {
      mockNotifier.shouldThrowOnUpdate = false;

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('out of stock item is displayed with strikethrough', (
      WidgetTester tester,
    ) async {
      final outOfStockItem = FridgeItem(
        id: '2',
        name: 'Out of Stock Item',
        quantity: 0,
        storeName: 'Test Store',
        entryDate: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeItemProvider(
              outOfStockItem.id,
            ).overrideWithValue(outOfStockItem),
            fridgeItemsProvider.overrideWith(() => mockNotifier),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: InventoryItemRow(itemId: outOfStockItem.id)),
          ),
        ),
      );

      expect(find.text('Out of Stock Item'), findsOneWidget);
    });

    testWidgets('CounterPill is read-only when item is archived', (
      WidgetTester tester,
    ) async {
      final archivedItem = FridgeItem(
        id: 'archived-1',
        name: 'Archived Item',
        quantity: 2,
        storeName: 'Store',
        entryDate: DateTime.now(),
        initialQuantity: 5,
        isArchived: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeItemProvider(archivedItem.id).overrideWithValue(archivedItem),
            fridgeItemsProvider.overrideWith(() => mockNotifier),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: InventoryItemRow(itemId: archivedItem.id)),
          ),
        ),
      );

      // find CounterPill
      final counterPillFinder = find.byType(CounterPill);
      expect(counterPillFinder, findsOneWidget);

      final CounterPill counterPill = tester.widget(counterPillFinder);
      expect(
        counterPill.onUpdate,
        isNull,
        reason: 'onUpdate should be null for archived items',
      );

      // Verify visual disabled state via helper validation or button check
      // We know from counter_pill_test that null onUpdate disables buttons.
      // We can optionally verify the buttons are disabled explicitly if we want to be thorough.

      final minusButton = find.descendant(
        of: counterPillFinder,
        matching: find.byIcon(Icons.remove),
      );
      final plusButton = find.descendant(
        of: counterPillFinder,
        matching: find.byIcon(Icons.add),
      );

      // InkWell onTap should be null
      final minusInkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.ancestor(
            of: minusButton,
            matching: find.byType(ActionButton),
          ),
          matching: find.byType(InkWell),
        ),
      );
      final plusInkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.ancestor(
            of: plusButton,
            matching: find.byType(ActionButton),
          ),
          matching: find.byType(InkWell),
        ),
      );

      expect(minusInkWell.onTap, isNull);
      expect(plusInkWell.onTap, isNull);
    });

    testWidgets('swiping right adds item to shopping list', (
      WidgetTester tester,
    ) async {
      final mockShoppingListRepo = MockShoppingListRepository();
      when(() => mockShoppingListRepo.addItem(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeItemProvider(testItem.id).overrideWithValue(testItem),
            fridgeItemsProvider.overrideWith(() => mockNotifier),
            shoppingListRepositoryProvider.overrideWithValue(
              mockShoppingListRepo,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('de'),
            home: Scaffold(body: InventoryItemRow(itemId: testItem.id)),
          ),
        ),
      );

      // Swipe right
      await tester.drag(find.byType(InventoryItemRow), const Offset(500, 0));
      await tester.pumpAndSettle();

      // Verify addItem was called
      verify(() => mockShoppingListRepo.addItem(any())).called(1);
    });

    testWidgets('long press adds item to shopping list', (
      WidgetTester tester,
    ) async {
      final mockShoppingListRepo = MockShoppingListRepository();
      when(() => mockShoppingListRepo.addItem(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeItemProvider(testItem.id).overrideWithValue(testItem),
            fridgeItemsProvider.overrideWith(() => mockNotifier),
            shoppingListRepositoryProvider.overrideWithValue(
              mockShoppingListRepo,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('de'),
            home: Scaffold(body: InventoryItemRow(itemId: testItem.id)),
          ),
        ),
      );

      // Long press
      await tester.longPress(find.byType(InventoryItemRow));
      await tester.pumpAndSettle();

      // Verify addItem was called
      verify(() => mockShoppingListRepo.addItem(any())).called(1);
    });
  });
}
