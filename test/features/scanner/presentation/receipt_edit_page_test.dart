import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_viewmodel.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';

void main() {
  group('ReceiptEditPage Widget Test', () {
    testWidgets('Happy Path: Loads items, calculates total, updates on delete', (
      tester,
    ) async {
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            initialScannedItemsProvider.overrideWithValue([item1, item2]),
          ],
          child: MaterialApp(
            home: ReceiptEditPage(scannedItems: [item1, item2]),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);

      expect(find.text('14.00 €'), findsOneWidget);

      final deleteIconFinder = find.byIcon(Icons.delete_outline).first;
      await tester.tap(deleteIconFinder);
      await tester.pumpAndSettle(); 

      expect(find.text('Item 1'), findsNothing);
      expect(find.text('Item 2'), findsOneWidget);

      expect(find.text('5.00 €'), findsOneWidget);
    });

    testWidgets('Edge Case: Empty list renders correctly without crash', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ReceiptEditPage(scannedItems: [])),
        ),
      );

      expect(find.text('0.00 €'), findsOneWidget);
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
            initialScannedItemsProvider.overrideWithValue([item]),
          ],
          child: MaterialApp(home: ReceiptEditPage(scannedItems: [item])),
        ),
      );

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
            initialScannedItemsProvider.overrideWithValue([item]),
          ],
          child: MaterialApp(home: ReceiptEditPage(scannedItems: [item])),
        ),
      );

      expect(find.text('10.00 €'), findsOneWidget);

      final priceFinder = find.widgetWithText(TextField, '10.00');
      await tester.enterText(priceFinder, '20.00');
      await tester.pump();
      expect(find.text('20.00 €'), findsOneWidget);
    });

    testWidgets('Shows save button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ReceiptEditPage(scannedItems: [])),
        ),
      );
      expect(find.text('Speichern'), findsOneWidget);
    });
  });
}
