import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';
import 'package:mealtrack/features/scanner/presentation/scanned_item_row.dart';

void main() {
  group('ScannedItemRow Widget Test', () {
    testWidgets('Happy Path: Changing quantity updates price automatically', (
      tester,
    ) async {
      // Arrange: Item with quantity 1 and total price 10.0 (implies unit price 10.0)
      final item = ScannedItem(
        name: 'Test Item',
        totalPrice: 10.0,
        quantity: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(item: item, onDelete: () {}, onChanged: () {}),
          ),
        ),
      );

      // Verify initial state
      expect(find.widgetWithText(TextField, '1'), findsOneWidget); // Quantity
      expect(find.widgetWithText(TextField, '10.00'), findsOneWidget); // Price

      // Act: Change quantity to 2
      final qtyFinder = find.widgetWithText(TextField, '1');
      await tester.enterText(qtyFinder, '2');
      await tester.pump();

      // Assert: Price should double (10.0 * 2 = 20.0)
      expect(find.widgetWithText(TextField, '20.00'), findsOneWidget);

      // Verify underlying item was updated
      expect(item.quantity, 2);
      expect(item.totalPrice, 20.0);
    });

    testWidgets('Edge Case: Empty quantity string does not crash app', (
      tester,
    ) async {
      final item = ScannedItem(
        name: 'Test Item',
        totalPrice: 10.0,
        quantity: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(item: item, onDelete: () {}, onChanged: () {}),
          ),
        ),
      );

      // Act: Clear the quantity field
      final qtyFinder = find.widgetWithText(TextField, '1');
      await tester.enterText(qtyFinder, '');
      await tester.pump();

      // Assert: No crash, price remains at last valid value (10.00)
      // because _onQtyChanged returns early on null/empty parse.
      expect(find.widgetWithText(TextField, '10.00'), findsOneWidget);
    });

    testWidgets('Edge Case: Zero quantity updates price to 0.00', (
      tester,
    ) async {
      final item = ScannedItem(
        name: 'Test Item',
        totalPrice: 10.0,
        quantity: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(item: item, onDelete: () {}, onChanged: () {}),
          ),
        ),
      );

      // Act: Set quantity to 0
      final qtyFinder = find.widgetWithText(TextField, '1');
      await tester.enterText(qtyFinder, '0');
      await tester.pump();

      // Assert
      expect(find.widgetWithText(TextField, '0.00'), findsOneWidget);
      expect(item.quantity, 0);
    });

    testWidgets('Callbacks: Delete icon triggers onDelete callback', (
      tester,
    ) async {
      bool wasDeleted = false;
      final item = ScannedItem(name: 'Delete Me', totalPrice: 5.0, quantity: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(
              item: item,
              onDelete: () {
                wasDeleted = true;
              },
              onChanged: () {},
            ),
          ),
        ),
      );

      // Act: Tap delete icon
      final deleteIcon = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteIcon);

      // Assert
      expect(wasDeleted, isTrue);
    });
  });
}
