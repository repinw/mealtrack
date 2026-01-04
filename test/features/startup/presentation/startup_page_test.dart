import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/startup/presentation/startup_page.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mealtrack/core/provider/firestore_service.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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
    apiKey: 'test',
    appId: 'test',
    messagingSenderId: 'test',
    projectId: 'test',
  );
}

void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebasePlatform.instance = MockFirebasePlatform();
}

void main() {
  setUpAll(() {
    setupFirebaseCoreMocks();
  });

  Widget createWidgetUnderTest(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: StartupPage()),
    );
  }

  testWidgets(
    'Scenario 1: Loading state shows CircularProgressIndicator and text',
    (tester) async {
      // Arrange
      final completer = Completer<void>();
      final container = ProviderContainer(
        overrides: [
          appInitializationProvider.overrideWith((ref) => completer.future),
        ],
      );
      addTearDown(container.dispose);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pump(); // Pump a frame to show loading

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('initialisiert'), findsOneWidget);
    },
  );

  testWidgets('Scenario 2: Error state shows error message and retry button', (
    tester,
  ) async {
    // Arrange
    final container = ProviderContainer(
      overrides: [
        appInitializationProvider.overrideWith(
          (ref) => Future.error('Test error'),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Act
    await tester.pumpWidget(createWidgetUnderTest(container));
    await tester.pumpAndSettle(); // Ensure UI settles

    // Assert
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.textContaining('Test error'), findsOneWidget);
    expect(find.text('Erneut versuchen'), findsOneWidget);

  });

  testWidgets('Scenario 3: Success state renders InventoryPage', (
    tester,
  ) async {
    // Arrange
    final container = ProviderContainer(
      overrides: [
        appInitializationProvider.overrideWith((ref) async {}), // Success
        firestoreServiceProvider.overrideWith(
          (ref) => FirestoreService(FakeFirebaseFirestore(), 'test_user'),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Act
    await tester.pumpWidget(createWidgetUnderTest(container));
    await tester.pump(); // Start future
    await tester.pump(); // Complete future

    // Assert
    expect(find.byType(InventoryPage), findsOneWidget);
  });
}
