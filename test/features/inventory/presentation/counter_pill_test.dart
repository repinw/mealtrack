import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/inventory/presentation/counter_pill.dart';

void main() {
  group('CounterPill', () {
    testWidgets('renders quantity text correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterPill(
              quantity: 42,
              isOutOfStock: false,
              onUpdate: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('displays black text when in stock', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterPill(
              quantity: 5,
              isOutOfStock: false,
              onUpdate: (_) {},
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('5'));
      expect(text.style?.color, Colors.black87);
    });

    testWidgets('displays grey text when out of stock', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterPill(
              quantity: 0,
              isOutOfStock: true,
              onUpdate: (_) {},
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('0'));
      expect(text.style?.color, Colors.grey);
    });

    testWidgets(
      'calls onUpdate(1) and updates local state when add is tapped',
      (tester) async {
        int? receivedValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CounterPill(
                quantity: 1,
                isOutOfStock: false,
                onUpdate: (val) => receivedValue = val,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump(); // Rebuild with local state

        expect(receivedValue, 1);
        expect(find.text('2'), findsOneWidget); // Optimistic update
      },
    );

    testWidgets(
      'calls onUpdate(-1) and updates local state when remove is tapped',
      (tester) async {
        int? receivedValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CounterPill(
                quantity: 2,
                isOutOfStock: false,
                onUpdate: (val) => receivedValue = val,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        expect(receivedValue, -1);
        expect(find.text('1'), findsOneWidget); 
      },
    );

    testWidgets('updates local state when widget prop changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterPill(
              quantity: 5,
              isOutOfStock: false,
              onUpdate: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterPill(
              quantity: 10, // External change
              isOutOfStock: false,
              onUpdate: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);
    });
  });
}
