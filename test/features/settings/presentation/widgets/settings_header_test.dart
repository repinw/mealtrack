import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/features/settings/presentation/widgets/settings_header.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  group('SettingsHeader', () {
    testWidgets('renders settings title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsHeader())),
      );

      // Assert
      expect(find.text(AppLocalizations.settings), findsOneWidget);
    });

    testWidgets('renders settings description', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsHeader())),
      );

      // Assert
      expect(find.text(AppLocalizations.settingsDescription), findsOneWidget);
    });

    testWidgets('renders back button icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsHeader())),
      );

      // Assert
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders person icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsHeader())),
      );

      // Assert
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('back button triggers Navigator.pop', (tester) async {
      // Arrange
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [mockObserver],
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(body: SettingsHeader()),
                    ),
                  );
                },
                child: const Text('Go to Settings'),
              ),
            ),
          ),
        ),
      );

      // Navigate to the settings header
      await tester.tap(find.text('Go to Settings'));
      await tester.pumpAndSettle();

      // Act - tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Assert - verify pop was called
      verify(() => mockObserver.didPop(any(), any())).called(1);
    });
  });
}
