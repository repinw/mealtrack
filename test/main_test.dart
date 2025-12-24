import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/app.dart';
import 'package:mealtrack/features/home/presentation/home_page.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockFirebaseAiService extends Mock implements FirebaseAiService {}

void main() {
  late MockImagePicker mockImagePicker;
  late MockFirebaseAiService mockFirebaseAiService;

  setUp(() {
    mockImagePicker = MockImagePicker();
    mockFirebaseAiService = MockFirebaseAiService();
  });

  testWidgets('App starts with ProviderScope', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MealTrackApp(
          imagePicker: mockImagePicker,
          firebaseAiService: mockFirebaseAiService,
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(MealTrackApp), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'MealTrack');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
