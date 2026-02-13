import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/category_icon.dart';

void main() {
  testWidgets('CategoryIcon renders specific icon and styling', (
    WidgetTester tester,
  ) async {
    const testName = 'Test Category';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CategoryIcon(name: testName)),
      ),
    );

    final iconFinder = find.byIcon(Icons.kitchen);
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
