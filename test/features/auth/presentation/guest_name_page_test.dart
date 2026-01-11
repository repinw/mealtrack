import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/auth/presentation/guest_name_page.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/core/l10n/l10n.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;
  late MockNavigatorObserver mockObserver;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    mockObserver = MockNavigatorObserver();

    registerFallbackValue(FakeRoute());

    when(() => mockUserCredential.user).thenReturn(mockUser);
    when(
      () => mockAuth.signInAnonymously(),
    ).thenAnswer((_) async => mockUserCredential);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});
    when(() => mockUser.reload()).thenAnswer((_) async {});
  });

  testWidgets('GuestNamePage renders correctly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
        child: const MaterialApp(home: GuestNamePage()),
      ),
    );

    expect(find.text(L10n.howShouldWeCallYou), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text(L10n.next), findsOneWidget);
  });

  testWidgets('GuestNamePage calls signInAnonymously and navigates', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
        child: MaterialApp(
          home: const GuestNamePage(),
          navigatorObservers: [mockObserver],
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Test Guest');
    await tester.tap(find.text(L10n.next));
    await tester.pump(); // Start async

    verify(() => mockAuth.signInAnonymously()).called(1);
    verify(() => mockUser.updateDisplayName('Test Guest')).called(1);

    // Check navigation
    // pushAndRemoveUntil calls didPush (and didRemove)
    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
  });

  testWidgets('GuestNamePage updates existing user if provided', (
    tester,
  ) async {
    when(() => mockUser.displayName).thenReturn('Old Name');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
        child: MaterialApp(
          home: GuestNamePage(user: mockUser),
          navigatorObservers: [mockObserver],
        ),
      ),
    );

    expect(find.text('Old Name'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'New Name');
    await tester.tap(find.text(L10n.next));
    await tester.pump();

    verifyNever(() => mockAuth.signInAnonymously());
    verify(() => mockUser.updateDisplayName('New Name')).called(1);
    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
  });

  testWidgets('does nothing when name is empty', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
        child: const MaterialApp(home: GuestNamePage()),
      ),
    );

    // Don't enter any text, just tap the button
    await tester.tap(find.text(L10n.next));
    await tester.pump();

    // signInAnonymously should NOT be called
    verifyNever(() => mockAuth.signInAnonymously());
  });

  testWidgets('does nothing when name contains only whitespace', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
        child: const MaterialApp(home: GuestNamePage()),
      ),
    );

    // Enter only whitespace
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text(L10n.next));
    await tester.pump();

    // signInAnonymously should NOT be called
    verifyNever(() => mockAuth.signInAnonymously());
  });

  testWidgets('shows error snackbar when signInAnonymously fails', (
    tester,
  ) async {
    when(() => mockAuth.signInAnonymously()).thenThrow(
      FirebaseAuthException(
        code: 'network-request-failed',
        message: 'A network error occurred.',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
        child: const MaterialApp(home: GuestNamePage()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Test Guest');
    await tester.tap(find.text(L10n.next));
    await tester.pumpAndSettle();

    // Verify error snackbar is shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining(L10n.errorLabel), findsOneWidget);
    expect(find.textContaining('A network error occurred.'), findsOneWidget);
  });
}
