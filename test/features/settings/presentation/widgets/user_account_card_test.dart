import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/l10n/app_localizations_de.dart';
import 'package:mealtrack/core/models/user_profile.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/settings/presentation/widgets/user_account_card.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFirebaseAuthException extends Mock implements FirebaseAuthException {
  @override
  final String code;

  MockFirebaseAuthException({required this.code});
}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  final l10n = AppLocalizationsDe();

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    when(() => mockAuth.currentUser).thenReturn(mockUser);
  });

  Widget createSubject(User user) {
    final mockProfile = UserProfile(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      isAnonymous: user.isAnonymous,
    );

    return ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
        userProfileProvider.overrideWith((_) => Stream.value(mockProfile)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: UserAccountCard(user: user)),
      ),
    );
  }

  group('UserAccountCard display', () {
    testWidgets('displays user info', (tester) async {
      when(() => mockUser.displayName).thenReturn('Test User');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUser.uid).thenReturn('12345');
      when(() => mockUser.isAnonymous).thenReturn(false);

      await tester.pumpWidget(createSubject(mockUser));
      await tester.pumpAndSettle(); // Wait for stream to emit

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('12345'), findsOneWidget);
    });

    testWidgets('shows actions for non-anonymous user', (tester) async {
      when(() => mockUser.displayName).thenReturn('Test User');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUser.uid).thenReturn('12345');
      when(() => mockUser.isAnonymous).thenReturn(false);

      await tester.pumpWidget(createSubject(mockUser));

      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.byIcon(Icons.delete_forever), findsOneWidget);
    });

    testWidgets('hides actions for anonymous user', (tester) async {
      when(() => mockUser.displayName).thenReturn(null);
      when(() => mockUser.email).thenReturn(null);
      when(() => mockUser.uid).thenReturn('12345');
      when(() => mockUser.isAnonymous).thenReturn(true);

      await tester.pumpWidget(createSubject(mockUser));

      expect(find.byIcon(Icons.logout), findsNothing);
      expect(find.byIcon(Icons.delete_forever), findsNothing);
    });
  });

  group('Logout', () {
    testWidgets('calls signOut when logout button is pressed', (tester) async {
      when(() => mockUser.displayName).thenReturn('Test User');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUser.uid).thenReturn('12345');
      when(() => mockUser.isAnonymous).thenReturn(false);
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await tester.pumpWidget(createSubject(mockUser));

      // Find and tap the logout button
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // Verify signOut was called
      verify(() => mockAuth.signOut()).called(1);
    });
  });

  group('Delete Account', () {
    testWidgets('shows confirmation dialog when delete button is pressed', (
      tester,
    ) async {
      when(() => mockUser.displayName).thenReturn('Test User');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUser.uid).thenReturn('12345');
      when(() => mockUser.isAnonymous).thenReturn(false);

      await tester.pumpWidget(createSubject(mockUser));

      // Find and tap the delete button
      await tester.tap(find.byIcon(Icons.delete_forever));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text(l10n.deleteAccountQuestion), findsOneWidget);
      expect(find.text(l10n.deleteAccountWarning), findsOneWidget);
      expect(find.text(l10n.cancel), findsOneWidget);
      expect(find.text(l10n.delete), findsOneWidget);
    });

    testWidgets('cancelling dialog does not delete account', (tester) async {
      when(() => mockUser.displayName).thenReturn('Test User');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUser.uid).thenReturn('12345');
      when(() => mockUser.isAnonymous).thenReturn(false);

      await tester.pumpWidget(createSubject(mockUser));

      // Tap delete button to open dialog
      await tester.tap(find.byIcon(Icons.delete_forever));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();

      // Verify delete was NOT called
      verifyNever(() => mockUser.delete());
    });

    testWidgets('confirming dialog calls user.delete()', (tester) async {
      when(() => mockUser.displayName).thenReturn('Test User');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUser.uid).thenReturn('12345');
      when(() => mockUser.isAnonymous).thenReturn(false);
      when(() => mockUser.delete()).thenAnswer((_) async {});

      await tester.pumpWidget(createSubject(mockUser));

      // Tap delete button to open dialog
      await tester.tap(find.byIcon(Icons.delete_forever));
      await tester.pumpAndSettle();

      // Tap confirm (delete)
      await tester.tap(find.text(l10n.delete));
      await tester.pumpAndSettle();

      // Verify delete was called
      verify(() => mockUser.delete()).called(1);
    });

    testWidgets('shows error snackbar when delete fails with generic error', (
      tester,
    ) async {
      when(() => mockUser.displayName).thenReturn('Test User');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUser.uid).thenReturn('12345');
      when(() => mockUser.isAnonymous).thenReturn(false);
      when(() => mockUser.delete()).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createSubject(mockUser));

      // Tap delete button to open dialog
      await tester.tap(find.byIcon(Icons.delete_forever));
      await tester.pumpAndSettle();

      // Tap confirm (delete)
      await tester.tap(find.text(l10n.delete));
      await tester.pumpAndSettle();

      // Verify error snackbar appears
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining(l10n.deleteAccountError), findsOneWidget);
    });

    testWidgets(
      'shows reauthenticate dialog when requires-recent-login error occurs',
      (tester) async {
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.uid).thenReturn('12345');
        when(() => mockUser.isAnonymous).thenReturn(false);

        // First call throws requires-recent-login
        when(
          () => mockUser.delete(),
        ).thenThrow(MockFirebaseAuthException(code: 'requires-recent-login'));

        await tester.pumpWidget(createSubject(mockUser));

        // Tap delete button to open dialog
        await tester.tap(find.byIcon(Icons.delete_forever));
        await tester.pumpAndSettle();

        // Tap confirm (delete)
        await tester.tap(find.text(l10n.delete));
        await tester.pumpAndSettle();

        // The showReauthenticateDialog is from firebase_ui_auth and will show
        // We verify that delete was called and the error was handled
        verify(() => mockUser.delete()).called(1);

        // Since showReauthenticateDialog is a Firebase UI component, we can't
        // fully test its behavior in a unit test. The test verifies that the
        // code path is executed without crashing.
      },
      skip: true, // showReauthenticateDialog requires Firebase UI setup
    );
  });
}
