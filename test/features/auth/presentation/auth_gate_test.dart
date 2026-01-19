import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/auth/presentation/auth_gate.dart';
import 'package:mealtrack/features/auth/presentation/welcome_page.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';
import 'package:mealtrack/features/inventory/domain/inventory_stats.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_viewmodel.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/provider/shopping_list_provider.dart';
import 'package:mealtrack/core/models/user_profile.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class MockUser extends Mock implements User {}

class MockFridgeItemsNotifier extends FridgeItems {
  @override
  Stream<List<FridgeItem>> build() => Stream.value([]);

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

class MockInventoryFilterNotifier extends InventoryFilter {
  @override
  InventoryFilterType build() => InventoryFilterType.all;

  @override
  void setFilter(InventoryFilterType type) {
    state = type;
  }
}

class MockScannerViewModel extends ScannerViewModel {
  @override
  Future<List<FridgeItem>> build() async => [];
}

class MockShoppingList extends ShoppingList {
  @override
  Stream<List<ShoppingListItem>> build() => Stream.value([]);
}

void main() {
  late MockUser mockUser;

  setUp(() {
    mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('test-user-id');
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.isAnonymous).thenReturn(false);
  });

  Widget createWidgetUnderTest(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: AuthGate(),
      ),
    );
  }

  group('AuthGate', () {
    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      final streamController = StreamController<User?>();

      final container = ProviderContainer(
        overrides: [
          authStateChangesProvider.overrideWith(
            (ref) => streamController.stream,
          ),
        ],
      );
      addTearDown(() {
        container.dispose();
        streamController.close();
      });

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows WelcomePage when user is null (unauthenticated)', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      expect(find.byType(WelcomePage), findsOneWidget);
    });

    testWidgets(
      'shows WelcomePage when network error occurs (e.g. offline start)',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            authStateChangesProvider.overrideWith(
              (ref) => Stream.error('Network error'),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(createWidgetUnderTest(container));
        await tester.pumpAndSettle();

        expect(find.byType(WelcomePage), findsOneWidget);
      },
    );

    testWidgets('shows InventoryPage when user is authenticated', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          authStateChangesProvider.overrideWith(
            (ref) => Stream.value(mockUser),
          ),
          fridgeItemsProvider.overrideWith(() => MockFridgeItemsNotifier()),
          inventoryFilterProvider.overrideWith(
            () => MockInventoryFilterNotifier(),
          ),
          inventoryDisplayListProvider.overrideWith(
            (ref) => const AsyncValue.data([]),
          ),
          inventoryStatsProvider.overrideWith((ref) => InventoryStats.empty),
          scannerViewModelProvider.overrideWith(() => MockScannerViewModel()),
          userProfileProvider.overrideWith(
            (ref) => Stream.value(
              UserProfile(
                uid: mockUser.uid,
                email: mockUser.email,
                displayName: mockUser.displayName,
              ),
            ),
          ),
          shoppingListProvider.overrideWith(() => MockShoppingList()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      expect(find.byType(InventoryPage), findsOneWidget);
    });
  });
}
