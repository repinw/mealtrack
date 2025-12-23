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
  group('Inventory Page', () {
    testWidgets('shows the correct title', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MealTrack());
      await tester.pumpAndSettle();

      // Verify that the app title is visible.
      // Using `find.textContaining` is more robust against minor text changes.
      expect(find.textContaining('Digitaler Kühlschrank'), findsOneWidget);
    });
  });
}
