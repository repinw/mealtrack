import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/sharing/presentation/widgets/join_section.dart';
import 'package:mealtrack/features/sharing/provider/sharing_provider.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class MockSharingViewModel extends SharingViewModel {
  AsyncValue<String?> _testState = const AsyncData(null);

  @override
  AsyncValue<String?> build() {
    return _testState;
  }

  void setState(AsyncValue<String?> newState) {
    _testState = newState;
    try {
      state = newState;
    } catch (_) {
      // Not initialized yet
    }
  }

  bool joinHouseholdCalled = false;
  String? lastJoinedCode;

  @override
  Future<void> joinHousehold(String code) async {
    joinHouseholdCalled = true;
    lastJoinedCode = code;
  }
}

void main() {
  late MockSharingViewModel mockSharingViewModel;

  setUp(() {
    mockSharingViewModel = MockSharingViewModel();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        sharingViewModelProvider.overrideWith(() => mockSharingViewModel),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('de'),
        home: Scaffold(body: JoinSection()),
      ),
    );
  }

  group('JoinSection', () {
    testWidgets('renders correctly', (tester) async {
      mockSharingViewModel.setState(const AsyncData(null));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Haushalt beitreten'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Sharing-Code eingeben'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('button is disabled when input is empty or invalid length', (
      tester,
    ) async {
      mockSharingViewModel.setState(const AsyncData(null));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      await tester.enterText(find.byType(TextField), '123');
      await tester.pump();

      final button3Digits = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button3Digits.onPressed, isNull);
    });

    testWidgets('button is enabled when input has 6 digits', (tester) async {
      mockSharingViewModel.setState(const AsyncData(null));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('calls joinHousehold when button is tapped with valid code', (
      tester,
    ) async {
      mockSharingViewModel.setState(const AsyncData(null));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      const validCode = '123456';
      await tester.enterText(find.byType(TextField), validCode);
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(mockSharingViewModel.joinHouseholdCalled, isTrue);
      expect(mockSharingViewModel.lastJoinedCode, validCode);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      tester,
    ) async {
      // Set loading state
      mockSharingViewModel.setState(const AsyncLoading<String?>());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Pump frame for loading

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsNothing);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows success snackbar and clears input on success', (
      tester,
    ) async {
      // Start with normal state
      mockSharingViewModel.setState(const AsyncData(null));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '654321');
      await tester.pump();

      // Trigger success state change to simulate provider update
      mockSharingViewModel.setState(const AsyncData('JOINED'));
      await tester.pump(); // Handle listener
      await tester.pumpAndSettle(); // Settle animation

      // Verify SnackBar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text('Haushalt beitreten'),
        ),
        findsOneWidget,
      );

      // Verify input cleared
      expect(find.text('654321'), findsNothing);
    });

    testWidgets('shows error snackbar for Code Expired', (tester) async {
      mockSharingViewModel.setState(const AsyncData(null));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Trigger error
      mockSharingViewModel.setState(
        AsyncError(Exception('Code Expired'), StackTrace.empty),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Code abgelaufen'), findsOneWidget);
    });

    testWidgets('shows error snackbar for Cannot Join Own Household', (
      tester,
    ) async {
      mockSharingViewModel.setState(const AsyncData(null));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      mockSharingViewModel.setState(
        AsyncError(Exception('Cannot Join Own Household'), StackTrace.empty),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Sie können nicht Ihrem eigenen Haushalt beitreten.'),
        findsOneWidget,
      );
    });

    testWidgets('shows error snackbar for Generic Error', (tester) async {
      mockSharingViewModel.setState(const AsyncData(null));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      mockSharingViewModel.setState(
        AsyncError(Exception('Some random error'), StackTrace.empty),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Ungültiger Code'), findsOneWidget);
    });
  });
}
