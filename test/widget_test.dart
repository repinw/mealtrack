import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/discount.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_item_row.dart';

class FakeFridgeItem extends Fake implements FridgeItem {
  @override
  final String id;
  @override
  String rawText;
  @override
  String storeName;
  @override
  DateTime entryDate;
  @override
  String? weight;
  @override
  int quantity;
  @override
  bool isConsumed;
  @override
  DateTime? consumptionDate;
  @override
  List<Discount> discounts;
  @override
  String? receiptId;

  int saveCallCount = 0;

  FakeFridgeItem({
    this.id = 'test-id',
    this.rawText = 'Test Produkt',
    this.storeName = 'Test Laden',
    this.quantity = 1,
    this.weight,
    this.unitPrice,
    this.isConsumed = false,
    this.consumptionDate,
    List<Discount>? discounts,
    DateTime? entryDate,
    this.receiptId,
  }) : discounts = discounts ?? [],
       entryDate = entryDate ?? DateTime.now();

  @override
  Future<void> save() async {
    saveCallCount++;
    await Future.delayed(Duration.zero);
  }

  @override
  void markAsConsumed({DateTime? consumptionTime}) {
    isConsumed = true;
    consumptionDate = consumptionTime ?? DateTime.now();
  }
}

void main() {
  group('InventoryItemRow', () {
    testWidgets('displays item details correctly', (WidgetTester tester) async {
      final item = FakeFridgeItem(rawText: 'Leckere Milch', quantity: 5);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: InventoryItemRow(item: item)),
          ),
        ),
      );

      expect(find.text('Leckere Milch'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('increases quantity and saves on tapping +', (
      WidgetTester tester,
    ) async {
      final item = FakeFridgeItem(quantity: 1);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: InventoryItemRow(item: item)),
          ),
        ),
      );

      // Klick auf +
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(); // UI Update

      expect(find.text('2'), findsOneWidget);
      expect(item.quantity, 2);
      expect(
        item.saveCallCount,
        greaterThan(0),
        reason: 'save() sollte aufgerufen werden',
      );
    });

    testWidgets('decreases quantity and saves on tapping -', (
      WidgetTester tester,
    ) async {
      final item = FakeFridgeItem(quantity: 2);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: InventoryItemRow(item: item)),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(item.quantity, 1);
      expect(item.saveCallCount, greaterThan(0));
    });

    testWidgets('marks item as consumed when quantity drops to 0', (
      WidgetTester tester,
    ) async {
      final item = FakeFridgeItem(quantity: 1, isConsumed: false);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: InventoryItemRow(item: item)),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('0'), findsOneWidget);
      expect(item.quantity, 0);
      expect(item.isConsumed, isTrue);
      expect(item.consumptionDate, isNotNull);
      expect(item.saveCallCount, greaterThan(0));
    });
  });
}
