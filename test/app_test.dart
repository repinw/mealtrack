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

  testWidgets('MealTrackApp builds and displays HomePage', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MealTrackApp(
          imagePicker: mockImagePicker,
          firebaseAiService: mockFirebaseAiService,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('MealTrackApp has correct title and theme', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MealTrackApp(
          imagePicker: mockImagePicker,
          firebaseAiService: mockFirebaseAiService,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'MealTrack');
    expect(materialApp.theme?.useMaterial3, isTrue);
    expect(
      materialApp.theme?.colorScheme.primary,
      ColorScheme.fromSeed(seedColor: Colors.deepPurple).primary,
    );
  });

  testWidgets('MealTrackApp passes dependencies to HomePage', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MealTrackApp(
          imagePicker: mockImagePicker,
          firebaseAiService: mockFirebaseAiService,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final homePage = tester.widget<HomePage>(find.byType(HomePage));
    expect(homePage.imagePicker, mockImagePicker);
    expect(homePage.firebaseAiService, mockFirebaseAiService);
  });
}
