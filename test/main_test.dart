import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/app.dart';

void main() {
  testWidgets('App starts with ProviderScope', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MealTrackApp()));
    await tester.pumpAndSettle();
    expect(find.byType(MealTrackApp), findsOneWidget);
  });
}
