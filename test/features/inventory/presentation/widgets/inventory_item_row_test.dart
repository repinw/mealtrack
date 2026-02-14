import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list/inventory_item_row/inventory_item_row.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockFridgeItems extends FridgeItems with Mock {
  final List<(FridgeItem, int)> updateQuantityCalls = [];
  final List<(FridgeItem, double, FridgeItemRemovalType, bool)>
  updateAmountCalls = [];
  bool shouldThrowOnUpdateQuantity = false;
  bool shouldThrowOnUpdateAmount = false;

  @override
  Stream<List<FridgeItem>> build() => Stream.value([]);

  @override
  Future<void> updateQuantity(FridgeItem item, int delta) async {
    updateQuantityCalls.add((item, delta));
    if (shouldThrowOnUpdateQuantity) {
      throw Exception('Network error');
    }
  }

  @override
  Future<void> updateAmount(
    FridgeItem item,
    double amountBase, {
    required FridgeItemRemovalType removalType,
    bool isUndo = false,
  }) async {
    updateAmountCalls.add((item, amountBase, removalType, isUndo));
    if (shouldThrowOnUpdateAmount) {
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

class MockShoppingListRepository extends Mock
    implements ShoppingListRepository {
  @override
  Stream<List<ShoppingListItem>> watchItems() => Stream.value([]);
}

void main() {
  late MockFridgeItems mockNotifier;

  final testItem = FridgeItem(
    id: '1',
    name: 'Test Apple',
    quantity: 3,
    storeName: 'Test Store',
    entryDate: DateTime.now(),
    initialQuantity: 5,
    initialAmountBase: 1000,
    remainingAmountBase: 600,
    amountUnit: FridgeItemAmountUnit.gram,
  );

  setUp(() {
    mockNotifier = MockFridgeItems();
  });

  Widget createWidgetUnderTest({
    FridgeItem? item,
    ShoppingListRepository? shoppingListRepository,
  }) {
    final rowItem = item ?? testItem;
    final overrides = [
      fridgeItemProvider(rowItem.id).overrideWithValue(rowItem),
      fridgeItemsProvider.overrideWith(() => mockNotifier),
    ];

    if (shoppingListRepository != null) {
      overrides.add(
        shoppingListRepositoryProvider.overrideWithValue(
          shoppingListRepository,
        ),
      );
    }

  Widget createWidgetUnderTest({
    FridgeItem? item,
    ShoppingListRepository? shoppingListRepository,
  }) {
    final rowItem = item ?? testItem;
    final overrides = [
      fridgeItemProvider(rowItem.id).overrideWithValue(rowItem),
      fridgeItemsProvider.overrideWith(() => mockNotifier),
    ];

    if (shoppingListRepository != null) {
      overrides.add(
        shoppingListRepositoryProvider.overrideWithValue(
          shoppingListRepository,
        ),
      );
    }

    return ProviderScope(
      overrides: overrides,
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Scaffold(body: InventoryItemRow(itemId: rowItem.id)),
        home: Scaffold(body: InventoryItemRow(itemId: rowItem.id)),
      ),
    );
  }

  group('InventoryItemRow Tests', () {
    testWidgets('renders item name and progress summary', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Test Apple'), findsOneWidget);
      expect(find.text('3 / 5'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('renders empty row when item is loading placeholder', (
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

      expect(find.byType(Dismissible), findsNothing);
      expect(find.byType(Dismissible), findsNothing);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('tap toggles action panel visibility', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

      await tester.tap(find.text('Test Apple'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
    });

    testWidgets('eating action updates quantity with a negative delta', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Test Apple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Essen'));
      await tester.pumpAndSettle();

      expect(mockNotifier.updateQuantityCalls.length, 1);
      final delta = mockNotifier.updateQuantityCalls.first.$2;
      expect(delta, lessThanOrEqualTo(-1));
      expect(delta, greaterThanOrEqualTo(-testItem.quantity));
    });

    testWidgets('shows SnackBar when remove action fails', (
      WidgetTester tester,
    ) async {
      final archivedItem = testItem.copyWith(isArchived: true);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Test Apple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wegwerfen'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Aktion fehlgeschlagen'), findsOneWidget);
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
        initialQuantity: 5,
      );

      await tester.pumpWidget(createWidgetUnderTest(item: outOfStockItem));

      final itemText = tester.widget<Text>(find.text('Out of Stock Item'));
      expect(itemText.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('action buttons are disabled when item is archived', (
      WidgetTester tester,
    ) async {
      final outOfStockItem = testItem.copyWith(
        quantity: 0,
        remainingAmountBase: 0,
      );

      await tester.pumpWidget(createWidgetUnderTest(item: archivedItem));

      expect(find.text('Archiviert'), findsOneWidget);

      await tester.tap(find.text('Archived Item'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wegwerfen').last, warnIfMissed: false);
      await tester.tap(find.text('Essen').last, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        mockNotifier.updateQuantityCalls,
        isEmpty,
        reason: 'Archived items should not allow removal actions',
      );
    });

    testWidgets('swiping right adds item to shopping list', (
      WidgetTester tester,
    ) async {
      final mockShoppingListRepo = MockShoppingListRepository();
      when(
        () => mockShoppingListRepo.addOrMergeItem(
          name: 'Test Apple',
          brand: null,
          quantity: 1,
          unitPrice: 0.0,
          category: null,
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        createWidgetUnderTest(shoppingListRepository: mockShoppingListRepo),
      );

      await tester.drag(
        find.byKey(const Key('inventory_row_1')),
        const Offset(500, 0),
      );
      await tester.pumpAndSettle();

      verify(
        () => mockShoppingListRepo.addOrMergeItem(
          name: 'Test Apple',
          brand: null,
          quantity: 1,
          unitPrice: 0.0,
          category: null,
        ),
      ).called(1);
      expect(
        find.text('Test Apple zur Einkaufsliste hinzugefügt'),
        findsOneWidget,
      );
    });

    testWidgets('long press adds item to shopping list', (
      WidgetTester tester,
    ) async {
      final mockShoppingListRepo = MockShoppingListRepository();
      when(
        () => mockShoppingListRepo.addOrMergeItem(
          name: 'Test Apple',
          brand: null,
          quantity: 1,
          unitPrice: 0.0,
          category: null,
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        createWidgetUnderTest(shoppingListRepository: mockShoppingListRepo),
        createWidgetUnderTest(shoppingListRepository: mockShoppingListRepo),
      );

      await tester.longPress(find.text('Test Apple'));
      await tester.pumpAndSettle();

      verify(
        () => mockShoppingListRepo.addOrMergeItem(
          name: 'Test Apple',
          brand: null,
          quantity: 1,
          unitPrice: 0.0,
          category: null,
        ),
      ).called(1);
      expect(
        find.text('Test Apple zur Einkaufsliste hinzugefügt'),
        findsOneWidget,
      );
    });
  });
}
