import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/action_button.dart';

void main() {
  group('ActionButton Tests', () {
    testWidgets('displays the correct icon', (WidgetTester tester) async {
      const iconData = Icons.add;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(icon: iconData, onTap: () {}),
          ),
        ),
      );

      expect(find.byIcon(iconData), findsOneWidget);
    });

    testWidgets('executes callback on tap', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              icon: Icons.check,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ActionButton));
      expect(wasTapped, isTrue);
    });

    testWidgets('has correct color in active state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(icon: Icons.check, onTap: () {}),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, Colors.black87);
    });

    testWidgets('has correct color in disabled state (onTap is null)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ActionButton(icon: Icons.check, onTap: null)),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, Colors.grey.shade300);
    });
  });
}
