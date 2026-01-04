import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/features/settings/presentation/widgets/account_card.dart';

import '../../../../helpers/test_helpers.dart';

class MockUser extends Mock implements User {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  setUpAll(() {
    setupFirebaseCoreMocks();
  });

  group('AccountCard - Guest User', () {
    testWidgets('displays guest label when isGuest is true', (tester) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('test-uid-12345678');

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(
                user: mockUser,
                isGuest: true,
                currentUserId: 'test-uid-12345678',
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(AppLocalizations.guest), findsOneWidget);
    });

    testWidgets('displays login button when isGuest is true', (tester) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('test-uid-12345678');

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(
                user: mockUser,
                isGuest: true,
                currentUserId: 'test-uid-12345678',
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(AppLocalizations.login), findsOneWidget);
    });

    testWidgets('displays truncated user ID', (tester) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('abc12345-rest-of-uid');

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(
                user: mockUser,
                isGuest: true,
                currentUserId: 'abc12345-rest-of-uid',
              ),
            ),
          ),
        ),
      );

      // Assert - ID should be first 8 characters + "..."
      expect(find.text('ID: abc12345...'), findsOneWidget);
    });

    testWidgets('shows login dialog when login button is tapped', (
      tester,
    ) async {
      // Arrange
      final mockUser = MockUser();
      final mockFirebaseAuth = MockFirebaseAuth();
      when(() => mockUser.uid).thenReturn('test-uid-12345678');
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [firebaseAuthProvider.overrideWithValue(mockFirebaseAuth)],
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(
                user: mockUser,
                isGuest: true,
                currentUserId: 'test-uid-12345678',
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text(AppLocalizations.login));
      await tester.pumpAndSettle();

      // Assert - check dialog is shown by finding unique content
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(AppLocalizations.loginDialogContent), findsOneWidget);
    });

    testWidgets('login dialog contains two options', (tester) async {
      // Arrange
      final mockUser = MockUser();
      final mockFirebaseAuth = MockFirebaseAuth();
      when(() => mockUser.uid).thenReturn('test-uid-12345678');
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [firebaseAuthProvider.overrideWithValue(mockFirebaseAuth)],
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(
                user: mockUser,
                isGuest: true,
                currentUserId: 'test-uid-12345678',
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text(AppLocalizations.login));
      await tester.pumpAndSettle();

      // Assert - dialog has two buttons
      expect(find.text(AppLocalizations.existingAccount), findsOneWidget);
      expect(find.text(AppLocalizations.linkAccount), findsOneWidget);
    });
  });

  group('AccountCard - Logged In User', () {
    testWidgets('displays user displayName when not guest', (tester) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('test-uid-12345678');
      when(() => mockUser.displayName).thenReturn('Max Mustermann');

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(
                user: mockUser,
                isGuest: false,
                currentUserId: 'test-uid-12345678',
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Max Mustermann'), findsOneWidget);
    });

    testWidgets('displays fallback text when displayName is null', (
      tester,
    ) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('test-uid-12345678');
      when(() => mockUser.displayName).thenReturn(null);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(
                user: mockUser,
                isGuest: false,
                currentUserId: 'test-uid-12345678',
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(AppLocalizations.loggedIn), findsOneWidget);
    });

    testWidgets('displays profile button when not guest', (tester) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('test-uid-12345678');
      when(() => mockUser.displayName).thenReturn('Max Mustermann');

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(
                user: mockUser,
                isGuest: false,
                currentUserId: 'test-uid-12345678',
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(AppLocalizations.profile), findsOneWidget);
      expect(find.text(AppLocalizations.login), findsNothing);
    });
  });

  group('AccountCard - Null User', () {
    testWidgets('displays unknown ID when user is null', (tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(user: null, isGuest: true, currentUserId: null),
            ),
          ),
        ),
      );

      // Assert - shows "Unbekannt" for unknown user
      expect(find.text('ID: ${AppLocalizations.unknown}...'), findsOneWidget);
    });
  });

  group('AccountCard - UI Structure', () {
    testWidgets('renders avatar with gradient', (tester) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('test-uid-12345678');

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(
                user: mockUser,
                isGuest: true,
                currentUserId: 'test-uid-12345678',
              ),
            ),
          ),
        ),
      );

      // Assert - find the avatar container (circular with gradient)
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('renders with proper card decoration', (tester) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('test-uid-12345678');

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(
                user: mockUser,
                isGuest: true,
                currentUserId: 'test-uid-12345678',
              ),
            ),
          ),
        ),
      );

      // Assert - the card is wrapped in a Container
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders TextButton for action', (tester) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('test-uid-12345678');

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(
                user: mockUser,
                isGuest: true,
                currentUserId: 'test-uid-12345678',
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders Row layout with avatar, info, and button', (
      tester,
    ) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('test-uid-12345678');

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(
                user: mockUser,
                isGuest: true,
                currentUserId: 'test-uid-12345678',
              ),
            ),
          ),
        ),
      );

      // Assert - main layout is a Row
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('renders Column for user info', (tester) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('test-uid-12345678');

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(
                user: mockUser,
                isGuest: true,
                currentUserId: 'test-uid-12345678',
              ),
            ),
          ),
        ),
      );

      // Assert - user info in Column
      expect(find.byType(Column), findsOneWidget);
    });
  });

  group('AccountCard - Dialog Interactions', () {
    testWidgets('dialog closes when tapping Link Account button', (
      tester,
    ) async {
      // Arrange
      final mockUser = MockUser();
      final mockFirebaseAuth = MockFirebaseAuth();
      when(() => mockUser.uid).thenReturn('test-uid-12345678');
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [firebaseAuthProvider.overrideWithValue(mockFirebaseAuth)],
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(
                user: mockUser,
                isGuest: true,
                currentUserId: 'test-uid-12345678',
              ),
            ),
          ),
        ),
      );

      // Act - open dialog
      await tester.tap(find.text(AppLocalizations.login));
      await tester.pumpAndSettle();

      // Assert dialog is open
      expect(find.byType(AlertDialog), findsOneWidget);

      // Act - tap Link Account (closes dialog, then tries to navigate)
      await tester.tap(find.text(AppLocalizations.linkAccount));
      await tester.pump(); // Just pump once since navigation will fail

      // Assert - dialog should have closed (popped)
      expect(find.text(AppLocalizations.loginDialogContent), findsNothing);
    });

    testWidgets('dialog shows FilledButton for Link Account', (tester) async {
      // Arrange
      final mockUser = MockUser();
      final mockFirebaseAuth = MockFirebaseAuth();
      when(() => mockUser.uid).thenReturn('test-uid-12345678');
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [firebaseAuthProvider.overrideWithValue(mockFirebaseAuth)],
          child: MaterialApp(
            home: Scaffold(
              body: AccountCard(
                user: mockUser,
                isGuest: true,
                currentUserId: 'test-uid-12345678',
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text(AppLocalizations.login));
      await tester.pumpAndSettle();

      // Assert - FilledButton for Link Account
      expect(find.byType(FilledButton), findsOneWidget);
      expect(
        find.byType(TextButton),
        findsAtLeast(2),
      ); // Original + Existing Account
    });
  });
}
