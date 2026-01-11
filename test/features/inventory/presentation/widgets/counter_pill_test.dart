import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/counter_pill.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/action_button.dart';

void main() {
  group('CounterPill', () {
    testWidgets('renders quantity/initialQuantity text correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterPill(
              quantity: 42,
              initialQuantity: 100,
              isOutOfStock: false,
              onUpdate: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('42 / 100'), findsOneWidget);
    });

    testWidgets('displays teal text when in stock', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterPill(
              quantity: 5,
              initialQuantity: 10,
              isOutOfStock: false,
              onUpdate: (_) {},
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('5 / 10'));
      expect(text.style?.color, Colors.teal);
    });

    testWidgets('displays grey text when out of stock', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterPill(
              quantity: 0,
              initialQuantity: 10,
              isOutOfStock: true,
              onUpdate: (_) {},
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('0 / 10'));
      expect(text.style?.color, Colors.grey);
    });

    testWidgets('plus button is disabled when canIncrease is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterPill(
              quantity: 10,
              initialQuantity: 10,
              isOutOfStock: false,
              canIncrease: false,
              onUpdate: (_) {},
            ),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is ActionButton && w.icon == Icons.add,
          ),
          matching: find.byType(InkWell),
        ),
      );
      expect(inkWell.onTap, isNull);
    });

    testWidgets(
      'plus button is enabled and calls onUpdate when canIncrease is true',
      (tester) async {
        bool called = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CounterPill(
                quantity: 5,
                initialQuantity: 10,
                isOutOfStock: false,
                canIncrease: true,
                onUpdate: (delta) {
                  if (delta == 1) called = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.add));
        expect(called, isTrue);
      },
    );

    testWidgets(
      'minus button is enabled and calls onUpdate when not out of stock',
      (tester) async {
        bool called = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CounterPill(
                quantity: 5,
                initialQuantity: 10,
                isOutOfStock: false,
                onUpdate: (delta) {
                  if (delta == -1) called = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.remove));
        expect(called, isTrue);
      },
    );

    testWidgets('minus button is disabled when out of stock', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterPill(
              quantity: 0,
              initialQuantity: 10,
              isOutOfStock: true,
              onUpdate: (_) {},
            ),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is ActionButton && w.icon == Icons.remove,
          ),
          matching: find.byType(InkWell),
        ),
      );
      expect(inkWell.onTap, isNull);
    });
  });
}
