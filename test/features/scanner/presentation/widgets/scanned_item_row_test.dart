import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/scanned_item_row.dart';

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

      expect(find.byKey(const Key('quantityField')), findsOneWidget);
      expect(find.byKey(const Key('priceField')), findsOneWidget);

      final qtyFinder = find.byKey(const Key('quantityField'));
      await tester.enterText(qtyFinder, '2');
      await tester.pump();

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

      final qtyFinder = find.byKey(const Key('quantityField'));
      await tester.enterText(qtyFinder, '');
      await tester.pump();
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

      final deleteIcon = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteIcon);

      expect(wasDeleted, isTrue);
    });

    testWidgets('Happy Path: Changing name updates item', (tester) async {
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

      await tester.enterText(find.byKey(const Key('nameField')), 'New Name');
      await tester.pump();

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

      final priceFinder = find.byKey(const Key('priceField'));
      await tester.enterText(priceFinder, '15.00');
      await tester.pump();
      expect(updatedItem?.unitPrice, 15.0);
    });

    testWidgets('Happy Path: Changing brand updates item', (tester) async {
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

      final brandFinder = find.byKey(const Key('brandField'));
      await tester.enterText(brandFinder, 'Nestle');
      await tester.pump();
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

      final weightFinder = find.byKey(const Key('weightField'));
      await tester.enterText(weightFinder, '1kg');
      await tester.pump();
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

      final weightFinder = find.byKey(const Key('weightField'));
      await tester.enterText(weightFinder, '');
      await tester.pump();
      expect(updatedItem?.weight, isNull);
    });

    testWidgets('Discount icon is shown when item has discounts', (
      tester,
    ) async {
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

      expect(find.byIcon(Icons.local_offer), findsOneWidget);
    });

    testWidgets('Tapping discount icon shows discount dialog', (tester) async {
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

      await tester.tap(find.byIcon(Icons.local_offer));
      await tester.pumpAndSettle();

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

      await tester.tap(find.byIcon(Icons.local_offer));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

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

      final priceFinder = find.byKey(const Key('priceField'));
      await tester.enterText(priceFinder, '15,50');
      await tester.pump();
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

      final priceFinder = find.byKey(const Key('priceField'));
      await tester.enterText(priceFinder, 'abc');
      await tester.pump();
      expect(updatedItem?.unitPrice, 0.0);
    });

    testWidgets('didUpdateWidget updates name controller when item changes', (
      tester,
    ) async {
      final item1 = createItem(name: 'Original Name');
      final item2 = createItem(name: 'Updated Name');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(
              item: item1,
              onDelete: () {},
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Original Name'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(
              item: item2,
              onDelete: () {},
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pump();

      final nameField = tester.widget<TextField>(
        find.byKey(const Key('nameField')),
      );
      expect(nameField.controller?.text, 'Updated Name');
    });

    testWidgets('didUpdateWidget updates price controller when price changes', (
      tester,
    ) async {
      final item1 = createItem(unitPrice: 10.0);
      final item2 = item1.copyWith(unitPrice: 25.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(
              item: item1,
              onDelete: () {},
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedItemRow(
              item: item2,
              onDelete: () {},
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pump();

      final priceField = tester.widget<TextField>(
        find.byKey(const Key('priceField')),
      );
      expect(priceField.controller?.text, '25.00');
    });

    testWidgets(
      'didUpdateWidget updates quantity controller when quantity changes',
      (tester) async {
        final item1 = createItem(quantity: 1);
        final item2 = item1.copyWith(quantity: 5);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScannedItemRow(
                item: item1,
                onDelete: () {},
                onChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScannedItemRow(
                item: item2,
                onDelete: () {},
                onChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pump();

        final qtyField = tester.widget<TextField>(
          find.byKey(const Key('quantityField')),
        );
        expect(qtyField.controller?.text, '5');
      },
    );

    testWidgets('Clearing brand field sets brand to null', (tester) async {
      final item = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 10.0,
        brand: 'TestBrand',
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

      final brandFinder = find.byKey(const Key('brandField'));
      await tester.enterText(brandFinder, '');
      await tester.pump();
      expect(updatedItem?.brand, isNull);
    });
  });
}
