import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/features/home/presentation/home_menu.dart';
import 'package:mealtrack/features/calories/presentation/calories_page.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/l10n/app_localizations_de.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';
import 'package:mealtrack/features/shoppinglist/presentation/shopping_list_page.dart';

class FakeShoppingListRepository implements ShoppingListRepository {
  @override
  Stream<List<ShoppingListItem>> watchItems() => Stream.value([]);
  @override
  Future<void> addItem(ShoppingListItem item) async {}
  @override
  Future<void> addOrMergeItem({
    required String name,
    required String? brand,
    String? category,
    required int quantity,
    required double? unitPrice,
  }) async {}
  @override
  Future<void> deleteItem(String id) async {}
  @override
  Future<void> clearList() async {}
  @override
  Future<void> updateItem(ShoppingListItem item) async {}
}

class MockFridgeRepository extends Mock implements FridgeRepository {}

class MockFridgeItemsNotifier extends FridgeItems {
  final List<FridgeItem> mockItems;

  MockFridgeItemsNotifier([this.mockItems = const []]);

  @override
  Stream<List<FridgeItem>> build() => Stream.value(mockItems);

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

  @override
  Future<void> deleteItemsByReceipt(String receiptId) async {}
}

// ignore: must_be_immutable
class MockScannerViewModel extends ScannerViewModel {
  final bool keepLoading;

  MockScannerViewModel({this.keepLoading = false});

  @override
  Future<List<FridgeItem>> build() async {
    if (keepLoading) {
      state = const AsyncLoading();
      await Completer<void>().future;
    }
    return [];
  }
}

void main() {
  late MockFridgeRepository mockRepository;
  late AppLocalizations l10n;

  setUp(() {
    mockRepository = MockFridgeRepository();
    l10n = AppLocalizationsDe();
  });

  Widget buildTestWidget({List<Override> additionalOverrides = const []}) {
    final fakeFirestore = FakeFirebaseFirestore();
    final mockAuth = MockFirebaseAuth();

    return ProviderScope(
      overrides: [
        fridgeRepositoryProvider.overrideWithValue(mockRepository),
        fridgeItemsProvider.overrideWith(() => MockFridgeItemsNotifier()),
        firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
        firebaseAuthProvider.overrideWithValue(mockAuth),
        shoppingListRepositoryProvider.overrideWithValue(
          FakeShoppingListRepository(),
        ),
        ...additionalOverrides,
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('de'),
        home: HomeMenu(),
      ),
    );
  }

  group('HomeMenu - Happy Path (Navigation)', () {
    testWidgets('shows InventoryPage on app start (Index 0)', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(InventoryPage), findsOneWidget);
    });

    testWidgets('displays all 4 navigation labels', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(l10n.inventory), findsAtLeastNWidgets(1));
      expect(find.text(l10n.shoppinglist), findsOneWidget);
      expect(find.text(l10n.calories), findsOneWidget);
      expect(find.text(l10n.statistics), findsOneWidget);
    });
  });

  group('HomeMenu - Logic & State (FAB Behavior)', () {
    testWidgets('FAB shows scanner icon (center_focus_weak) on Tab 0', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.center_focus_weak), findsOneWidget);
    });

    testWidgets('FAB triggers ScanOptionsBottomSheet on Tab 0', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets('FAB shows add icon on Shopping List Tab (Index 1)', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Navigate to Shopping List
      await tester.tap(find.text(l10n.shoppinglist));
      await tester.pumpAndSettle(); // Animation

      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('HomeMenu - Loading State', () {
    testWidgets(
      'FAB shows CircularProgressIndicator when scanner is loading on Tab 0',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            additionalOverrides: [
              scannerViewModelProvider.overrideWith(
                () => MockScannerViewModel(keepLoading: true),
              ),
            ],
          ),
        );
        // Use pump() with a short duration to capture loading state
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byIcon(Icons.center_focus_weak), findsNothing);
      },
    );

    testWidgets('FAB shows scanner icon when scanner is not loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          additionalOverrides: [
            scannerViewModelProvider.overrideWith(
              () => MockScannerViewModel(keepLoading: false),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.center_focus_weak), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('HomeMenu - Edge Cases (Coming Soon Features)', () {
    testWidgets('tapping Einkaufsliste opens shopping list page', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.shoppinglist));
      await tester.pumpAndSettle();

      expect(find.byType(ShoppingListPage), findsOneWidget);
    });

    testWidgets('tapping Kalorien opens calories page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.calories));
      await tester.pumpAndSettle();

      expect(find.byType(CaloriesPage), findsOneWidget);
    });

    testWidgets('tapping Statistik shows featureInProgress snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.statistics));
      await tester.pumpAndSettle();

      expect(find.text(l10n.featureInProgress), findsOneWidget);
    });

    testWidgets('navigation index does not change when tapping statistics', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(InventoryPage), findsOneWidget);

      await tester.tap(find.text(l10n.statistics));
      await tester.pumpAndSettle();

      expect(find.byType(InventoryPage), findsOneWidget);
    });
  });

  group('HomeMenu - UI Elements', () {
    testWidgets('contains a FloatingActionButton', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('has a bottom navigation bar container', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('layout remains stable when keyboard is open', (tester) async {
      // Simulate keyboard open with viewInsets.bottom
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(() => tester.view.resetViewInsets());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify no overflow - layout should remain stable
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text(l10n.inventory), findsAtLeastNWidgets(1));

      // Verify bottom nav bar is still visible (not pushed off screen)
      expect(find.byType(SafeArea), findsWidgets);

      // No exceptions should be thrown (would indicate overflow)
      expect(tester.takeException(), isNull);
    });
  });
}
