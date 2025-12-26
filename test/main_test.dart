import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/app.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/features/home/presentation/home_page.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:mealtrack/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockFirebaseAiService extends Mock implements FirebaseAiService {}

void main() {
  late MockImagePicker mockImagePicker;
  late MockFirebaseAiService mockFirebaseAiService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockImagePicker = MockImagePicker();
    mockFirebaseAiService = MockFirebaseAiService();
  });

  testWidgets('App starts with ProviderScope', (WidgetTester tester) async {
    when(() => mockFirebaseAiService.initialize()).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        firebaseAiServiceProvider.overrideWithValue(mockFirebaseAiService),
      ],
    );
    addTearDown(container.dispose);
    await container.read(firebaseAiServiceProvider).initialize();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MealTrackApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MealTrackApp), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'MealTrack');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
