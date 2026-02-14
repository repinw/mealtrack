import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/presentation/widgets/meal_section_card.dart';

void main() {
  group('MealSectionCard', () {
    testWidgets('shows empty label when no content is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          child: const MealSectionCard(
            title: 'Breakfast',
            emptyLabel: 'No entries',
          ),
        ),
      );

      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('No entries'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
      expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
    });

    testWidgets('respects initiallyExpanded for cards with content', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          child: const MealSectionCard(
            title: 'Lunch',
            initiallyExpanded: true,
            content: Text('Entry A'),
          ),
        ),
      );

      expect(find.text('Lunch'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
      expect(find.text('Entry A'), findsOneWidget);
    });

    testWidgets('toggles arrow icon on tap when content exists', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          child: const MealSectionCard(
            title: 'Dinner',
            content: Text('Entry B'),
          ),
        ),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });
  });
}

Widget _host({required Widget child}) {
  return MaterialApp(home: Scaffold(body: child));
}
