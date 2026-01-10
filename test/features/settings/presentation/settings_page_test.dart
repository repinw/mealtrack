import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/settings/presentation/settings_page.dart';
import 'package:mealtrack/features/settings/presentation/widgets/account_card.dart';

import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    // Default stubs
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('123');
    when(() => mockUser.isAnonymous).thenReturn(false);
    when(() => mockUser.displayName).thenReturn('Test');
    when(() => mockUser.email).thenReturn('test@test.com');
  });

  testWidgets('SettingsPage shows AccountCard when user is logged in', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith(
            (ref) => Stream.value(mockUser),
          ),
          firebaseAuthProvider.overrideWithValue(mockAuth),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );

    // Initial load
    await tester.pump();

    expect(find.byType(AccountCard), findsOneWidget);
  });
}
