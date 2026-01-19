import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/app.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';

class MockUser extends Mock implements User {}

class MockFirebaseAiService extends Mock implements FirebaseAiService {}

void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mock = MockFirebasePlatform();
  FirebasePlatform.instance = mock;
}

class MockFirebasePlatform extends Fake
    with MockPlatformInterfaceMixin
    implements FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return MockFirebaseApp();
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseApp();
  }

  @override
  List<FirebaseAppPlatform> get apps => [MockFirebaseApp()];
}

class MockFirebaseApp extends Fake implements FirebaseAppPlatform {
  @override
  String get name => defaultFirebaseAppName;

  @override
  FirebaseOptions get options => const FirebaseOptions(
    apiKey: 'test-api-key',
    appId: 'test-app-id',
    messagingSenderId: 'test-sender-id',
    projectId: 'test-project-id',
  );
}

void main() {
  late MockFirebaseAiService mockFirebaseAiService;

  setUpAll(() async {
    setupFirebaseCoreMocks();
  });

  setUp(() {
    mockFirebaseAiService = MockFirebaseAiService();
  });

  testWidgets('App starts with ProviderScope', (WidgetTester tester) async {
    when(() => mockFirebaseAiService.initialize()).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        firebaseAiServiceProvider.overrideWithValue(mockFirebaseAiService),

        authStateChangesProvider.overrideWith(
          (ref) => Stream.value(MockUser()),
        ),
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
    expect(find.byType(InventoryPage), findsOneWidget);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'MealTrack');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
