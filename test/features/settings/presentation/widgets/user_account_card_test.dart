import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/settings/presentation/widgets/user_account_card.dart';

import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    when(() => mockAuth.currentUser).thenReturn(mockUser);
  });

  Widget createSubject(User user) {
    return ProviderScope(
      overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
      child: MaterialApp(
        home: Scaffold(body: UserAccountCard(user: user)),
      ),
    );
  }

  testWidgets('UserAccountCard displays user info', (tester) async {
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.uid).thenReturn('12345');
    when(() => mockUser.isAnonymous).thenReturn(false);

    await tester.pumpWidget(createSubject(mockUser));

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('12345'), findsOneWidget);
  });

  testWidgets('UserAccountCard shows actions for non-anonymous user', (
    tester,
  ) async {
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.uid).thenReturn('12345');
    when(() => mockUser.isAnonymous).thenReturn(false);

    await tester.pumpWidget(createSubject(mockUser));

    expect(find.byIcon(Icons.logout), findsOneWidget);
    expect(find.byIcon(Icons.delete_forever), findsOneWidget);
  });

  testWidgets('UserAccountCard hides actions for anonymous user', (
    tester,
  ) async {
    when(() => mockUser.displayName).thenReturn(null);
    when(() => mockUser.email).thenReturn(null);
    when(() => mockUser.uid).thenReturn('12345');
    when(() => mockUser.isAnonymous).thenReturn(true);

    await tester.pumpWidget(createSubject(mockUser));

    expect(find.byIcon(Icons.logout), findsNothing);
    expect(find.byIcon(Icons.delete_forever), findsNothing);
  });
}
