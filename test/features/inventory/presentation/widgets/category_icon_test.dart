import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list/inventory_item_row/category_icon.dart';

void main() {
  testWidgets('CategoryIcon renders specific icon and styling', (
    WidgetTester tester,
  ) async {
    const testName = 'Test Category';
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal).copyWith(
        secondaryContainer: Colors.amber,
        onSecondaryContainer: Colors.black,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const Scaffold(body: CategoryIcon(name: testName)),
      ),
    );

    final iconFinder = find.byIcon(Icons.kitchen_outlined);
    expect(iconFinder, findsOneWidget);

    final avatarFinder = find.byType(CircleAvatar);
    expect(avatarFinder, findsOneWidget);

    final CircleAvatar avatar = tester.widget(avatarFinder);
    final context = tester.element(avatarFinder);
    final colorScheme = Theme.of(context).colorScheme;
    expect(avatar.radius, 24);
    expect(avatar.backgroundColor, colorScheme.surfaceContainerHighest);

    final Icon icon = tester.widget(iconFinder);
    expect(icon.color, colorScheme.onSurfaceVariant);
    expect(icon.size, 22);
  });
}
