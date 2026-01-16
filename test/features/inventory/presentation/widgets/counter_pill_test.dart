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

    testWidgets('displays theme-based text color when in stock', (
      tester,
    ) async {
      final theme = ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue).copyWith(
          onSecondaryContainer: Colors.red, // Distinct color for verify
          secondaryContainer: Colors.blue,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
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
      expect(text.style?.color, theme.colorScheme.onSecondaryContainer);

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('5 / 10'),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, theme.colorScheme.secondaryContainer);
    });

    testWidgets('displays theme-based text color when out of stock', (
      tester,
    ) async {
      final theme = ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue).copyWith(
          onSurfaceVariant: Colors.purple, // Distinct color for verify
          surfaceContainerHighest: Colors.grey,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
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
      expect(text.style?.color, theme.colorScheme.onSurfaceVariant);

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('0 / 10'),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, theme.colorScheme.surfaceContainerHighest);
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

    testWidgets('buttons are disabled/not clickable when onUpdate is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CounterPill(
              quantity: 5,
              initialQuantity: 10,
              isOutOfStock: false,
              onUpdate: null, // Simulate archived/read-only state
            ),
          ),
        ),
      );

      // Verify Minus Button
      final minusInkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is ActionButton && w.icon == Icons.remove,
          ),
          matching: find.byType(InkWell),
        ),
      );
      expect(
        minusInkWell.onTap,
        isNull,
        reason: 'Minus button should be disabled',
      );

      // Verify Plus Button
      final plusInkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is ActionButton && w.icon == Icons.add,
          ),
          matching: find.byType(InkWell),
        ),
      );
      expect(
        plusInkWell.onTap,
        isNull,
        reason: 'Plus button should be disabled',
      );
    });
  });
}
