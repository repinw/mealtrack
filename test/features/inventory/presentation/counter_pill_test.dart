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

    testWidgets('calls onUpdate(1) when add button is tapped', (tester) async {
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
      expect(receivedValue, 1);
    });

    testWidgets(
      'calls onUpdate(-1) when remove button is tapped and in stock',
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
        expect(receivedValue, -1);
      },
    );

    testWidgets(
      'does not call onUpdate when remove button is tapped and out of stock',
      (tester) async {
        bool wasCalled = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CounterPill(
                quantity: 0,
                isOutOfStock: true,
                onUpdate: (_) => wasCalled = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.remove));
        expect(wasCalled, isFalse);
      },
    );
  });
}
