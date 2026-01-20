import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/features/auth/presentation/viewmodel/guest_name_viewmodel.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;
  late FakeFirebaseFirestore fakeFirestore;
  late ProviderContainer container;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    fakeFirestore = FakeFirebaseFirestore();

    when(() => mockUser.uid).thenReturn('test_uid');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.isAnonymous).thenReturn(true);
    when(() => mockUser.displayName).thenReturn(null);
    when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});
    when(() => mockUser.reload()).thenAnswer((_) async {});

    when(() => mockUserCredential.user).thenReturn(mockUser);
    when(
      () => mockAuth.signInAnonymously(),
    ).thenAnswer((_) async => mockUserCredential);

    container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
        firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  GuestNameViewModel getViewModel() {
    return container.read(guestNameViewModelProvider.notifier);
  }

  group('GuestNameViewModel', () {
    test('initial state is AsyncData(null)', () {
      final state = container.read(guestNameViewModelProvider);
      expect(state, const AsyncData<void>(null));
    });

    test('submit with existing user updates name and reloads', () async {
      final viewModel = getViewModel();

      await viewModel.submit(name: 'New Name', user: mockUser);

      // Verify state is successful
      expect(
        container.read(guestNameViewModelProvider),
        const AsyncData<void>(null),
      );

      // Verify User interactions
      verify(() => mockUser.updateDisplayName('New Name')).called(1);
      verify(() => mockUser.reload()).called(1);

      // Verify Firestore interaction (UserExtension side-effect)
      final snapshot = await fakeFirestore
          .collection(usersCollection)
          .doc('test_uid')
          .get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()!['displayName'], 'New Name');

      // Verify NO signInAnonymously called
      verifyNever(() => mockAuth.signInAnonymously());
    });

    test(
      'submit with NO user (null) signs in anonymously then updates',
      () async {
        final viewModel = getViewModel();

        await viewModel.submit(name: 'Guest User', user: null);

        // Verify state is successful
        expect(
          container.read(guestNameViewModelProvider),
          const AsyncData<void>(null),
        );

        // Verify Auth interaction
        verify(() => mockAuth.signInAnonymously()).called(1);

        // Verify User interactions
        verify(() => mockUser.updateDisplayName('Guest User')).called(1);

        // Verify Firestore interaction
        final snapshot = await fakeFirestore
            .collection(usersCollection)
            .doc('test_uid')
            .get();
        expect(snapshot.exists, isTrue);
        expect(snapshot.data()!['displayName'], 'Guest User');
      },
    );

    test('submit sets state to error if signInAnonymously fails', () async {
      when(() => mockAuth.signInAnonymously()).thenThrow(
        FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Network error',
        ),
      );

      final viewModel = getViewModel();

      await viewModel.submit(name: 'Fail User', user: null);

      final state = container.read(guestNameViewModelProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<FirebaseAuthException>());
      expect(
        (state.error as FirebaseAuthException).code,
        'network-request-failed',
      );
    });

    test('submit sets state to error if updateDisplayName fails', () async {
      when(
        () => mockUser.updateDisplayName(any()),
      ).thenThrow(Exception('Update Failed'));

      final viewModel = getViewModel();

      await viewModel.submit(name: 'Fail Update', user: mockUser);

      final state = container.read(guestNameViewModelProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<Exception>());
      expect(state.error.toString(), contains('Update Failed'));
    });
  });
}
