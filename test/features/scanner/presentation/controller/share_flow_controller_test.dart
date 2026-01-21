import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/scanner/presentation/controller/share_flow_controller.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:mealtrack/features/scanner/service/share_service.dart';
import 'package:mocktail/mocktail.dart';

class FakeScannerViewModel extends ScannerViewModel {
  int analyzeCallCount = 0;
  XFile? analyzedFile;
  bool shouldFail = false;

  @override
  Future<List<FridgeItem>> build() async => [];

  @override
  Future<void> analyzeSharedFile(XFile file) async {
    analyzeCallCount++;
    analyzedFile = file;
    if (shouldFail) {
      throw Exception('Simulated Error');
    }
  }
}

void main() {
  late FakeScannerViewModel fakeScannerViewModel;

  setUp(() {
    fakeScannerViewModel = FakeScannerViewModel();
    registerFallbackValue(XFile(''));
  });

  ProviderContainer makeContainer({LatestSharedFile? latestSharedFile}) {
    final container = ProviderContainer(
      overrides: [
        scannerViewModelProvider.overrideWith(() => fakeScannerViewModel),
        if (latestSharedFile != null)
          latestSharedFileProvider.overrideWith(() => latestSharedFile),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ShareFlowController', () {
    test('initial state is Initial', () {
      final container = makeContainer();
      final state = container.read(shareFlowControllerProvider);
      expect(state, const ShareFlowState.initial());
    });

    test(
      'updates to ConfirmationPending when latestSharedFileProvider receives file',
      () async {
        final container = makeContainer();
        container.listen(shareFlowControllerProvider, (_, _) {});

        final file = XFile('test.jpg');

        container.read(latestSharedFileProvider.notifier).state = file;

        final state = container.read(shareFlowControllerProvider);
        expect(state, ShareFlowState.confirmationPending(file));
      },
    );

    test('confirmScan triggers analysis and updates state', () async {
      final container = makeContainer();
      container.listen(shareFlowControllerProvider, (_, _) {});
      final file = XFile('test.jpg');

      // Set initial state
      container.read(latestSharedFileProvider.notifier).state = file;

      // Act
      final future = container
          .read(shareFlowControllerProvider.notifier)
          .confirmScan();

      // Assert analyzing state
      expect(
        container.read(shareFlowControllerProvider),
        const ShareFlowState.analyzing(),
      );

      // Wait for completion
      await future;

      expect(fakeScannerViewModel.analyzeCallCount, 1);
      expect(fakeScannerViewModel.analyzedFile, file);

      expect(
        container.read(shareFlowControllerProvider),
        const ShareFlowState.success(),
      );
      expect(container.read(latestSharedFileProvider), null);
    });

    test(
      'confirmScan handles error state from ScannerViewModel without exception',
      () async {
        final container = makeContainer();
        container.listen(shareFlowControllerProvider, (_, _) {});
        // Keep scannerViewModelProvider alive
        container.listen(scannerViewModelProvider, (_, _) {});

        fakeScannerViewModel.shouldFail = true;
        final file = XFile('test.jpg');

        // Set initial state
        container.read(latestSharedFileProvider.notifier).state = file;

        // Act
        await container
            .read(shareFlowControllerProvider.notifier)
            .confirmScan();

        // Assert error state
        final state = container.read(shareFlowControllerProvider);

        // Verification of failure: currently expected to fail because ShareFlowController sets success
        state.maybeWhen(
          error: (e) => expect(e.toString(), contains('Simulated Error')),
          orElse: () => fail('Expected error state, but got $state'),
        );

        expect(container.read(latestSharedFileProvider), null);
      },
    );
  });
}
