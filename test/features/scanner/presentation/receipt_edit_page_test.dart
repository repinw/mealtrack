import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/receipt_footer.dart';
import 'package:mocktail/mocktail.dart';

class MockFridgeRepository extends Mock implements FridgeRepository {}

// ignore: must_be_immutable
class MockScannerViewModel extends ScannerViewModel {
  final List<FridgeItem> _items;

  MockScannerViewModel(this._items);

  @override
  Future<List<FridgeItem>> build() async {
    state = AsyncData(_items);
    return _items;
  }
}

void main() {
  group('ReceiptEditPage Widget Test', () {
    testWidgets(
      'Happy Path: Loads items, calculates total, updates on delete',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final item1 = FridgeItem.create(
          name: 'Item 1',
          storeName: 'Test Store',
          unitPrice: 9.0,
          quantity: 1,
          discounts: {'D1': 1.0},
        );

        final item2 = FridgeItem.create(
          name: 'Item 2',
          storeName: 'Test Store',
          unitPrice: 5.0,
        );

        final items = [item1, item2];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              scannerViewModelProvider.overrideWith(
                () => MockScannerViewModel(items),
              ),
            ],
            child: const MaterialApp(home: ReceiptEditPage()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);

        expect(find.textContaining('14.00'), findsOneWidget);

        final deleteIconFinder = find.byIcon(Icons.delete_outline).first;
        await tester.tap(deleteIconFinder);
        await tester.pumpAndSettle();

        expect(find.text('Item 1'), findsNothing);
        expect(find.text('Item 2'), findsOneWidget);

        expect(find.textContaining('5.00'), findsAtLeastNWidgets(1));

        final footerFinder = find.byType(ReceiptFooter);
        final footerTotalFinder = find.descendant(
          of: footerFinder,
          matching: find.textContaining('5.00'),
        );
        expect(footerTotalFinder, findsOneWidget);
      },
    );

    testWidgets('Edge Case: Empty list renders correctly without crash', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scannerViewModelProvider.overrideWith(
              () => MockScannerViewModel([]),
            ),
          ],
          child: const MaterialApp(home: ReceiptEditPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('0.00'), findsOneWidget);
      expect(find.text('0 Artikel'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('Extracts store name from items and populates header', (
      tester,
    ) async {
      final item = FridgeItem.create(
        name: 'Item',
        storeName: 'SuperMarket X',
        unitPrice: 10.0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scannerViewModelProvider.overrideWith(
              () => MockScannerViewModel([item]),
            ),
          ],
          child: const MaterialApp(home: ReceiptEditPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'SuperMarket X'), findsOneWidget);
    });

    testWidgets('Updates total when item price changes', (tester) async {
      final item = FridgeItem.create(
        name: 'Item',
        storeName: 'Store',
        unitPrice: 10.0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scannerViewModelProvider.overrideWith(
              () => MockScannerViewModel([item]),
            ),
          ],
          child: const MaterialApp(home: ReceiptEditPage()),
        ),
      );
      await tester.pumpAndSettle();

      final footerFinder = find.byType(ReceiptFooter);
      final footerTotalFinder = find.descendant(
        of: footerFinder,
        matching: find.textContaining('10.00'),
      );
      expect(footerTotalFinder, findsOneWidget);

      final priceFinder = find.widgetWithText(TextField, '10.00');
      expect(priceFinder, findsOneWidget);

      await tester.enterText(priceFinder, '20.00');
      await tester.pumpAndSettle();

      final footerTotalUpdatedFinder = find.descendant(
        of: footerFinder,
        matching: find.textContaining('20.00'),
      );
      expect(footerTotalUpdatedFinder, findsOneWidget);
    });

    testWidgets('Shows save button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scannerViewModelProvider.overrideWith(
              () => MockScannerViewModel([]),
            ),
          ],
          child: const MaterialApp(home: ReceiptEditPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Speichern'), findsOneWidget);
    });

    testWidgets('Back button navigates back', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scannerViewModelProvider.overrideWith(
              () => MockScannerViewModel([]),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReceiptEditPage()),
                  ),
                  child: const Text('Go to Receipt'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Go to Receipt'));
      await tester.pumpAndSettle();

      expect(find.byType(ReceiptEditPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(ReceiptEditPage), findsNothing);
    });

    testWidgets('Editing merchant name updates viewmodel', (tester) async {
      final item = FridgeItem.create(
        name: 'Item',
        storeName: 'Original Store',
        unitPrice: 10.0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scannerViewModelProvider.overrideWith(
              () => MockScannerViewModel([item]),
            ),
          ],
          child: const MaterialApp(home: ReceiptEditPage()),
        ),
      );
      await tester.pumpAndSettle();

      final merchantField = find.widgetWithText(TextField, 'Original Store');
      expect(merchantField, findsOneWidget);

      await tester.enterText(merchantField, 'New Store Name');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'New Store Name'), findsOneWidget);
    });

    testWidgets('Updates total quantity when item quantity changes', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final item = FridgeItem.create(
        name: 'Item',
        storeName: 'Store',
        unitPrice: 10.0,
        quantity: 1,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scannerViewModelProvider.overrideWith(
              () => MockScannerViewModel([item]),
            ),
          ],
          child: const MaterialApp(home: ReceiptEditPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 Artikel'), findsOneWidget);

      final qtyField = find.byKey(const Key('quantityField'));
      await tester.enterText(qtyField, '3');
      await tester.pumpAndSettle();

      expect(find.text('3 Artikel'), findsOneWidget);
    });

    testWidgets('Save button adds items to fridge and navigates back', (
      tester,
    ) async {
      final mockRepository = MockFridgeRepository();

      when(() => mockRepository.getItems()).thenAnswer((_) async => []);
      when(() => mockRepository.addItems(any())).thenAnswer((_) async {});

      final item = FridgeItem.create(
        name: 'Save Item',
        storeName: 'Store',
        unitPrice: 15.0,
        quantity: 1,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeRepositoryProvider.overrideWithValue(mockRepository),
            scannerViewModelProvider.overrideWith(
              () => MockScannerViewModel([item]),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReceiptEditPage()),
                  ),
                  child: const Text('Go'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.byType(ReceiptEditPage), findsOneWidget);
      expect(find.text('Save Item'), findsOneWidget);

      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.addItems(any())).called(1);
      expect(find.byType(ReceiptEditPage), findsNothing);
    });
    testWidgets('Save button filters out deposit items', (tester) async {
      final mockRepository = MockFridgeRepository();

      when(() => mockRepository.getItems()).thenAnswer((_) async => []);
      when(() => mockRepository.addItems(any())).thenAnswer((_) async {});

      final normalItem = FridgeItem.create(
        name: 'Normal Item',
        storeName: 'Store',
        unitPrice: 10.0,
        quantity: 1,
        isDeposit: false,
      );

      final depositItem = FridgeItem.create(
        name: 'Pfand Item',
        storeName: 'Store',
        unitPrice: -0.25,
        quantity: 1,
        isDeposit: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fridgeRepositoryProvider.overrideWithValue(mockRepository),
            scannerViewModelProvider.overrideWith(
              () => MockScannerViewModel([normalItem, depositItem]),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReceiptEditPage()),
                  ),
                  child: const Text('Go'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Normal Item'), findsOneWidget);
      expect(find.text('Pfand Item'), findsOneWidget);

      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      final captured = verify(
        () => mockRepository.addItems(captureAny()),
      ).captured;
      final savedItems = captured.first as List<FridgeItem>;

      expect(savedItems.length, 1);
      expect(savedItems.first.name, 'Normal Item');
    });

    testWidgets(
      'Save button merges isDiscount items into previous item discounts',
      (tester) async {
        final mockRepository = MockFridgeRepository();

        when(() => mockRepository.getItems()).thenAnswer((_) async => []);
        when(() => mockRepository.addItems(any())).thenAnswer((_) async {});

        final normalItem = FridgeItem.create(
          name: 'Coffee',
          storeName: 'Store',
          unitPrice: 5.0,
          quantity: 1,
          isDeposit: false,
        );

        final discountItem = FridgeItem.create(
          name: 'Sonderrabatt',
          storeName: 'Store',
          unitPrice: -1.0,
          quantity: 1,
          isDeposit: true,
          isDiscount: true,
        );

        final pfandItem = FridgeItem.create(
          name: 'Pfand',
          storeName: 'Store',
          unitPrice: 0.25,
          quantity: 1,
          isDeposit: true,
          isDiscount: false,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              fridgeRepositoryProvider.overrideWithValue(mockRepository),
              scannerViewModelProvider.overrideWith(
                () =>
                    MockScannerViewModel([normalItem, discountItem, pfandItem]),
              ),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReceiptEditPage(),
                      ),
                    ),
                    child: const Text('Go'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Speichern'));
        await tester.pumpAndSettle();

        final captured = verify(
          () => mockRepository.addItems(captureAny()),
        ).captured;
        final savedItems = captured.first as List<FridgeItem>;

        expect(savedItems.length, 1);
        final savedItem = savedItems.first;
        expect(savedItem.name, 'Coffee');

        expect(savedItem.discounts.containsKey('Sonderrabatt'), isTrue);
        expect(savedItem.discounts['Sonderrabatt'], -1.0);

        expect(savedItem.discounts.containsKey('Pfand'), isFalse);
      },
    );
  });
}
