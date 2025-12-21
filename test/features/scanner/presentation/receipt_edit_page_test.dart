import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';

void main() {
  group('ReceiptEditPage Widget Test', () {
    testWidgets(
      'Happy Path: Loads items, calculates total, updates on delete',
      (tester) async {
        // Arrange
        // Item 1: 10.00 - 1.00 Discount = 9.00 Effective
        final item1 = ScannedItem(
          name: 'Item 1',
          totalPrice: 10.0,
          quantity: 1,
          discounts: {'D1': 1.0},
        );

        // Item 2: 5.00 - 0.00 Discount = 5.00 Effective
        final item2 = ScannedItem(name: 'Item 2', totalPrice: 5.0, quantity: 1);

        await tester.pumpWidget(
          MaterialApp(home: ReceiptEditPage(scannedItems: [item1, item2])),
        );

        // Assert Initial State
        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);

        // Check Total: 9.00 + 5.00 = 14.00
        expect(find.text('14.00 €'), findsOneWidget);

        // Act: Delete Item 1 (First item in list)
        final deleteIconFinder = find.byIcon(Icons.delete_outline).first;
        await tester.tap(deleteIconFinder);
        await tester.pump(); // Rebuild UI

        // Assert after delete
        expect(find.text('Item 1'), findsNothing);
        expect(find.text('Item 2'), findsOneWidget);

        // Check new Total: 5.00
        expect(find.text('5.00 €'), findsOneWidget);
      },
    );

    testWidgets('Edge Case: Empty list renders correctly without crash', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(home: ReceiptEditPage(scannedItems: [])),
      );

      // Assert
      expect(find.text('0.00 €'), findsOneWidget);
      expect(find.text('0 Artikel'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });
  });
}
