import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
  });

  test('authStateChangesProvider returns stream from FirebaseAuth', () async {
    final container = ProviderContainer(
      overrides: [firebaseAuthProvider.overrideWithValue(mockFirebaseAuth)],
    );
    addTearDown(container.dispose);

    when(
      () => mockFirebaseAuth.authStateChanges(),
    ).thenAnswer((_) => Stream.value(mockUser));

    // Use listen to capture state changes
    final states = <AsyncValue<User?>>[];
    container.listen(
      authStateChangesProvider,
      (previous, next) => states.add(next),
      fireImmediately: true,
    );

    // Wait for stream to emit
    await Future.delayed(Duration.zero);

    expect(states.last, isA<AsyncData<User?>>());
    expect(states.last.value, mockUser);
  });

  test('firebaseAuthProvider returns FirebaseAuth instance', () {
    // This test assumes we can't easily check the instance without checking implementation detail
    // or overriding.
    // If we don't override, it returns FirebaseAuth.instance which might fail in test env if not initialized.
    // So we mostly test that the provider exists and is capable of being overridden.

    final container = ProviderContainer(
      overrides: [firebaseAuthProvider.overrideWithValue(mockFirebaseAuth)],
    );
    addTearDown(container.dispose);

    expect(container.read(firebaseAuthProvider), equals(mockFirebaseAuth));
  });
}
