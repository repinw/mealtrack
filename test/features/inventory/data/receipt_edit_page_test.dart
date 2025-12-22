import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_footer.dart';
import 'package:mealtrack/features/scanner/presentation/scanned_item_row.dart';

void main() {
  group('ReceiptEditPage', () {
    testWidgets('renders list of scanned items and header info', (
      tester,
    ) async {
      final items = [
        ScannedItem(name: 'Milk', totalPrice: 1.50, quantity: 1),
        ScannedItem(name: 'Bread', totalPrice: 2.00, quantity: 1),
      ];

      await tester.pumpWidget(
        MaterialApp(home: ReceiptEditPage(scannedItems: items)),
      );

      // Verify items are displayed
      expect(find.byType(ScannedItemRow), findsNWidgets(2));
      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('Bread'), findsOneWidget);

      // Verify "POSITIONEN" header and count
      expect(find.text('POSITIONEN'), findsOneWidget);
      expect(find.text('2 Artikel'), findsOneWidget);
    });

    testWidgets('populates merchant name from items', (tester) async {
      final items = [
        ScannedItem(name: 'Milk', totalPrice: 1.50, storeName: 'MySupermarket'),
      ];

      await tester.pumpWidget(
        MaterialApp(home: ReceiptEditPage(scannedItems: items)),
      );

      // Assuming ReceiptHeader contains a TextField that gets populated
      expect(find.text('MySupermarket'), findsOneWidget);
    });

    testWidgets('removes item when delete is tapped', (tester) async {
      final items = [
        ScannedItem(name: 'Item A', totalPrice: 10.0),
        ScannedItem(name: 'Item B', totalPrice: 20.0),
      ];

      await tester.pumpWidget(
        MaterialApp(home: ReceiptEditPage(scannedItems: items)),
      );

      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
      expect(find.text('2 Artikel'), findsOneWidget);

      // Find the delete icon for Item A (first row)
      final firstRowFinder = find.byType(ScannedItemRow).first;
      final deleteIconFinder = find.descendant(
        of: firstRowFinder,
        matching: find.byIcon(Icons.delete_outline),
      );

      await tester.tap(deleteIconFinder);
      await tester.pump(); // Rebuild UI

      expect(find.text('Item A'), findsNothing);
      expect(find.text('Item B'), findsOneWidget);
      expect(find.byType(ScannedItemRow), findsOneWidget);

      // Verify article count updated
      expect(find.text('1 Artikel'), findsOneWidget);
    });

    testWidgets('updates merchant name for all items when header changes', (
      tester,
    ) async {
      final items = [
        ScannedItem(name: 'Item A', totalPrice: 10.0, storeName: 'OldStore'),
        ScannedItem(name: 'Item B', totalPrice: 5.0, storeName: 'OldStore'),
      ];

      await tester.pumpWidget(
        MaterialApp(home: ReceiptEditPage(scannedItems: items)),
      );

      // Find the widget displaying 'OldStore' and enter new text
      await tester.enterText(find.text('OldStore'), 'NewStore');
      await tester.pump();

      // Verify the items' storeName was updated
      expect(items[0].storeName, 'NewStore');
      expect(items[1].storeName, 'NewStore');
    });

    testWidgets('updates total when item quantity changes', (tester) async {
      final items = [
        ScannedItem(name: 'Item A', totalPrice: 10.0, quantity: 1),
      ];

      await tester.pumpWidget(
        MaterialApp(home: ReceiptEditPage(scannedItems: items)),
      );

      // Verify initial total passed to footer
      final footerFinder = find.byType(ReceiptFooter);
      expect(footerFinder, findsOneWidget);
      expect(tester.widget<ReceiptFooter>(footerFinder).total, 10.0);

      // Change quantity of Item A to 2
      final qtyFinder = find.widgetWithText(TextField, '1');
      await tester.enterText(qtyFinder, '2');
      await tester.pump();

      // Verify updated total (10.0 * 2 = 20.0)
      expect(tester.widget<ReceiptFooter>(footerFinder).total, 20.0);
    });

    testWidgets('updates total correctly when item with discount changes', (
      tester,
    ) async {
      final items = [
        ScannedItem(
          name: 'Item A',
          totalPrice: 20.0,
          quantity: 1,
          discounts: {'Sale': 5.0}, // effective price 15.0
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(home: ReceiptEditPage(scannedItems: items)),
      );

      // Verify initial total passed to footer: 20.0 - 5.0 = 15.0
      final footerFinder = find.byType(ReceiptFooter);
      expect(tester.widget<ReceiptFooter>(footerFinder).total, 15.0);

      // Change quantity of Item A to 2
      final qtyFinder = find.widgetWithText(TextField, '1');
      await tester.enterText(qtyFinder, '2');
      await tester.pump();

      // Verify updated total. The ScannedItem's totalPrice will be updated to 40.0
      // The page's total will be 40.0 - 5.0 = 35.0
      expect(tester.widget<ReceiptFooter>(footerFinder).total, 35.0);
    });

    testWidgets('updates article count when item quantity changes', (
      tester,
    ) async {
      final items = [
        ScannedItem(name: 'Item A', totalPrice: 10.0, quantity: 1),
      ];

      await tester.pumpWidget(
        MaterialApp(home: ReceiptEditPage(scannedItems: items)),
      );

      expect(find.text('1 Artikel'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, '1'), '3');
      await tester.pump();
      expect(find.text('3 Artikel'), findsOneWidget);
    });
  });
}
