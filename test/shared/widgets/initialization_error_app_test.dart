import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/shared/widgets/initialization_error_app.dart';

void main() {
  testWidgets('InitializationErrorApp renders error message', (tester) async {
    await tester.pumpWidget(const InitializationErrorApp());

    expect(
      find.textContaining('App konnte nicht initialisiert werden'),
      findsOneWidget,
    );
  });
}
