import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/discount.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_item_row.dart';

// Ein verbesserter Fake für FridgeItem, der sich wie das echte Hive-Objekt verhält,
// aber keine Datenbank benötigt.
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
  double? unitPrice;
  @override
  bool isConsumed;
  @override
  DateTime? consumptionDate;
  @override
  List<Discount> discounts;
  @override
  String? receiptId;

  // Hilfsvariable für Tests, um zu prüfen, ob gespeichert wurde
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
    // Simuliert asynchrones Speichern ohne Verzögerung im Test
    await Future.delayed(Duration.zero);
  }

  @override
  void markAsConsumed({DateTime? consumptionTime}) {
    isConsumed = true;
    consumptionDate = consumptionTime ?? DateTime.now();
    // Hinweis: Im echten Code ruft das Widget oft save() manuell auf,
    // nachdem es markAsConsumed() aufgerufen hat.
  }
}

void main() {
  group('InventoryItemRow', () {
    testWidgets('zeigt Artikeldetails korrekt an', (WidgetTester tester) async {
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

    testWidgets('erhöht die Menge und speichert beim Tippen auf +', (
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

    testWidgets('verringert die Menge und speichert beim Tippen auf -', (
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

      // Klick auf -
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(item.quantity, 1);
      expect(item.saveCallCount, greaterThan(0));
    });

    testWidgets('markiert Artikel als verbraucht, wenn Menge auf 0 fällt', (
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

      // Klick auf - (von 1 auf 0)
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
