import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/l10n/app_localizations_de.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/settings/presentation/widgets/account_card.dart';
import 'package:mealtrack/features/settings/presentation/widgets/guest_mode_card.dart';
import 'package:mealtrack/features/settings/presentation/widgets/link_account_bottom_sheet.dart';
import 'package:mealtrack/features/settings/presentation/widgets/user_account_card.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mock_firebase_setup.dart';

class MockUser extends Mock implements User {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  final l10n = AppLocalizationsDe();

  setUpAll(() async {
    await mockFirebaseInitialiseApp();
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    when(() => mockAuth.currentUser).thenReturn(mockUser);
  });

  Widget createAccountCardSubject(User user) {
    return ProviderScope(
      overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: AccountCard(user: user)),
      ),
    );
  }

  Widget createUserAccountCardSubject(User user) {
    return ProviderScope(
      overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: UserAccountCard(user: user)),
      ),
    );
  }

  void setupGuestUser() {
    when(() => mockUser.isAnonymous).thenReturn(true);
    when(() => mockUser.uid).thenReturn('guest123');
    when(() => mockUser.displayName).thenReturn(null);
    when(() => mockUser.email).thenReturn(null);
  }

  void setupAuthenticatedUser() {
    when(() => mockUser.isAnonymous).thenReturn(false);
    when(() => mockUser.uid).thenReturn('user123');
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.email).thenReturn('test@example.com');
  }

  group('AccountCard rendering', () {
    testWidgets('shows GuestModeCard for anonymous user', (tester) async {
      setupGuestUser();

      await tester.pumpWidget(createAccountCardSubject(mockUser));
      await tester.pumpAndSettle();

      expect(find.byType(GuestModeCard), findsOneWidget);
      expect(find.byType(UserAccountCard), findsOneWidget);
      expect(find.text(l10n.guestMode), findsWidgets);
    });

    testWidgets('hides GuestModeCard for authenticated user', (tester) async {
      setupAuthenticatedUser();

      await tester.pumpWidget(createAccountCardSubject(mockUser));
      await tester.pumpAndSettle();

      expect(find.byType(GuestModeCard), findsNothing);
      expect(find.byType(UserAccountCard), findsOneWidget);
    });
  });

  group('Guest interactions - Link Account', () {
    testWidgets('opens LinkAccountBottomSheet when Link Account is tapped', (
      tester,
    ) async {
      setupGuestUser();
      when(() => mockUser.delete()).thenAnswer((_) async {});

      await tester.pumpWidget(createAccountCardSubject(mockUser));
      await tester.pumpAndSettle();

      // Tap the Link Account button in GuestModeCard
      await tester.tap(find.text(l10n.linkAccount));
      await tester.pumpAndSettle();

      expect(find.byType(LinkAccountBottomSheet), findsOneWidget);
      expect(find.text(l10n.createNewAccount), findsOneWidget);
      expect(find.text(l10n.useExistingAccount), findsOneWidget);
    });

    testWidgets('shows warning dialog when Use Existing Account is tapped', (
      tester,
    ) async {
      setupGuestUser();
      when(() => mockUser.delete()).thenAnswer((_) async {});

      await tester.pumpWidget(createAccountCardSubject(mockUser));
      await tester.pumpAndSettle();

      // Open bottom sheet
      await tester.tap(find.text(l10n.linkAccount));
      await tester.pumpAndSettle();

      // Tap Use Existing Account button
      await tester.tap(
        find.widgetWithText(OutlinedButton, l10n.useExistingAccount),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(l10n.warning), findsOneWidget);
      expect(find.text(l10n.linkAccountExistingWarning), findsOneWidget);
    });

    testWidgets('deletes guest account when confirming Use Existing Account', (
      tester,
    ) async {
      setupGuestUser();
      when(() => mockUser.delete()).thenAnswer((_) async {});

      await tester.pumpWidget(createAccountCardSubject(mockUser));
      await tester.pumpAndSettle();

      // Open bottom sheet
      await tester.tap(find.text(l10n.linkAccount));
      await tester.pumpAndSettle();

      // Tap Use Existing Account button
      await tester.tap(
        find.widgetWithText(OutlinedButton, l10n.useExistingAccount),
      );
      await tester.pumpAndSettle();

      // Tap Proceed (confirm deletion)
      await tester.tap(find.widgetWithText(FilledButton, l10n.proceed));
      await tester.pumpAndSettle();

      verify(() => mockUser.delete()).called(1);
    });

    testWidgets(
      'does NOT delete account when cancelling Use Existing Account',
      (tester) async {
        setupGuestUser();
        when(() => mockUser.delete()).thenAnswer((_) async {});

        await tester.pumpWidget(createAccountCardSubject(mockUser));
        await tester.pumpAndSettle();

        // Open bottom sheet
        await tester.tap(find.text(l10n.linkAccount));
        await tester.pumpAndSettle();

        // Tap Use Existing Account button
        await tester.tap(
          find.widgetWithText(OutlinedButton, l10n.useExistingAccount),
        );
        await tester.pumpAndSettle();

        // Tap Cancel
        await tester.tap(find.widgetWithText(TextButton, l10n.cancel));
        await tester.pumpAndSettle();

        verifyNever(() => mockUser.delete());
        expect(find.byType(AlertDialog), findsNothing);
      },
    );
  });

  group('Authenticated user - Logout', () {
    testWidgets('calls signOut when Logout button is tapped', (tester) async {
      setupAuthenticatedUser();
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await tester.pumpWidget(createUserAccountCardSubject(mockUser));
      await tester.pumpAndSettle();

      // Find and tap the Logout button
      await tester.tap(find.text(l10n.logout));
      await tester.pumpAndSettle();

      verify(() => mockAuth.signOut()).called(1);
    });
  });

  group('Authenticated user - Delete Account', () {
    testWidgets('shows delete confirmation dialog when Delete is tapped', (
      tester,
    ) async {
      setupAuthenticatedUser();

      await tester.pumpWidget(createUserAccountCardSubject(mockUser));
      await tester.pumpAndSettle();

      // Find and tap the Delete Account button
      await tester.tap(find.text(l10n.deleteAccount));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(l10n.deleteAccountQuestion), findsOneWidget);
      expect(find.text(l10n.deleteAccountWarning), findsOneWidget);
    });

    testWidgets('deletes account when confirming deletion', (tester) async {
      setupAuthenticatedUser();
      when(() => mockUser.delete()).thenAnswer((_) async {});

      await tester.pumpWidget(createUserAccountCardSubject(mockUser));
      await tester.pumpAndSettle();

      // Tap Delete Account button
      await tester.tap(find.text(l10n.deleteAccount));
      await tester.pumpAndSettle();

      // Tap Delete (red confirmation button)
      await tester.tap(find.widgetWithText(FilledButton, l10n.delete));
      await tester.pumpAndSettle();

      verify(() => mockUser.delete()).called(1);
    });

    testWidgets('does NOT delete account when cancelling deletion', (
      tester,
    ) async {
      setupAuthenticatedUser();

      await tester.pumpWidget(createUserAccountCardSubject(mockUser));
      await tester.pumpAndSettle();

      // Tap Delete Account button
      await tester.tap(find.text(l10n.deleteAccount));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.widgetWithText(TextButton, l10n.cancel));
      await tester.pumpAndSettle();

      verifyNever(() => mockUser.delete());
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('shows error snackbar when delete fails with generic error', (
      tester,
    ) async {
      setupAuthenticatedUser();
      when(() => mockUser.delete()).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createUserAccountCardSubject(mockUser));
      await tester.pumpAndSettle();

      // Tap Delete Account button
      await tester.tap(find.text(l10n.deleteAccount));
      await tester.pumpAndSettle();

      // Tap Delete (red confirmation button)
      await tester.tap(find.widgetWithText(FilledButton, l10n.delete));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining(l10n.deleteAccountError), findsOneWidget);
    });
  });
}
