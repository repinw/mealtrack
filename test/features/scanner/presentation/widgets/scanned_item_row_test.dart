import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/scanned_item_row.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

void main() {
  group('ScannedItemRow Widget Test', () {
    FridgeItem createItem({
      String name = 'Test Item',
      double unitPrice = 10.0,
      int quantity = 1,
      String? brand,
      String? language,
    }) {
      return FridgeItem.create(
        name: name,
        storeName: 'Test Store',
        quantity: quantity,
        unitPrice: unitPrice,
        brand: brand,
        language: language,
      );
    }

    Widget wrap(Widget child, {Locale locale = const Locale('de')}) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: Scaffold(body: child),
      );
    }

    Widget createTestWidget(
      FridgeItem item, {
      VoidCallback? onDelete,
      ValueChanged<FridgeItem>? onChanged,
      Locale locale = const Locale('de'),
    }) {
      return wrap(
        ScannedItemRow(
          item: item,
          onDelete: onDelete ?? () {},
          onChanged: onChanged ?? (_) {},
        ),
        locale: locale,
      );
    }

    testWidgets('Happy Path: Changing quantity calls onChanged', (
      tester,
    ) async {
      final item = createItem(quantity: 1);
      FridgeItem? updatedItem;

      await tester.pumpWidget(
        createTestWidget(item, onChanged: (val) => updatedItem = val),
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
        createTestWidget(item, onChanged: (_) => onChangedCalled = true),
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
        createTestWidget(
          item,
          onDelete: () {
            wasDeleted = true;
          },
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
        createTestWidget(item, onChanged: (val) => updatedItem = val),
      );

      await tester.enterText(find.byKey(const Key('nameField')), 'New Name');
      await tester.pump();

      expect(updatedItem?.name, 'New Name');
    });

    testWidgets('Happy Path: Changing price updates unitPrice', (tester) async {
      final item = createItem(unitPrice: 10.0);
      FridgeItem? updatedItem;

      await tester.pumpWidget(
        createTestWidget(item, onChanged: (val) => updatedItem = val),
      );

      final priceFinder = find.byKey(const Key('priceField'));
      await tester.enterText(priceFinder, '15,00');
      await tester.pump();
      expect(updatedItem?.unitPrice, 15.0);
    });

    testWidgets('Happy Path: Changing brand updates item', (tester) async {
      final item = createItem(name: 'Item', brand: '');
      FridgeItem? updatedItem;

      await tester.pumpWidget(
        createTestWidget(item, onChanged: (val) => updatedItem = val),
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
        createTestWidget(item, onChanged: (val) => updatedItem = val),
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
        createTestWidget(item, onChanged: (val) => updatedItem = val),
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
        discounts: const {'Rabatt': 2.50},
      );

      await tester.pumpWidget(createTestWidget(item));

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
        discounts: const {'Sonderrabatt': 2.50},
      );

      await tester.pumpWidget(createTestWidget(item));

      await tester.tap(find.byIcon(Icons.local_offer));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Enthaltene Rabatte'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Sonderrabatt'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.textContaining('2,50'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.textContaining('€'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Discount dialog can be dismissed', (tester) async {
      final item = FridgeItem(
        id: 'test-id',
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 10.0,
        entryDate: DateTime.now(),
        discounts: const {'Rabatt': 2.50},
      );

      await tester.pumpWidget(createTestWidget(item));

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

      await tester.pumpWidget(createTestWidget(item));

      expect(find.byIcon(Icons.local_offer), findsNothing);
    });

    testWidgets('Price field accepts comma as decimal separator', (
      tester,
    ) async {
      final item = createItem(unitPrice: 10.0);
      FridgeItem? updatedItem;

      await tester.pumpWidget(
        createTestWidget(item, onChanged: (val) => updatedItem = val),
      );

      final priceFinder = find.byKey(const Key('priceField'));
      // Using fallback parsing (likely system logic in this raw MaterialApp test)
      // Wait, in previous successful run this worked for '15,50' in German context
      await tester.enterText(priceFinder, '15,50');
      await tester.pump();
      expect(updatedItem?.unitPrice, 15.5);
    });

    testWidgets('Invalid price defaults to 0.0', (tester) async {
      final item = createItem(unitPrice: 10.0);
      FridgeItem? updatedItem;

      await tester.pumpWidget(
        createTestWidget(item, onChanged: (val) => updatedItem = val),
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

      await tester.pumpWidget(createTestWidget(item1));

      expect(find.text('Original Name'), findsOneWidget);

      await tester.pumpWidget(createTestWidget(item2));

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

      await tester.pumpWidget(createTestWidget(item1));

      await tester.pumpWidget(createTestWidget(item2));

      await tester.pump();

      final priceField = tester.widget<TextField>(
        find.byKey(const Key('priceField')),
      );
      expect(priceField.controller?.text, '25,00');
    });

    testWidgets(
      'didUpdateWidget updates quantity controller when quantity changes',
      (tester) async {
        final item1 = createItem(quantity: 1);
        final item2 = item1.copyWith(quantity: 5);

        await tester.pumpWidget(createTestWidget(item1));

        await tester.pumpWidget(createTestWidget(item2));

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
        createTestWidget(item, onChanged: (val) => updatedItem = val),
      );

      final brandFinder = find.byKey(const Key('brandField'));
      await tester.enterText(brandFinder, '');
      await tester.pump();

      expect(updatedItem?.brand, isNull);
    });

    testWidgets('Locale en: Price field parses dot correctly', (tester) async {
      final item = createItem(unitPrice: 10.0, language: 'en');
      FridgeItem? updatedItem;

      await tester.pumpWidget(
        createTestWidget(
          item,
          onChanged: (val) => updatedItem = val,
          // Even if app locale is de, item language 'en' should force en parsing
          locale: const Locale('de'),
        ),
      );

      final priceFinder = find.byKey(const Key('priceField'));
      await tester.enterText(priceFinder, '1234.56');
      await tester.pump();
      expect(updatedItem?.unitPrice, 1234.56);
    });

    testWidgets(
      'Locale fallback: Defaults to valid parsing for context locale (de) with complex numbers',
      (tester) async {
        final item = createItem(unitPrice: 10.0, language: null);
        FridgeItem? updatedItem;

        // Run in German context (default for wrap)
        await tester.pumpWidget(
          createTestWidget(
            item,
            onChanged: (val) => updatedItem = val,
            locale: const Locale('de'),
          ),
        );

        final priceFinder = find.byKey(const Key('priceField'));
        // German format: 1.234,56
        await tester.enterText(priceFinder, '1.234,56');
        await tester.pump();
        // Should parse correctly as 1234.56
        expect(updatedItem?.unitPrice, 1234.56);
      },
    );

    testWidgets('Edge Case: Quantity 0 defaults to 1', (tester) async {
      final item = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 5,
        unitPrice: 10.0,
      );
      FridgeItem? updatedItem;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ScannedItemRow(
              item: item,
              onDelete: () {},
              onChanged: (val) => updatedItem = val,
            ),
          ),
        ),
      );

      final qtyFinder = find.byKey(const Key('quantityField'));
      await tester.enterText(qtyFinder, '0');
      await tester.pump();

      // Verify logic enforces 1
      expect(updatedItem?.quantity, 1);
    });

    testWidgets(
      'Fix: didUpdateWidget does not overwrite user input if parsed value matches (ignoring string format)',
      (tester) async {
        final item = createItem(unitPrice: 10.0);
        FridgeItem? updatedItem;

        await tester.pumpWidget(
          createTestWidget(
            item,
            onChanged: (val) => updatedItem = val,
            locale: const Locale('de'),
          ),
        );

        final priceFinder = find.byKey(const Key('priceField'));

        // User types "10"; which parses to 10.0 (matching item unitPrice)
        await tester.enterText(priceFinder, '10');
        await tester.pump();

        // Trigger dependency/widget update with SAME item
        await tester.pumpWidget(
          createTestWidget(
            item,
            onChanged: (val) => updatedItem = val,
            locale: const Locale('de'),
          ),
        );
        await tester.pump();

        final priceField = tester.widget<TextField>(priceFinder);

        // Should confirm we are comparing values, not strings.
        expect(priceField.controller?.text, '10');
      },
    );

    testWidgets('Fix: Robust handling of invalid format during rebuild', (
      tester,
    ) async {
      final item = createItem(unitPrice: 10.0);
      FridgeItem? updatedItem;

      // Use a custom builder to force rebuilds
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return createTestWidget(
              item,
              onChanged: (val) => updatedItem = val,
              locale: const Locale('de'),
            );
          },
        ),
      );

      final priceFinder = find.byKey(const Key('priceField'));

      // User types invalid text
      await tester.enterText(priceFinder, 'invalid');
      await tester.pump();

      // Force a rebuild from parent
      await tester.pumpWidget(
        createTestWidget(
          item,
          onChanged: (val) => updatedItem = val,
          locale: const Locale('de'),
        ),
      );
      await tester.pump();

      final priceField = tester.widget<TextField>(priceFinder);
      // Should be reset to valid format because "invalid" is invalid.
      expect(priceField.controller?.text, '10,00');
    });
  });
}
