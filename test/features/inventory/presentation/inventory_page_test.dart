import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mealtrack/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_viewmodel.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';

class MockInventoryFilterNotifier extends InventoryFilter {
  final InventoryFilterType initialValue;
  MockInventoryFilterNotifier({this.initialValue = InventoryFilterType.all});

  @override
  InventoryFilterType build() => initialValue;

  @override
  void setFilter(InventoryFilterType type) {
    state = type;
  }
}

class MockFridgeItemsNotifier extends FridgeItems {
  @override
  Future<List<FridgeItem>> build() async {
    return [];
  }

  @override
  Future<void> deleteAll() async {}

  @override
  Future<void> addItems(List<FridgeItem> items) async {}

  @override
  Future<void> reload() async {}

  @override
  Future<void> updateItem(FridgeItem item) async {}

  @override
  Future<void> updateQuantity(FridgeItem item, int delta) async {}

  @override
  Future<void> deleteItem(String id) async {}
}

class MockScannerViewModel extends ScannerViewModel {
  @override
  Future<List<FridgeItem>> build() async => [];
}

void main() {
  testWidgets('InventoryPage renders app bar content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => const AsyncValue.loading(),
          ),

          scannerViewModelProvider.overrideWith(() => MockScannerViewModel()),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilterNotifier(),
          ),
          fridgeItemsProvider.overrideWith(() => MockFridgeItemsNotifier()),
        ],
        child: MaterialApp(
          theme: AppTheme.theme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('de', 'DE')],
          home: const InventoryPage(title: 'Test Inventory'),
        ),
      ),
    );

    expect(find.text('VORRATSWERT'), findsOneWidget);
    expect(find.text('Test Inventory'), findsNothing);
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
          scannerViewModelProvider.overrideWith(() => MockScannerViewModel()),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilterNotifier(),
          ),
          fridgeItemsProvider.overrideWith(() => MockFridgeItemsNotifier()),
        ],
        child: MaterialApp(
          theme: AppTheme.theme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('de', 'DE')],
          home: const InventoryPage(title: 'Test Inventory'),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
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
          scannerViewModelProvider.overrideWith(() => MockScannerViewModel()),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilterNotifier(),
          ),
          fridgeItemsProvider.overrideWith(() => MockFridgeItemsNotifier()),
        ],
        child: MaterialApp(
          theme: AppTheme.theme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('de', 'DE')],
          home: const InventoryPage(title: 'Test Inventory'),
        ),
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

            scannerViewModelProvider.overrideWith(() => MockScannerViewModel()),
            inventoryFilterProvider.overrideWith(
              () => MockInventoryFilterNotifier(
                initialValue: InventoryFilterType.all,
              ),
            ),
            fridgeItemsProvider.overrideWith(() => MockFridgeItemsNotifier()),
          ],
          child: MaterialApp(
            theme: AppTheme.theme,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('de', 'DE')],
            home: const InventoryPage(title: 'Test Inventory'),
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

            scannerViewModelProvider.overrideWith(() => MockScannerViewModel()),
            inventoryFilterProvider.overrideWith(
              () => MockInventoryFilterNotifier(
                initialValue: InventoryFilterType.available,
              ),
            ),
            fridgeItemsProvider.overrideWith(() => MockFridgeItemsNotifier()),
          ],
          child: MaterialApp(
            theme: AppTheme.theme,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('de', 'DE')],
            home: const InventoryPage(title: 'Test Inventory'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(AppLocalizations.noAvailableItems), findsOneWidget);
    },
  );

  testWidgets('InventoryPage updates filter when new type is selected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => const AsyncValue.data(<InventoryDisplayItem>[]),
          ),

          scannerViewModelProvider.overrideWith(() => MockScannerViewModel()),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilterNotifier(
              initialValue: InventoryFilterType.all,
            ),
          ),
          fridgeItemsProvider.overrideWith(() => MockFridgeItemsNotifier()),
        ],
        child: MaterialApp(
          theme: AppTheme.theme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('de', 'DE')],
          home: const InventoryPage(title: 'Test Inventory'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text(AppLocalizations.filterAll), findsOneWidget);

    await tester.tap(find.text(AppLocalizations.filterAvailable));
    await tester.pumpAndSettle();
  });

  testWidgets('InventoryList header displays store name and date', (
    WidgetTester tester,
  ) async {
    final testDate = DateTime(2024, 12, 28);
    final headerItem = InventoryHeaderItem(
      storeName: 'Test Store',
      entryDate: testDate,
      itemCount: 1,
      receiptId: 'test_receipt_id',
      isFullyConsumed: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryDisplayListProvider.overrideWith(
            (ref) => AsyncValue.data(<InventoryDisplayItem>[headerItem]),
          ),

          scannerViewModelProvider.overrideWith(() => MockScannerViewModel()),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilterNotifier(
              initialValue: InventoryFilterType.all,
            ),
          ),
          fridgeItemsProvider.overrideWith(() => MockFridgeItemsNotifier()),
        ],
        child: MaterialApp(
          theme: AppTheme.theme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('de', 'DE')],
          home: const InventoryPage(title: 'Test Inventory'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Test Store'), findsOneWidget);
    expect(find.textContaining('12'), findsOneWidget);
    expect(find.textContaining('28'), findsOneWidget);
    expect(find.textContaining('2024'), findsOneWidget);
  });
}
