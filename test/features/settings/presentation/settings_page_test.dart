import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/features/settings/presentation/settings_page.dart';
import 'package:mealtrack/features/settings/presentation/widgets/account_card.dart';

import '../../../helpers/test_helpers.dart';

class MockUser extends Mock implements User {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  setUpAll(() {
    setupFirebaseCoreMocks();
    registerFallbackValue(FakeRoute());
  });

  group('Loading State', () {
    testWidgets('renders page while auth state is pending', (tester) async {
      // Arrange
      final completer = Completer<User?>();
      final container = ProviderContainer(
        overrides: [
          authStateChangesProvider.overrideWith(
            (ref) => Stream.fromFuture(completer.future),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Act
      await tester.pumpWidget(
        createTestWidget(container: container, child: const SettingsPage()),
      );

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Guest User State', () {
    testWidgets('displays guest label when user is anonymous', (tester) async {
      // Arrange
      final mockUser = MockUser();

      when(() => mockUser.isAnonymous).thenReturn(true);
      when(() => mockUser.uid).thenReturn('test-uid-12345678');
      when(() => mockUser.displayName).thenReturn(null);

      final container = createAuthContainer(mockUser);
      addTearDown(container.dispose);

      // Act
      await tester.pumpWidget(
        createTestWidget(container: container, child: const SettingsPage()),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(AppLocalizations.guest), findsOneWidget);
      expect(find.text(AppLocalizations.login), findsOneWidget);
    });

    testWidgets('displays truncated user ID for guest', (tester) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.isAnonymous).thenReturn(true);
      when(() => mockUser.uid).thenReturn('abc12345-rest-of-uid');
      when(() => mockUser.displayName).thenReturn(null);

      final container = createAuthContainer(mockUser);
      addTearDown(container.dispose);

      // Act
      await tester.pumpWidget(
        createTestWidget(container: container, child: const SettingsPage()),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('ID: abc12345'), findsOneWidget);
    });
  });

  group('Logged-In User State', () {
    testWidgets('displays user name when logged in with account', (
      tester,
    ) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.isAnonymous).thenReturn(false);
      when(() => mockUser.uid).thenReturn('logged-in-user-123');
      when(() => mockUser.displayName).thenReturn('Max Mustermann');

      final container = createAuthContainer(mockUser);
      addTearDown(container.dispose);

      // Act
      await tester.pumpWidget(
        createTestWidget(container: container, child: const SettingsPage()),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Max Mustermann'), findsOneWidget);
      expect(find.text(AppLocalizations.profile ?? 'Profil'), findsOneWidget);
    });

    testWidgets('displays "Angemeldet" when displayName is null', (
      tester,
    ) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.isAnonymous).thenReturn(false);
      when(() => mockUser.uid).thenReturn('user-no-name12345');
      when(() => mockUser.displayName).thenReturn(null);

      final container = createAuthContainer(mockUser);
      addTearDown(container.dispose);

      // Act
      await tester.pumpWidget(
        createTestWidget(container: container, child: const SettingsPage()),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(AppLocalizations.loggedIn), findsOneWidget);
    });
  });

  group('UI Structure', () {
    testWidgets('contains all expected sections', (tester) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.isAnonymous).thenReturn(true);
      when(() => mockUser.uid).thenReturn('test-uid-12345678');
      when(() => mockUser.displayName).thenReturn(null);

      final container = createAuthContainer(mockUser);
      addTearDown(container.dispose);

      // Act
      await tester.pumpWidget(
        createTestWidget(container: container, child: const SettingsPage()),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(AppLocalizations.settings), findsOneWidget);
      expect(find.text(AppLocalizations.account), findsOneWidget);
      expect(find.text(AppLocalizations.accountDescription), findsOneWidget);
      expect(find.byType(AccountCard), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  testWidgets('Back button navigates back', (tester) async {
    // Arrange
    final mockObserver = MockNavigatorObserver();
    final mockUser = MockUser();
    when(() => mockUser.isAnonymous).thenReturn(true);
    when(() => mockUser.uid).thenReturn('test-uid-12345678');
    when(() => mockUser.displayName).thenReturn(null);

    final container = createAuthContainer(mockUser);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: const SettingsPage(),
          navigatorObservers: [mockObserver],
        ),
      ),
    );

    // Act
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    // Assert
    verify(() => mockObserver.didPop(any(), any())).called(1);
  });

  testWidgets('Login button shows dialog', (tester) async {
    // Arrange
    final mockUser = MockUser();
    when(() => mockUser.isAnonymous).thenReturn(true);
    when(() => mockUser.uid).thenReturn('test-uid-12345678');
    when(() => mockUser.displayName).thenReturn(null);

    final container = createAuthContainer(mockUser);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsPage()),
      ),
    );

    // Act
    await tester.tap(find.text(AppLocalizations.login));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(AppLocalizations.loginDialogContent), findsOneWidget);
  });

  testWidgets('Profile button is visible for logged-in user', (tester) async {
    // Arrange
    final mockUser = MockUser();
    when(() => mockUser.isAnonymous).thenReturn(false);
    when(() => mockUser.uid).thenReturn('test-uid-12345678');
    when(() => mockUser.displayName).thenReturn('Max Mustermann');

    final container = createAuthContainer(mockUser);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    // Assert - Profile button is shown (not Login button)
    expect(find.text(AppLocalizations.profile), findsOneWidget);
    expect(find.text(AppLocalizations.login), findsNothing);
  });
}
