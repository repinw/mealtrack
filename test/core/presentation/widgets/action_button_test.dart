import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/presentation/widgets/action_button.dart';

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

    testWidgets('icon color is inherited in active state', (
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
      expect(iconWidget.color, isNull);
    });

    testWidgets('icon color is inherited in disabled state (onTap is null)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ActionButton(icon: Icons.check, onTap: null)),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, isNull);

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
    });
  });
}
