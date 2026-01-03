import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAiService extends Mock implements FirebaseAiService {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseAiService mockAiService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockAiService = MockFirebaseAiService();
    when(() => mockAiService.initialize()).thenAnswer((_) async {});
  });

  test('appInitialization signs in anonymously if user is null', () async {
    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
        firebaseAiServiceProvider.overrideWithValue(mockAiService),
      ],
    );

    expect(mockAuth.currentUser, isNull);

    await container.read(appInitializationProvider.future);

    expect(mockAuth.currentUser, isNotNull);
    verify(() => mockAiService.initialize()).called(1);
  });

  test('appInitialization does not sign in if user already exists', () async {
    await mockAuth.signInAnonymously();
    final initialUser = mockAuth.currentUser;
    expect(initialUser, isNotNull);

    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
        firebaseAiServiceProvider.overrideWithValue(mockAiService),
      ],
    );

    await container.read(appInitializationProvider.future);

    expect(mockAuth.currentUser!.uid, equals(initialUser!.uid));
    verify(() => mockAiService.initialize()).called(1);
  });
}
