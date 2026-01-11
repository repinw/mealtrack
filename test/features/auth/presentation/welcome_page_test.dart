import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/auth/presentation/welcome_page.dart';
import 'package:mealtrack/core/l10n/l10n.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mock_firebase_setup.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route {}

Widget buildTestWidget({List<NavigatorObserver>? navigatorObservers}) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('de'),
      home: const WelcomePage(),
      navigatorObservers: navigatorObservers ?? [],
    ),
  );
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  await mockFirebaseInitialiseApp();

  late MockNavigatorObserver mockObserver;

  setUp(() {
    mockObserver = MockNavigatorObserver();
    registerFallbackValue(FakeRoute());
  });

  testWidgets('WelcomePage renders correctly', (tester) async {
    await tester.pumpWidget(buildTestWidget());

    expect(find.text(L10n.welcomeTitle), findsOneWidget);
    expect(find.text(L10n.loginBtn), findsOneWidget);
    expect(find.text(L10n.continueGuestBtn), findsOneWidget);
  });

  testWidgets('WelcomePage navigates to AuthSignInScreen on login press', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(navigatorObservers: [mockObserver]),
    );

    await tester.tap(find.text(L10n.loginBtn));
    await tester.pump();

    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
  });

  testWidgets('WelcomePage navigates to GuestNamePage on guest press', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(navigatorObservers: [mockObserver]),
    );

    await tester.tap(find.text(L10n.continueGuestBtn));
    await tester.pump();

    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
  });
}
