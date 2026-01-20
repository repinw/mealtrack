import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/features/auth/presentation/guest_name_page.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';

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
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    mockObserver = MockNavigatorObserver();
    fakeFirestore = FakeFirebaseFirestore();

    registerFallbackValue(FakeRoute());

    // User Setup
    when(() => mockUser.uid).thenReturn('test_uid');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.isAnonymous).thenReturn(true);
    when(() => mockUser.displayName).thenReturn(null); // Default to no name

    // Extension method underlying calls
    when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});
    when(() => mockUser.reload()).thenAnswer((_) async {});

    // Auth Setup
    when(() => mockUserCredential.user).thenReturn(mockUser);
    when(
      () => mockAuth.signInAnonymously(),
    ).thenAnswer((_) async => mockUserCredential);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
  });

  Widget createWidgetUnderTest({
    Widget? home,
    NavigatorObserver? navigatorObserver,
  }) {
    return ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
        firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
      ],
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

  AppLocalizations getL10n(WidgetTester tester) {
    return AppLocalizations.of(tester.element(find.byType(GuestNamePage)))!;
  }

  testWidgets('GuestNamePage renders correctly', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final l10n = getL10n(tester);

    expect(find.text(l10n.howShouldWeCallYou), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text(l10n.next), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows loading indicator and disables button while submitting', (
    tester,
  ) async {
    final completer = Completer<UserCredential>();
    when(
      () => mockAuth.signInAnonymously(),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Loading User');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    // Verify loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(getL10n(tester).next), findsNothing);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    // Complete future
    completer.complete(mockUserCredential);
    await tester.pumpAndSettle();

    // Verify loading ended (and likely navigated away, but mostly loading check)
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Happy Path: signInAnonymously, syncs data, and navigates', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(navigatorObserver: mockObserver),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'New User');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // Verify Auth calls
    verify(() => mockAuth.signInAnonymously()).called(1);
    verify(() => mockUser.updateDisplayName('New User')).called(1);
    verify(() => mockUser.reload()).called(1);

    // Verify Firestore Data (checking UserExtension effect)
    final snapshot = await fakeFirestore
        .collection(usersCollection)
        .doc('test_uid')
        .get();
    expect(snapshot.exists, isTrue);
    expect(snapshot.data()!['displayName'], 'New User');
    expect(snapshot.data()!['isAnonymous'], isTrue);

    // Verify Navigation
    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
  });

  testWidgets('updates existing user if provided', (tester) async {
    when(() => mockUser.displayName).thenReturn('Old Name');

    await tester.pumpWidget(
      createWidgetUnderTest(
        home: GuestNamePage(user: mockUser),
        navigatorObserver: mockObserver,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Old Name'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Updated Name');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // Verify No SignInAnonymously
    verifyNever(() => mockAuth.signInAnonymously());

    // Verify Update Calls
    verify(() => mockUser.updateDisplayName('Updated Name')).called(1);
    verify(() => mockUser.reload()).called(1);

    // Verify Firestore Update
    final snapshot = await fakeFirestore
        .collection(usersCollection)
        .doc('test_uid')
        .get();
    expect(snapshot.exists, isTrue);
    expect(snapshot.data()!['displayName'], 'Updated Name');

    // Verify Navigation
    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
  });

  testWidgets('does nothing when name is empty or validation fails', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // Verify validaton error
    expect(find.text(getL10n(tester).enterValidName), findsOneWidget);
    verifyNever(() => mockAuth.signInAnonymously());

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // Verify validaton error for whitespace
    expect(find.text(getL10n(tester).enterValidName), findsOneWidget);
    verifyNever(() => mockAuth.signInAnonymously());
  });

  testWidgets('displays network error message when network fails', (
    tester,
  ) async {
    when(
      () => mockAuth.signInAnonymously(),
    ).thenThrow(FirebaseAuthException(code: 'network-request-failed'));

    await tester.pumpWidget(
      createWidgetUnderTest(navigatorObserver: mockObserver),
    );
    await tester.pumpAndSettle();

    // Clear initial navigation interactions
    clearInteractions(mockObserver);

    await tester.enterText(find.byType(TextField), 'Network Fail');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    final l10n = getL10n(tester);

    // Verify loading gone
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(l10n.retry), findsOneWidget);

    // Check Error Message
    expect(find.text(l10n.firstLoginRequiresInternet), findsOneWidget);

    // Verify No Navigation
    verifyNever(() => mockObserver.didPush(any(), any()));
  });

  testWidgets('displays generic error message for other errors', (
    tester,
  ) async {
    when(() => mockAuth.signInAnonymously()).thenThrow(
      FirebaseAuthException(code: 'unknown', message: 'Something went wrong'),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'General Error');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    final l10n = getL10n(tester);

    // Check Error Message format: '${l10n.errorLabel}${e.message}'
    expect(find.text('${l10n.errorLabel}Something went wrong'), findsOneWidget);
  });
}
