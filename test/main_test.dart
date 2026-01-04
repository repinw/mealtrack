import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/app.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mealtrack/core/provider/firestore_service.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';

import 'helpers/test_helpers.dart';

class MockFirebaseAiService extends Mock implements FirebaseAiService {}

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
        firestoreServiceProvider.overrideWith(
          (ref) => FirestoreService(FakeFirebaseFirestore(), 'test_user'),
        ),
        appInitializationProvider.overrideWith(
          (ref) async {},
        ), // Skip startup logic
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
