import 'dart:async';

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

  @override
  Future<List<FridgeItem>> build() async => [];

  @override
  Future<void> analyzeSharedFile(XFile file) async {
    print('FakeScannerViewModel: analyzeSharedFile called with ${file.path}');
    analyzeCalled = true;
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scannerViewModelProvider.overrideWith(() => fakeScannerViewModel),
          shareServiceProvider.overrideWith(() => MockShareService()),
        ],
        child: ShareIntentListener(
          child: MaterialApp(
            navigatorKey: rootNavigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: Text('Home')),
          ),
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scannerViewModelProvider.overrideWith(() => fakeScannerViewModel),
          shareServiceProvider.overrideWith(() => MockShareService()),
        ],
        child: ShareIntentListener(
          child: MaterialApp(
            navigatorKey: rootNavigatorKey,
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
    await tester.pump();

    // We expect analyzeSharedFile to be called
    await tester.pumpAndSettle();

    expect(fakeScannerViewModel.analyzeCalled, isTrue);
  });
}
