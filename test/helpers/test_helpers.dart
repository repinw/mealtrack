import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:mealtrack/core/provider/app_providers.dart';

/// ============================================================================
/// FIREBASE MOCKS
/// ============================================================================
/// These are required because Firebase needs to be initialized before tests run.
/// Without these mocks, any test that uses Firebase Auth or Firestore will fail.

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

/// Call this in setUpAll() for any test that uses Firebase
void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebasePlatform.instance = MockFirebasePlatform();
}

/// ============================================================================
/// WIDGET TEST WRAPPER
/// ============================================================================
/// This function wraps your widget in all the necessary parent widgets
/// (MaterialApp, ProviderScope, etc.) so you don't have to repeat it.

/// Creates a testable widget with the given [child] and [container].
///
/// **Why we need this:**
/// - `MaterialApp` is required for widgets that use Material Design components
/// - `UncontrolledProviderScope` lets us inject mock providers for testing
///
/// **Usage Example:**
/// ```dart
/// final container = ProviderContainer(overrides: [
///   authStateChangesProvider.overrideWith((ref) => Stream.value(mockUser)),
/// ]);
/// addTearDown(container.dispose);
///
/// await tester.pumpWidget(
///   createTestWidget(
///     container: container,
///     child: const SettingsPage(),
///   ),
/// );
/// ```
Widget createTestWidget({
  required Widget child,
  required ProviderContainer container,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      // Disable animations for faster tests
      debugShowCheckedModeBanner: false,
      home: child,
    ),
  );
}

/// Creates a ProviderContainer with auth state mocked to emit [user].
///
/// **Usage:**
/// ```dart
/// final container = createAuthContainer(mockUser);
/// addTearDown(container.dispose);
/// ```
ProviderContainer createAuthContainer(User? user) {
  return ProviderContainer(
    overrides: [
      authStateChangesProvider.overrideWith((ref) => Stream.value(user)),
    ],
  );
}

/// ============================================================================
/// COMMONLY USED FINDER EXTENSIONS
/// ============================================================================
/// Convenience methods to find widgets more easily

extension WidgetTesterExtensions on WidgetTester {
  /// Finds a widget containing specific text and taps it.
  ///
  /// **Usage:** `await tester.tapByText('Login');`
  Future<void> tapByText(String text) async {
    await tap(find.text(text));
    await pumpAndSettle();
  }

  /// Finds a button by its icon and taps it.
  ///
  /// **Usage:** `await tester.tapByIcon(Icons.arrow_back);`
  Future<void> tapByIcon(IconData icon) async {
    await tap(find.byIcon(icon));
    await pumpAndSettle();
  }
}

/// ============================================================================
/// ASSERTION HELPERS
/// ============================================================================
/// Shorthand methods for common test assertions

/// Asserts that a widget with [text] is visible on screen.
void expectText(String text) {
  expect(find.text(text), findsOneWidget);
}

/// Asserts that a widget with [text] is NOT on screen.
void expectNoText(String text) {
  expect(find.text(text), findsNothing);
}

/// Asserts that a widget of type [T] is visible on screen.
void expectWidget<T>() {
  expect(find.byType(T), findsOneWidget);
}

/// Asserts that NO widget of type [T] is on screen.
void expectNoWidget<T>() {
  expect(find.byType(T), findsNothing);
}
