import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/sharing/presentation/widgets/invite_section.dart';
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

  bool generateCodeCalled = false;

  @override
  Future<void> generateCode() async {
    generateCodeCalled = true;
  }

  @override
  Future<void> joinHousehold(String code) async {}
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
        home: Scaffold(body: InviteSection()),
      ),
    );
  }

  testWidgets('Initial state shows generate code button', (tester) async {
    mockSharingViewModel.setState(const AsyncData(null));
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Code generieren'), findsOneWidget);
    expect(find.byIcon(Icons.qr_code), findsOneWidget);
  });

  testWidgets('Loading state shows progress indicator', (tester) async {
    mockSharingViewModel.setState(const AsyncLoading<String?>());
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.qr_code), findsNothing);
  });

  testWidgets('Loading state disables button', (tester) async {
    mockSharingViewModel.setState(const AsyncLoading<String?>());
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    final buttonFinder = find.ancestor(
      of: find.text('Code generieren'),
      matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
    );

    expect(buttonFinder, findsOneWidget);

    final button = tester.widget<ButtonStyleButton>(buttonFinder);
    expect(button.onPressed, isNull);
  });

  testWidgets('Success state shows invite code', (tester) async {
    const inviteCode = 'ABC-123';
    mockSharingViewModel.setState(const AsyncData(inviteCode));
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text(inviteCode), findsOneWidget);
    expect(find.text('Code ist für 24 Stunden gültig'), findsOneWidget);
    expect(find.text('Code kopieren'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('Copy code implementation copies to clipboard', (tester) async {
    const inviteCode = 'ABC-123';
    mockSharingViewModel.setState(const AsyncData(inviteCode));

    // Intercept clipboard
    final log = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      },
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Code kopieren'));
    await tester.pump(); // SnackBar animation start

    final clipboardCalls = log.where(
      (call) => call.method == 'Clipboard.setData',
    );
    expect(clipboardCalls, hasLength(1));
    expect(clipboardCalls.first.arguments['text'], inviteCode);

    expect(find.text('Code kopiert!'), findsOneWidget);
  });

  testWidgets('Refresh button calls generateCode', (tester) async {
    const inviteCode = 'ABC-123';
    mockSharingViewModel.setState(const AsyncData(inviteCode));
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.refresh));

    expect(mockSharingViewModel.generateCodeCalled, isTrue);
  });

  testWidgets('Error state shows SnackBar', (tester) async {
    // Initial state to load widget
    mockSharingViewModel.setState(const AsyncData(null));
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Trigger error using AsyncError
    final error = Exception('Failed to generate');
    mockSharingViewModel.setState(AsyncError(error, StackTrace.empty));
    await tester.pump(); // Process state change

    expect(find.text('Fehler: Exception: Failed to generate'), findsOneWidget);
  });
}
