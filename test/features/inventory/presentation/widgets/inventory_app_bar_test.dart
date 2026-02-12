import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_app_bar.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/sharing/presentation/sharing_page.dart';
import 'package:mealtrack/features/settings/presentation/settings_page.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/core/presentation/widgets/summary_header.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../shared/test_helpers.dart';

class MockFridgeRepository extends Mock implements FridgeRepository {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

class MockFridgeItemsNotifier extends FridgeItems {
  final List<FridgeItem> mockItems;
  bool deleteAllCalled = false;

  MockFridgeItemsNotifier([this.mockItems = const []]);

  @override
  Stream<List<FridgeItem>> build() => Stream.value(mockItems);

  @override
  Future<void> deleteAll() async {
    deleteAllCalled = true;
  }

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

void main() {
  late MockFridgeRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockRepository = MockFridgeRepository();
  });

  Widget buildTestWidget({
    List<FridgeItem>? items,
    NavigatorObserver? navigatorObserver,
  }) {
    return ProviderScope(
      overrides: [
        fridgeRepositoryProvider.overrideWithValue(mockRepository),
        fridgeItemsProvider.overrideWith(
          () => MockFridgeItemsNotifier(items ?? []),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorObservers: navigatorObserver != null
            ? [navigatorObserver]
            : [],
        home: const Scaffold(
          appBar: InventoryAppBar(title: 'Test Title'),
          body: SizedBox.shrink(),
        ),
      ),
    );
  }

  group('InventoryAppBar', () {
    testWidgets('displays the title in uppercase', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('TEST TITLE'), findsOneWidget);
    });

    testWidgets('displays VORRATSWERT label', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('VORRATSWERT'), findsOneWidget);
      expect(find.byType(SummaryHeader), findsOneWidget);
    });

    testWidgets('displays inventory value when items exist', (tester) async {
      final items = [
        createTestFridgeItem(
          name: 'Test Item',
          storeName: 'Store',
          quantity: 2,
          unitPrice: 5.0,
        ),
      ];

      await tester.pumpWidget(buildTestWidget(items: items));
      await tester.pumpAndSettle();

      expect(find.textContaining('10,00'), findsOneWidget);
    });

    testWidgets('displays debug delete button in debug mode', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_forever), findsOneWidget);
    });

    testWidgets('debug delete button clears all items and shows snackbar', (
      tester,
    ) async {
      final item = createTestFridgeItem(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 1.0,
      );

      await tester.pumpWidget(buildTestWidget(items: [item]));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_forever));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('displays purchases and items count', (tester) async {
      final items = [
        createTestFridgeItem(
          name: 'Item 1',
          storeName: 'Store',
          quantity: 3,
          unitPrice: 1.0,
        ).copyWith(receiptId: 'receipt-1'),
        createTestFridgeItem(
          name: 'Item 2',
          storeName: 'Store',
          quantity: 2,
          unitPrice: 1.0,
        ).copyWith(receiptId: 'receipt-1'),
      ];

      await tester.pumpWidget(buildTestWidget(items: items));
      await tester.pumpAndSettle();

      expect(find.textContaining('1'), findsWidgets);
      expect(find.textContaining('5'), findsWidgets);
    });

    testWidgets('displays sharing button with people icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('displays settings button with settings icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('tapping sharing button pushes SharingPage', (tester) async {
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(buildTestWidget(navigatorObserver: mockObserver));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.people_outline));
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
      expect(find.byType(SharingPage), findsOneWidget);
    });

    testWidgets('tapping settings button pushes SettingsPage', (tester) async {
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(buildTestWidget(navigatorObserver: mockObserver));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
      expect(find.byType(SettingsPage), findsOneWidget);
    });
  });
}
