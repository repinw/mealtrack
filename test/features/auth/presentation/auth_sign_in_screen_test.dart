import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/auth/presentation/auth_sign_in_screen.dart';
import 'package:mealtrack/features/auth/presentation/my_sign_in_screen.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import '../../../mock_firebase_setup.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await mockFirebaseInitialiseApp();

  testWidgets('AuthSignInScreen renders MySignInScreen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AuthSignInScreen(),
        ),
      ),
    );

    expect(find.byType(MySignInScreen), findsOneWidget);

    final mySignInScreen = tester.widget<MySignInScreen>(
      find.byType(MySignInScreen),
    );
    expect(mySignInScreen.mfaAction, isA<AuthStateChangeAction<MFARequired>>());
  });
}
