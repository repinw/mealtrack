import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/auth/presentation/welcome_page.dart';
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
    await tester.pumpAndSettle();

    expect(find.text('Willkommen bei MealTrack!'), findsOneWidget);
    expect(find.text('Einloggen'), findsOneWidget);
    expect(find.text('Als Gast fortsetzen'), findsOneWidget);
  });

  testWidgets('WelcomePage navigates to AuthSignInScreen on login press', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(navigatorObservers: [mockObserver]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Einloggen'));
    await tester.pump();

    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
  });

  testWidgets('WelcomePage navigates to GuestNamePage on guest press', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(navigatorObservers: [mockObserver]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Als Gast fortsetzen'));
    await tester.pump();

    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
  });
}
