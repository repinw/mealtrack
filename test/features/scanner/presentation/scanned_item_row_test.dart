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
        name: name,
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
      expect(find.byKey(const Key('quantityField')), findsOneWidget);
      expect(find.byKey(const Key('priceField')), findsOneWidget);

      // Act: Change quantity to 2
      final qtyFinder = find.byKey(const Key('quantityField'));
      await tester.enterText(qtyFinder, '2');
      await tester.pump();

      // Assert: onChanged called with new quantity
      expect(updatedItem, isNotNull);
      expect(updatedItem!.quantity, 2);
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
      final qtyFinder = find.byKey(const Key('quantityField'));
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
      await tester.enterText(find.byKey(const Key('nameField')), 'New Name');
      await tester.pump();

      // Assert
      expect(updatedItem?.name, 'New Name');
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
      final priceFinder = find.byKey(const Key('priceField'));
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
      final brandFinder = find.byKey(const Key('brandField'));
      await tester.enterText(brandFinder, 'Nestle');
      await tester.pump();

      // Assert
      expect(updatedItem?.brand, 'Nestle');
    });

    testWidgets('Happy Path: Changing weight updates item', (tester) async {
      final item = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 10.0,
        weight: '500g',
      );
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

      // Act: Change weight
      final weightFinder = find.byKey(const Key('weightField'));
      await tester.enterText(weightFinder, '1kg');
      await tester.pump();

      // Assert
      expect(updatedItem?.weight, '1kg');
    });

    testWidgets('Clearing weight field sets weight to null', (tester) async {
      final item = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 10.0,
        weight: '500g',
      );
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

      // Act: Clear weight
      final weightFinder = find.byKey(const Key('weightField'));
      await tester.enterText(weightFinder, '');
      await tester.pump();

      // Assert
      expect(updatedItem?.weight, isNull);
    });

    testWidgets('Discount icon is shown when item has discounts', (
      tester,
    ) async {
      // ignore: invalid_use_of_internal_member
      final item = FridgeItem(
        id: 'test-id',
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 10.0,
        entryDate: DateTime.now(),
        discounts: {'Rabatt': 2.50},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(
              item: item,
              onDelete: () {},
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert: Discount icon is visible
      expect(find.byIcon(Icons.local_offer), findsOneWidget);
    });

    testWidgets('Tapping discount icon shows discount dialog', (tester) async {
      // ignore: invalid_use_of_internal_member
      final item = FridgeItem(
        id: 'test-id',
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 10.0,
        entryDate: DateTime.now(),
        discounts: {'Sonderrabatt': 2.50},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(
              item: item,
              onDelete: () {},
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Act: Tap discount icon
      await tester.tap(find.byIcon(Icons.local_offer));
      await tester.pumpAndSettle();

      // Assert: Dialog is shown with discount info
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Enthaltene Rabatte'), findsOneWidget);
      expect(find.text('Sonderrabatt'), findsOneWidget);
      expect(find.text('-2.50 €'), findsOneWidget);
    });

    testWidgets('Discount dialog can be dismissed', (tester) async {
      // ignore: invalid_use_of_internal_member
      final item = FridgeItem(
        id: 'test-id',
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 10.0,
        entryDate: DateTime.now(),
        discounts: {'Rabatt': 2.50},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(
              item: item,
              onDelete: () {},
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Act: Open and close dialog
      await tester.tap(find.byIcon(Icons.local_offer));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Assert: Dialog is closed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Discount icon is NOT shown when item has no discounts', (
      tester,
    ) async {
      final item = createItem();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(
              item: item,
              onDelete: () {},
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert: Discount icon is NOT visible
      expect(find.byIcon(Icons.local_offer), findsNothing);
    });

    testWidgets('Price field accepts comma as decimal separator', (
      tester,
    ) async {
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

      // Act: Enter price with comma
      final priceFinder = find.byKey(const Key('priceField'));
      await tester.enterText(priceFinder, '15,50');
      await tester.pump();

      // Assert: Should be parsed correctly
      expect(updatedItem?.unitPrice, 15.5);
    });

    testWidgets('Invalid price defaults to 0.0', (tester) async {
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

      // Act: Enter invalid price
      final priceFinder = find.byKey(const Key('priceField'));
      await tester.enterText(priceFinder, 'abc');
      await tester.pump();

      // Assert: Should default to 0.0
      expect(updatedItem?.unitPrice, 0.0);
    });
  });
}
