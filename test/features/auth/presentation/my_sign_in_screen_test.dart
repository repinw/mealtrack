import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/auth/presentation/my_sign_in_screen.dart';
import 'package:mocktail/mocktail.dart';
import '../../../mock_firebase_setup.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await mockFirebaseInitialiseApp();
  testWidgets('MySignInScreen renders SignInScreen', (tester) async {
    // We just verify it builds without exploding.

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: MySignInScreen(
              mfaAction: AuthStateChangeAction<MFARequired>(
                (context, state) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(true, isTrue);
  });
}
