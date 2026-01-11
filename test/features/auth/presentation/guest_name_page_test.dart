import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/auth/presentation/guest_name_page.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
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

  Widget createWidgetUnderTest({
    Widget? home,
    NavigatorObserver? navigatorObserver,
  }) {
    return ProviderScope(
      overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home ?? const GuestNamePage(),
        navigatorObservers: navigatorObserver != null
            ? [navigatorObserver]
            : [],
      ),
    );
  }

  testWidgets('GuestNamePage renders correctly', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Allow localizations to load
    await tester.pumpAndSettle();

    expect(find.text('Wie möchtest du genannt werden?'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Weiter'), findsOneWidget);
  });

  testWidgets('GuestNamePage calls signInAnonymously and navigates', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(navigatorObserver: mockObserver),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Test Guest');
    await tester.tap(find.text('Weiter'));
    await tester.pump(); // Start async

    verify(() => mockAuth.signInAnonymously()).called(1);
    verify(() => mockUser.updateDisplayName('Test Guest')).called(1);

    // Check navigation
    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
  });

  testWidgets('GuestNamePage updates existing user if provided', (
    tester,
  ) async {
    when(() => mockUser.displayName).thenReturn('Old Name');

    await tester.pumpWidget(
      createWidgetUnderTest(
        home: GuestNamePage(user: mockUser),
        navigatorObserver: mockObserver,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Old Name'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'New Name');
    await tester.tap(find.text('Weiter'));
    await tester.pump();

    verifyNever(() => mockAuth.signInAnonymously());
    verify(() => mockUser.updateDisplayName('New Name')).called(1);
    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
  });

  testWidgets('does nothing when name is empty', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Don't enter any text, just tap the button
    await tester.tap(find.text('Weiter'));
    await tester.pump();

    // signInAnonymously should NOT be called
    verifyNever(() => mockAuth.signInAnonymously());
  });

  testWidgets('does nothing when name contains only whitespace', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Enter only whitespace
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Weiter'));
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

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Test Guest');
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();

    // Verify error snackbar is shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Fehler: '), findsOneWidget);
    expect(find.textContaining('A network error occurred.'), findsOneWidget);
  });

  testWidgets('shows error snackbar when updateDisplayName fails', (
    tester,
  ) async {
    when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'Failed to update display name.',
      );
    });

    await tester.pumpWidget(
      createWidgetUnderTest(navigatorObserver: mockObserver),
    );
    await tester.pumpAndSettle();

    clearInteractions(mockObserver);

    await tester.enterText(find.byType(TextField), 'Test Guest');
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();

    // Verify error snackbar is shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Fehler: '), findsOneWidget);
    expect(
      find.textContaining('Failed to update display name.'),
      findsOneWidget,
    );

    // Check that we did NOT navigate away
    verifyNever(() => mockObserver.didPush(any(), any()));
  });
}
