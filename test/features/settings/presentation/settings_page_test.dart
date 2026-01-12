import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/l10n/app_localizations_de.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/settings/presentation/settings_page.dart';
import 'package:mealtrack/features/settings/presentation/widgets/account_card.dart';

import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  final l10n = AppLocalizationsDe();

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('123');
    when(() => mockUser.isAnonymous).thenReturn(false);
    when(() => mockUser.displayName).thenReturn('Test');
    when(() => mockUser.email).thenReturn('test@test.com');
  });

  Widget buildTestWidget({required List<Override> overrides}) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsPage(),
      ),
    );
  }

  testWidgets('SettingsPage shows AccountCard when user is logged in', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        overrides: [
          authStateChangesProvider.overrideWith(
            (ref) => Stream.value(mockUser),
          ),
          firebaseAuthProvider.overrideWithValue(mockAuth),
        ],
      ),
    );

    await tester.pump();

    expect(find.byType(AccountCard), findsOneWidget);
  });

  testWidgets('SettingsPage shows error message when auth stream has error', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        overrides: [
          authStateChangesProvider.overrideWith(
            (ref) => Stream.error(Exception('Auth service unavailable')),
          ),
          firebaseAuthProvider.overrideWithValue(mockAuth),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining(l10n.errorLabel), findsOneWidget);
    expect(find.textContaining('Auth service unavailable'), findsOneWidget);
    expect(find.byType(AccountCard), findsNothing);
  });

  testWidgets('SettingsPage shows loading indicator while waiting for auth', (
    tester,
  ) async {
    final neverCompleteController = StreamController<User?>();

    await tester.pumpWidget(
      buildTestWidget(
        overrides: [
          authStateChangesProvider.overrideWith(
            (ref) => neverCompleteController.stream,
          ),
          firebaseAuthProvider.overrideWithValue(mockAuth),
        ],
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(AccountCard), findsNothing);

    neverCompleteController.close();
  });
}
