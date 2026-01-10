import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/auth/presentation/guest_name_page.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
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

    expect(find.text(AppLocalizations.howShouldWeCallYou), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text(AppLocalizations.next), findsOneWidget);
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
    await tester.tap(find.text(AppLocalizations.next));
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
    await tester.tap(find.text(AppLocalizations.next));
    await tester.pump();

    verifyNever(() => mockAuth.signInAnonymously());
    verify(() => mockUser.updateDisplayName('New Name')).called(1);
    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
  });
}
