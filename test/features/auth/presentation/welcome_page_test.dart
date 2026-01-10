import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/auth/presentation/welcome_page.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mock_firebase_setup.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  await mockFirebaseInitialiseApp();

  late MockNavigatorObserver mockObserver;

  setUp(() {
    mockObserver = MockNavigatorObserver();
    registerFallbackValue(FakeRoute());
  });

  testWidgets('WelcomePage renders correctly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: WelcomePage())),
    );

    expect(find.text(AppLocalizations.welcomeTitle), findsOneWidget);
    expect(find.text(AppLocalizations.loginBtn), findsOneWidget);
    expect(find.text(AppLocalizations.continueGuestBtn), findsOneWidget);
  });

  testWidgets('WelcomePage navigates to AuthSignInScreen on login press', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const WelcomePage(),
          navigatorObservers: [mockObserver],
        ),
      ),
    );

    await tester.tap(find.text(AppLocalizations.loginBtn));
    await tester.pump();

    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
  });

  testWidgets('WelcomePage navigates to GuestNamePage on guest press', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const WelcomePage(),
          navigatorObservers: [mockObserver],
        ),
      ),
    );

    await tester.tap(find.text(AppLocalizations.continueGuestBtn));
    await tester.pump();

    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
  });
}
