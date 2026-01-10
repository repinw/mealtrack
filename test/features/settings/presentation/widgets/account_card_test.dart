import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/features/auth/presentation/my_sign_in_screen.dart';
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

  setUpAll(() async {
    await mockFirebaseInitialiseApp();
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    when(() => mockAuth.currentUser).thenReturn(mockUser);
  });

  Widget createSubject(User user) {
    return ProviderScope(
      overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
      child: MaterialApp(
        home: Scaffold(body: AccountCard(user: user)),
      ),
    );
  }

  testWidgets('AccountCard shows GuestModeCard for anonymous user', (
    tester,
  ) async {
    when(() => mockUser.isAnonymous).thenReturn(true);
    when(() => mockUser.uid).thenReturn('guest123');
    when(() => mockUser.displayName).thenReturn(null);
    when(() => mockUser.email).thenReturn(null);

    await tester.pumpWidget(createSubject(mockUser));
    await tester.pumpAndSettle();

    expect(find.byType(GuestModeCard), findsOneWidget);
    expect(find.byType(UserAccountCard), findsOneWidget);
    expect(find.text(AppLocalizations.guestMode), findsWidgets);
  });

  testWidgets('AccountCard hides GuestModeCard for authenticated user', (
    tester,
  ) async {
    when(() => mockUser.isAnonymous).thenReturn(false);
    when(() => mockUser.uid).thenReturn('user123');
    when(() => mockUser.displayName).thenReturn('User');
    when(() => mockUser.email).thenReturn('user@example.com');

    await tester.pumpWidget(createSubject(mockUser));
    await tester.pumpAndSettle();

    expect(find.byType(GuestModeCard), findsNothing);
    expect(find.byType(UserAccountCard), findsOneWidget);
  });

  group('Guest interactions', () {
    setUp(() {
      when(() => mockUser.isAnonymous).thenReturn(true);
      when(() => mockUser.uid).thenReturn('guest123');
      when(() => mockUser.displayName).thenReturn(null);
      when(() => mockUser.email).thenReturn(null);
      when(() => mockUser.delete()).thenAnswer((_) async {});
    });

    testWidgets('Opens LinkAccountBottomSheet when Link Account is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject(mockUser));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(FilledButton, Icons.link));
      await tester.pumpAndSettle();

      expect(find.byType(LinkAccountBottomSheet), findsOneWidget);
    }, skip: true); // TODO: Verify locally

    testWidgets(
      'Shows generic sign in screen when Create New Account is tapped',
      (tester) async {
        await tester.pumpWidget(createSubject(mockUser));
        await tester.pumpAndSettle();

        // Open bottom sheet
        await tester.tap(find.widgetWithIcon(FilledButton, Icons.link));
        await tester.pumpAndSettle();

        // Tap create new account button
        await tester.tap(find.widgetWithIcon(FilledButton, Icons.person_add));
        await tester.pump(); // Start transition
        await tester.pump(); // transition

        expect(find.byType(MySignInScreen), findsOneWidget);
      },
      skip: true,
    );

    testWidgets('Shows warning dialog when Use Existing Account is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject(mockUser));
      await tester.pumpAndSettle();

      // Open bottom sheet
      await tester.tap(find.widgetWithIcon(FilledButton, Icons.link));
      await tester.pumpAndSettle();

      // Tap existing account button
      await tester.tap(find.widgetWithIcon(OutlinedButton, Icons.login));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(AppLocalizations.warning), findsOneWidget);
    }, skip: true);

    testWidgets('Deletes account when confirming Use Existing Account', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject(mockUser));
      await tester.pumpAndSettle();

      // Open bottom sheet
      await tester.tap(find.widgetWithIcon(FilledButton, Icons.link));
      await tester.pumpAndSettle();

      // Tap existing account button
      await tester.tap(find.widgetWithIcon(OutlinedButton, Icons.login));
      await tester.pumpAndSettle();

      // Tap Proceed (red button)
      await tester.tap(
        find.widgetWithText(FilledButton, AppLocalizations.proceed),
      );
      await tester.pumpAndSettle();

      verify(() => mockUser.delete()).called(1);
    }, skip: true);

    testWidgets(
      'Does NOT delete account when cancelling Use Existing Account',
      (tester) async {
        await tester.pumpWidget(createSubject(mockUser));
        await tester.pumpAndSettle();

        // Open bottom sheet
        await tester.tap(find.widgetWithIcon(FilledButton, Icons.link));
        await tester.pumpAndSettle();

        // Tap existing account button
        await tester.tap(find.widgetWithIcon(OutlinedButton, Icons.login));
        await tester.pumpAndSettle();

        // Tap Cancel
        await tester.tap(
          find.widgetWithText(TextButton, AppLocalizations.cancel),
        );
        await tester.pumpAndSettle();

        verifyNever(() => mockUser.delete());
        expect(find.byType(AlertDialog), findsNothing);
      },
      skip: true,
    );
  });
}
