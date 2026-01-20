import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/router/app_router.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/share_intent_listener.dart';
import 'package:mealtrack/features/scanner/service/share_service.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mealtrack/core/models/fridge_item.dart';

class FakeScannerViewModel extends AsyncNotifier<List<FridgeItem>>
    implements ScannerViewModel {
  bool analyzeCalled = false;
  bool shouldThrow = false;

  @override
  Future<List<FridgeItem>> build() async => [];

  @override
  Future<void> analyzeSharedFile(XFile file) async {
    analyzeCalled = true;
    if (shouldThrow) {
      throw Exception('Mock analysis error');
    }
  }

  @override
  Future<void> analyzeImageFromCamera() async {}

  @override
  Future<void> analyzeImageFromGallery() async {}

  @override
  Future<void> analyzeImageFromPDF() async {}
}

class MockShareService extends AsyncNotifier<void>
    with Mock
    implements ShareService {
  @override
  Future<void> build() async {}
}

void main() {
  testWidgets('ShareIntentListener shows dialog when file is shared', (
    tester,
  ) async {
    final fakeScannerViewModel = FakeScannerViewModel();

    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scannerViewModelProvider.overrideWith(() => fakeScannerViewModel),
          shareServiceProvider.overrideWith(() => MockShareService()),
          navigatorKeyProvider.overrideWithValue(navigatorKey),
        ],
        child: ShareIntentListener(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: Text('Home')),
          ), // ...
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ShareIntentListener)),
    );
    container.read(latestSharedFileProvider.notifier).state = XFile(
      'test_receipt.jpg',
    );
    await tester.pumpAndSettle();

    expect(find.text('Beleg scannen?'), findsOneWidget);
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('ShareIntentListener proceeds when Yes is clicked', (
    tester,
  ) async {
    final fakeScannerViewModel = FakeScannerViewModel();

    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scannerViewModelProvider.overrideWith(() => fakeScannerViewModel),
          shareServiceProvider.overrideWith(() => MockShareService()),
          navigatorKeyProvider.overrideWithValue(navigatorKey),
        ],
        child: ShareIntentListener(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: Text('Home')),
          ),
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ShareIntentListener)),
    );
    container.read(latestSharedFileProvider.notifier).state = XFile(
      'test_receipt.jpg',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ja'));
    await tester.pump();
    await tester.pump(); // Start analysis

    await tester.pumpAndSettle(); // Finish analysis

    expect(fakeScannerViewModel.analyzeCalled, isTrue);
  });

  testWidgets('ShareIntentListener does not analyze when Cancel is clicked', (
    tester,
  ) async {
    final fakeScannerViewModel = FakeScannerViewModel();

    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scannerViewModelProvider.overrideWith(() => fakeScannerViewModel),
          shareServiceProvider.overrideWith(() => MockShareService()),
          navigatorKeyProvider.overrideWithValue(navigatorKey),
        ],
        child: ShareIntentListener(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: Text('Home')),
          ),
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ShareIntentListener)),
    );
    container.read(latestSharedFileProvider.notifier).state = XFile('test.jpg');
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(fakeScannerViewModel.analyzeCalled, isFalse);
  });

  testWidgets('ShareIntentListener shows SnackBar on analysis error', (
    tester,
  ) async {
    final fakeScannerViewModel = FakeScannerViewModel()..shouldThrow = true;

    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scannerViewModelProvider.overrideWith(() => fakeScannerViewModel),
          shareServiceProvider.overrideWith(() => MockShareService()),
          navigatorKeyProvider.overrideWithValue(navigatorKey),
        ],
        child: ShareIntentListener(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: Text('Home')),
          ),
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ShareIntentListener)),
    );
    container.read(latestSharedFileProvider.notifier).state = XFile('test.jpg');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ja'));
    await tester.pump();
    await tester.pump(); // Start analysis

    await tester.pumpAndSettle(); // Finish analysis with error

    // Loading dialog should be gone
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // SnackBar should be shown
    expect(find.byType(SnackBar), findsOneWidget);
    // Localization for receiptReadErrorFormat: "Der Kassenbon konnte nicht gelesen werden (Format-Fehler)."
    expect(
      find.textContaining('Der Kassenbon konnte nicht gelesen werden'),
      findsOneWidget,
    );
  });

  testWidgets('ShareIntentListener does nothing when file is null', (
    tester,
  ) async {
    final fakeScannerViewModel = FakeScannerViewModel();

    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scannerViewModelProvider.overrideWith(() => fakeScannerViewModel),
          shareServiceProvider.overrideWith(() => MockShareService()),
          navigatorKeyProvider.overrideWithValue(navigatorKey),
        ],
        child: ShareIntentListener(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: Text('Home')),
          ),
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ShareIntentListener)),
    );

    // Explicitly set null
    container.read(latestSharedFileProvider.notifier).state = null;
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(fakeScannerViewModel.analyzeCalled, isFalse);
  });
}
