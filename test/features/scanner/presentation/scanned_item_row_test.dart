import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/data/discount.dart';
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

    testWidgets('shows discount dialog when discount icon is tapped', (
      tester,
    ) async {
      final discount = Discount(name: 'Promo', amount: 1.0);
      final item = ScannedItem(
        name: 'Item with Discount',
        totalPrice: 10.0,
        quantity: 1,
        discounts: [discount],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(item: item, onDelete: () {}, onChanged: () {}),
          ),
        ),
      );

      // Find discount icon
      final discountIcon = find.byIcon(Icons.local_offer);
      await tester.tap(discountIcon);
      await tester.pumpAndSettle();

      // Verify dialog content
      expect(find.text('Enthaltene Rabatte'), findsOneWidget);
      expect(find.text('Promo'), findsOneWidget);
      expect(find.text('-1.00 €'), findsOneWidget);
    });

    testWidgets('UI: Shows amber border for low confidence items',
        (tester) async {
      // Arrange
      final item = ScannedItem(
        name: 'Unsure Item',
        totalPrice: 5.0,
        isLowConfidence: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(item: item, onDelete: () {}, onChanged: () {}),
          ),
        ),
      );

      // Assert
      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.border is Border &&
              (decoration.border as Border).top.color == Colors.amber;
        }
        return false;
      });

      expect(containerFinder, findsOneWidget);
    });

    testWidgets('Happy Path: Changing name updates item', (tester) async {
      // Arrange
      final item = ScannedItem(name: 'Old Name', totalPrice: 10.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(item: item, onDelete: () {}, onChanged: () {}),
          ),
        ),
      );

      // Act
      await tester.enterText(
          find.widgetWithText(TextField, 'Old Name'), 'New Name');
      await tester.pump();

      // Assert
      expect(item.name, 'New Name');
    });

    testWidgets('Happy Path: Changing price updates item correctly',
        (tester) async {
      // Arrange: Item with discount
      final item = ScannedItem(
        name: 'Test Item',
        totalPrice: 12.0,
        quantity: 1,
        discounts: [Discount(name: 'Sale', amount: 2.0)], // effective price is 10.00
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(item: item, onDelete: () {}, onChanged: () {}),
          ),
        ),
      );

      // Act: Change price to 15.00
      final priceFinder = find.widgetWithText(TextField, '10.00');
      await tester.enterText(priceFinder, '15.00');
      await tester.pump();

      // Assert: Verify underlying item was updated
      // displayedPrice is 15.00. totalDiscount is 2.0.
      // grossTotalPrice = 15.00 + 2.0 = 17.0
      expect(item.totalPrice, 17.0);
      expect(item.unitPrice, 17.0); // since quantity is 1
    });

    testWidgets('Happy Path: Changing brand updates item', (tester) async {
      // Arrange
      final item = ScannedItem(name: 'Test Item', totalPrice: 10.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(item: item, onDelete: () {}, onChanged: () {}),
          ),
        ),
      );

      // Act
      final brandFinder = find.widgetWithText(TextField, 'Marke');
      await tester.enterText(brandFinder, 'Nestle');
      await tester.pump();

      // Assert
      expect(item.brand, 'Nestle');
    });
  });
}
