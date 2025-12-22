import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/scanner/presentation/scanned_item_row.dart';

void main() {
  group('ScannedItemRow Widget Test', () {
    FridgeItem createItem({
      String name = 'Test Item',
      double unitPrice = 10.0,
      int quantity = 1,
      String? brand,
    }) {
      return FridgeItem.create(
        rawText: name,
        storeName: 'Test Store',
        quantity: quantity,
        unitPrice: unitPrice,
        brand: brand,
      );
    }

    testWidgets('Happy Path: Changing quantity calls onChanged', (
      tester,
    ) async {
      final item = createItem(quantity: 1);
      FridgeItem? updatedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(
              item: item,
              onDelete: () {},
              onChanged: (val) => updatedItem = val,
            ),
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

      // Assert: onChanged called with new quantity
      expect(updatedItem, isNotNull);
      expect(updatedItem!.quantity, 2);

      // Price field should NOT change (it shows unit price)
      expect(find.widgetWithText(TextField, '10.00'), findsOneWidget);
    });

    testWidgets('Edge Case: Empty quantity string does not crash app', (
      tester,
    ) async {
      final item = createItem(quantity: 1);
      bool onChangedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(
              item: item,
              onDelete: () {},
              onChanged: (_) => onChangedCalled = true,
            ),
          ),
        ),
      );

      // Act: Clear the quantity field
      final qtyFinder = find.widgetWithText(TextField, '1');
      await tester.enterText(qtyFinder, '');
      await tester.pump();

      // Assert
      expect(onChangedCalled, isFalse);
    });

    testWidgets('Callbacks: Delete icon triggers onDelete callback', (
      tester,
    ) async {
      bool wasDeleted = false;
      final item = createItem();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(
              item: item,
              onDelete: () {
                wasDeleted = true;
              },
              onChanged: (_) {},
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

    testWidgets('Happy Path: Changing name updates item', (tester) async {
      // Arrange
      final item = createItem(name: 'Old Name');
      FridgeItem? updatedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(
              item: item,
              onDelete: () {},
              onChanged: (val) => updatedItem = val,
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(
        find.widgetWithText(TextField, 'Old Name'),
        'New Name',
      );
      await tester.pump();

      // Assert
      expect(updatedItem?.rawText, 'New Name');
    });

    testWidgets('Happy Path: Changing price updates unitPrice', (tester) async {
      final item = createItem(unitPrice: 10.0);
      FridgeItem? updatedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(
              item: item,
              onDelete: () {},
              onChanged: (val) => updatedItem = val,
            ),
          ),
        ),
      );

      // Act: Change price to 15.00
      final priceFinder = find.widgetWithText(TextField, '10.00');
      await tester.enterText(priceFinder, '15.00');
      await tester.pump();

      // Assert
      expect(updatedItem?.unitPrice, 15.0);
    });

    testWidgets('Happy Path: Changing brand updates item', (tester) async {
      // Arrange
      final item = createItem(name: 'Item', brand: '');
      FridgeItem? updatedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(
              item: item,
              onDelete: () {},
              onChanged: (val) => updatedItem = val,
            ),
          ),
        ),
      );

      // Act
      final brandFinder = find.widgetWithText(TextField, 'Marke');
      await tester.enterText(brandFinder, 'Nestle');
      await tester.pump();

      // Assert
      expect(updatedItem?.brand, 'Nestle');
    });
  });
}
