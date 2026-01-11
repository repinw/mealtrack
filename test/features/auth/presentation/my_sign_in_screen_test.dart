import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/auth/presentation/my_sign_in_screen.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_core/firebase_core.dart';
import '../../../mock_firebase_setup.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockAuthCredential extends Mock implements AuthCredential {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await mockFirebaseInitialiseApp();

  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    registerFallbackValue(FakeAuthCredential());
    mockFirebaseAuth = MockFirebaseAuth();
    final mockApp = MockFirebaseApp();
    when(() => mockFirebaseAuth.app).thenReturn(mockApp);
  });

  testWidgets('MySignInScreen renders SignInScreen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: const MySignInScreen()),
        ),
      ),
    );

    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('MySignInScreen shows dialog on credential-already-in-use', (
    tester,
  ) async {
    final mockUser = MockUser();
    final mockCredential = MockUserCredential();
    final mockAuthCredential = MockAuthCredential();

    when(() => mockUser.delete()).thenAnswer((_) async {});
    when(
      () => mockFirebaseAuth.signInWithCredential(mockAuthCredential),
    ).thenAnswer((_) async => mockCredential);
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [firebaseAuthProvider.overrideWithValue(mockFirebaseAuth)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MySignInScreen(),
                    ),
                  );
                },
                child: const Text('Push'),
              ),
            ),
          ),
        ),
      ),
    );

    // Initial pump
    await tester.pumpAndSettle();

    // Push the screen
    await tester.tap(find.text('Push'));
    await tester.pumpAndSettle();

    final signInScreenFinder = find.byType(SignInScreen);
    expect(signInScreenFinder, findsOneWidget);

    final signInScreenWithActions = tester.widget<SignInScreen>(
      signInScreenFinder,
    );
    final authFailedAction = signInScreenWithActions.actions
        .whereType<AuthStateChangeAction<AuthFailed>>()
        .first;

    final exception = FirebaseAuthException(
      code: 'credential-already-in-use',
      credential: mockAuthCredential,
    );

    final BuildContext context = tester.element(signInScreenFinder);

    authFailedAction.callback(context, AuthFailed(exception));

    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Bestehendes'), findsOneWidget);
    expect(
      find.textContaining('Dieses Konto ist bereits registriert'),
      findsOneWidget,
    );

    expect(find.text('Abbrechen'), findsOneWidget);
    expect(find.text('Fortfahren'), findsOneWidget);

    await tester.tap(find.text('Fortfahren'));
    await tester.pump();

    verify(() => mockUser.delete()).called(1);
    verify(
      () => mockFirebaseAuth.signInWithCredential(mockAuthCredential),
    ).called(1);

    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('Sie wurden mit Ihrem bestehenden Konto angemeldet.'),
      findsOneWidget,
    );
  });
}
