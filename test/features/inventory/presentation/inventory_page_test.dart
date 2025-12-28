import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_viewmodel.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';

class MockInventoryFilterNotifier extends InventoryFilter {
  final bool initialValue;
  MockInventoryFilterNotifier({this.initialValue = false});

  @override
  bool build() => initialValue;

  @override
  void toggle() {
    state = !state;
  }
}

class MockFridgeItemsNotifier extends FridgeItems {
  @override
  Future<void> deleteAll() async {}

  @override
  Future<void> addItems(List items) async {}

  @override
  Future<void> reload() async {}

  @override
  Future<void> updateItem(item) async {}

  @override
  Future<void> updateQuantity(item, int delta) async {}

  @override
  Future<void> deleteItem(String id) async {}
}

void main() {
  testWidgets('InventoryPage renders title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => const AsyncValue.loading(),
          ),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilterNotifier(),
          ),
        ],
        child: const MaterialApp(home: InventoryPage(title: 'Test Inventory')),
      ),
    );

    expect(find.text('Test Inventory'), findsOneWidget);
  });

  testWidgets('InventoryPage shows loading indicator when loading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => const AsyncValue.loading(),
          ),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilterNotifier(),
          ),
        ],
        child: const MaterialApp(home: InventoryPage(title: 'Test Inventory')),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('InventoryPage shows error message when error occurs', (
    WidgetTester tester,
  ) async {
    const errorMessage = 'Something went wrong';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) =>
                AsyncValue.error(Exception(errorMessage), StackTrace.current),
          ),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilterNotifier(),
          ),
        ],
        child: const MaterialApp(home: InventoryPage(title: 'Test Inventory')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Something went wrong'), findsOneWidget);
  });

  testWidgets(
    'InventoryPage shows "no items found" when list is empty and filter is off',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryDisplayListProvider.overrideWith(
              (ref) => const AsyncValue.data(<InventoryDisplayItem>[]),
            ),
            inventoryFilterProvider.overrideWith(
              () => MockInventoryFilterNotifier(initialValue: false),
            ),
          ],
          child: const MaterialApp(
            home: InventoryPage(title: 'Test Inventory'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(AppLocalizations.noItemsFound), findsOneWidget);
    },
  );

  testWidgets(
    'InventoryPage shows "no available items" when list is empty and filter is on',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryDisplayListProvider.overrideWith(
              (ref) => const AsyncValue.data(<InventoryDisplayItem>[]),
            ),
            inventoryFilterProvider.overrideWith(
              () => MockInventoryFilterNotifier(initialValue: true),
            ),
          ],
          child: const MaterialApp(
            home: InventoryPage(title: 'Test Inventory'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(AppLocalizations.noAvailableItems), findsOneWidget);
    },
  );

  testWidgets('InventoryPage toggles filter when switch is tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => const AsyncValue.data(<InventoryDisplayItem>[]),
          ),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilterNotifier(initialValue: false),
          ),
        ],
        child: const MaterialApp(home: InventoryPage(title: 'Test Inventory')),
      ),
    );

    final switchFinder = find.byType(Switch);
    expect(tester.widget<Switch>(switchFinder).value, isFalse);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(switchFinder).value, isTrue);
  });

  testWidgets('InventoryList header displays store name and date', (
    WidgetTester tester,
  ) async {
    final testDate = DateTime(2024, 12, 28);
    final headerItem = InventoryHeaderItem(
      storeName: 'Test Store',
      entryDate: testDate,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => AsyncValue.data(<InventoryDisplayItem>[headerItem]),
          ),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilterNotifier(initialValue: false),
          ),
        ],
        child: const MaterialApp(home: InventoryPage(title: 'Test Inventory')),
      ),
    );

    await tester.pumpAndSettle();

    // Verify the header is displayed with store name and date
    expect(find.textContaining('Test Store'), findsOneWidget);
    expect(find.textContaining('12'), findsOneWidget); // Month or day
    expect(find.textContaining('28'), findsOneWidget); // Day
    expect(find.textContaining('2024'), findsOneWidget); // Year
  });
}
