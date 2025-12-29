import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/presentation/item_details.dart';

void main() {
  Widget buildTestWidget(FridgeItem item, {bool isOutOfStock = false}) {
    return MaterialApp(
      home: Scaffold(
        body: ItemDetails(item: item, isOutOfStock: isOutOfStock),
      ),
    );
  }

  group('ItemDetails', () {
    testWidgets('displays item name', (tester) async {
      final item = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 1.0,
      );

      await tester.pumpWidget(buildTestWidget(item));
      expect(find.text('Test Item'), findsOneWidget);
    });

    testWidgets('displays brand when provided', (tester) async {
      final item = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 1.0,
        brand: 'Test Brand',
      );

      await tester.pumpWidget(buildTestWidget(item));
      expect(find.text('Test Brand'), findsOneWidget);
    });

    testWidgets('does not display brand when null', (tester) async {
      final item = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 1.0,
      );

      await tester.pumpWidget(buildTestWidget(item));
      expect(find.text('Test Brand'), findsNothing);
    });

    testWidgets('does not display brand when empty', (tester) async {
      final item = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 1.0,
        brand: '',
      );

      await tester.pumpWidget(buildTestWidget(item));
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('displays weight when provided', (tester) async {
      final item = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 1.0,
        weight: '500g',
      );

      await tester.pumpWidget(buildTestWidget(item));
      expect(find.text('500g'), findsOneWidget);
    });

    testWidgets('does not display weight when null', (tester) async {
      final item = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 1.0,
      );

      await tester.pumpWidget(buildTestWidget(item));
      expect(find.text('500g'), findsNothing);
    });

    testWidgets('does not display weight when empty', (tester) async {
      final item = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 1.0,
        weight: '',
      );

      await tester.pumpWidget(buildTestWidget(item));
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('applies out of stock styling when isOutOfStock is true', (
      tester,
    ) async {
      final item = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 1.0,
      );

      await tester.pumpWidget(buildTestWidget(item, isOutOfStock: true));

      final nameText = tester.widget<Text>(find.text('Test Item'));
      expect(nameText.style?.decoration, TextDecoration.lineThrough);
      expect(nameText.style?.color, Colors.grey);
    });

    testWidgets(
      'does not apply out of stock styling when isOutOfStock is false',
      (tester) async {
        final item = FridgeItem.create(
          name: 'Test Item',
          storeName: 'Store',
          quantity: 1,
          unitPrice: 1.0,
        );

        await tester.pumpWidget(buildTestWidget(item, isOutOfStock: false));

        final nameText = tester.widget<Text>(find.text('Test Item'));
        expect(nameText.style?.decoration, isNot(TextDecoration.lineThrough));
      },
    );

    testWidgets('displays all fields together', (tester) async {
      final item = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 1.0,
        brand: 'Premium Brand',
        weight: '1kg',
      );

      await tester.pumpWidget(buildTestWidget(item));
      expect(find.text('Premium Brand'), findsOneWidget);
      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text('1kg'), findsOneWidget);
    });
  });
}
