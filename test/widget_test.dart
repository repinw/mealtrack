import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_item_row.dart';

// A fake implementation of FridgeItem to avoid database dependencies in tests.
class FakeFridgeItem extends Fake implements FridgeItem {
  @override
  String rawText;
  @override
  String? weight;
  @override
  int quantity;
  @override
  bool isConsumed;
  @override
  DateTime? consumptionDate;

  FakeFridgeItem({
    this.rawText = 'Test Item',
    this.weight = '500g',
    this.quantity = 1,
    this.isConsumed = false,
    this.consumptionDate,
  });

  @override
  Future<void> save() async {
    // Simulate a successful save operation
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  void markAsConsumed({DateTime? consumptionTime}) {
    isConsumed = true;
    consumptionDate = consumptionTime ?? DateTime.now();
  }
}

void main() {
  testWidgets('InventoryItemRow updates quantity and handles optimistic UI', (
    WidgetTester tester,
  ) async {
    final item = FakeFridgeItem(quantity: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: InventoryItemRow(item: item)),
      ),
    );

    // Verify initial state
    expect(find.text('Test Item'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    // Test Increment
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(); // Rebuild UI for optimistic update

    expect(find.text('2'), findsOneWidget);
    expect(item.quantity, 2);

    // Test Decrement
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(item.quantity, 1);
  });

  testWidgets('InventoryItemRow marks as consumed when quantity reaches 0', (
    WidgetTester tester,
  ) async {
    final item = FakeFridgeItem(quantity: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: InventoryItemRow(item: item)),
      ),
    );

    // Decrement to 0
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
    expect(item.quantity, 0);
    expect(item.isConsumed, isTrue);
  });
}
