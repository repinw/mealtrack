import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/auth/presentation/auth_gate.dart';
import 'package:mealtrack/features/auth/presentation/welcome_page.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockUser extends Mock implements User {}

void main() {
  late MockUser mockUser;

  setUp(() {
    mockUser = MockUser();
  });

  Widget createWidgetUnderTest(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('de')],
        home: AuthGate(),
      ),
    );
  }

  // testWidgets('AuthGate shows CircularProgressIndicator when loading', (
  //   tester,
  // ) async {
  //   final container = ProviderContainer(
  //     overrides: [
  //       authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
  //     ],
  //   );
  //   addTearDown(container.dispose);

  //   await tester.pumpWidget(createWidgetUnderTest(container));
  //   await tester.pump(); // Initial load

  //   expect(find.byType(CircularProgressIndicator), findsOneWidget);
  // });

  // testWidgets('AuthGate shows WelcomePage when error occurs', (tester) async {
  //   final container = ProviderContainer(
  //     overrides: [
  //       authStateChangesProvider.overrideWith((ref) => Stream.error('Error')),
  //     ],
  //   );
  //   addTearDown(container.dispose);

  //   await tester.pumpWidget(createWidgetUnderTest(container));
  //   await tester.pump();

  //   // Expect WelcomePage
  //   expect(find.byType(WelcomePage), findsOneWidget);
  // });

  // testWidgets('AuthGate shows WelcomePage when user is null', (tester) async {
  //   final container = ProviderContainer(
  //     overrides: [
  //       authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
  //     ],
  //   );
  //   addTearDown(container.dispose);

  //   await tester.pumpWidget(createWidgetUnderTest(container));
  //   await tester.pump();

  //   expect(find.byType(WelcomePage), findsOneWidget);
  // });

  // TODO: Fix InventoryPage dependencies for this test
  // testWidgets('AuthGate shows InventoryPage when user is logged in', (tester) async {
  //    final container = ProviderContainer(
  //     overrides: [
  //       authStateChangesProvider.overrideWith((ref) => Stream.value(mockUser)),
  //       inventoryDisplayListProvider.overrideWith((ref) => const AsyncValue.data([])),
  //     ],
  //   );
  //   addTearDown(container.dispose);

  //   await tester.pumpWidget(createWidgetUnderTest(container));
  //   await tester.pump(); // Auth state
  //   await tester.pump(); // Inventory load

  //   expect(find.byType(InventoryPage), findsOneWidget);
  // });
}
