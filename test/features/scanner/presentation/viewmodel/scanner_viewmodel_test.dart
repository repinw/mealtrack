import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mealtrack/features/scanner/data/receipt_repository.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockReceiptRepository extends Mock implements ReceiptRepository {}

class MockFilePicker extends Mock implements FilePicker {}

void main() {
  late MockImagePicker mockImagePicker;
  late MockReceiptRepository mockReceiptRepository;
  late MockFilePicker mockFilePicker;

  setUp(() {
    mockImagePicker = MockImagePicker();
    mockReceiptRepository = MockReceiptRepository();
    mockFilePicker = MockFilePicker();
    registerFallbackValue(XFile(''));
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        imagePickerProvider.overrideWithValue(mockImagePicker),
        receiptRepositoryProvider.overrideWithValue(mockReceiptRepository),
        filePickerProvider.overrideWithValue(mockFilePicker),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ScannerViewModel', () {
    test('initial state is AsyncData([])', () async {
      final container = makeContainer();
      container.listen(scannerViewModelProvider, (_, _) {});

      await container.read(scannerViewModelProvider.future);

      final state = container.read(scannerViewModelProvider);
      expect(state, isA<AsyncData<List<FridgeItem>>>());
      expect(state.value, isEmpty);
    });

    test('analyzeImageFromGallery success', () async {
      final container = makeContainer();
      final viewModel = container.read(scannerViewModelProvider.notifier);
      container.listen(scannerViewModelProvider, (_, _) {});

      final file = XFile('path/to/image.jpg');
      final expectedItems = [
        FridgeItem.create(
          name: 'Apple',
          storeName: 'Store',
          quantity: 1,
          unitPrice: 1.0,
        ),
      ];

      when(
        () => mockImagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1500,
          imageQuality: 80,
        ),
      ).thenAnswer((_) async => file);

      when(
        () => mockReceiptRepository.analyzeReceipt(file),
      ).thenAnswer((_) async => expectedItems);

      await viewModel.analyzeImageFromGallery();

      verify(
        () => mockImagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1500,
          imageQuality: 80,
        ),
      ).called(1);
      verify(() => mockReceiptRepository.analyzeReceipt(file)).called(1);

      final state = container.read(scannerViewModelProvider);
      expect(state, isA<AsyncData<List<FridgeItem>>>());
      expect(state.value, hasLength(1));

      final item = state.value!.first;
      expect(item.name, 'Apple');
      expect(item.storeName, 'Store');
      expect(item.quantity, 1);
      expect(item.unitPrice, 1.0);
    });

    test(
      'analyzeImageFromGallery does nothing when image picker returns null',
      () async {
        final container = makeContainer();
        final viewModel = container.read(scannerViewModelProvider.notifier);
        container.listen(scannerViewModelProvider, (_, _) {});

        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1500,
            imageQuality: 80,
          ),
        ).thenAnswer((_) async => null);

        await viewModel.analyzeImageFromGallery();

        verify(
          () => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1500,
            imageQuality: 80,
          ),
        ).called(1);
        verifyNever(() => mockReceiptRepository.analyzeReceipt(any()));

        final state = container.read(scannerViewModelProvider);
        expect(state, isA<AsyncData<List<FridgeItem>>>());
        expect(state.value, isEmpty);
      },
    );

    test(
      'analyzeImageFromGallery sets error state when repository throws',
      () async {
        final container = makeContainer();
        final viewModel = container.read(scannerViewModelProvider.notifier);
        container.listen(scannerViewModelProvider, (_, _) {});

        final file = XFile('path/to/image.jpg');
        final exception = ReceiptAnalysisException(
          'Analysis Failed',
          code: 'TEST_ERROR',
        );

        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1500,
            imageQuality: 80,
          ),
        ).thenAnswer((_) async => file);

        when(
          () => mockReceiptRepository.analyzeReceipt(file),
        ).thenThrow(exception);

        await viewModel.analyzeImageFromGallery();

        expect(container.read(scannerViewModelProvider).hasError, true);
        expect(container.read(scannerViewModelProvider).error, exception);
      },
    );

    test(
      'analyzeImageFromGallery sets error state when image compression fails',
      () async {
        final container = makeContainer();
        final viewModel = container.read(scannerViewModelProvider.notifier);
        container.listen(scannerViewModelProvider, (_, _) {});

        final file = XFile('path/to/image.jpg');
        final exception = ReceiptAnalysisException(
          'Image compression failed',
          code: 'COMPRESSION_ERROR',
        );

        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1500,
            imageQuality: 80,
          ),
        ).thenAnswer((_) async => file);

        when(
          () => mockReceiptRepository.analyzeReceipt(file),
        ).thenThrow(exception);

        await viewModel.analyzeImageFromGallery();

        final state = container.read(scannerViewModelProvider);
        expect(state.hasError, true);
        expect(state.error, exception);
        expect(
          (state.error as ReceiptAnalysisException).code,
          'COMPRESSION_ERROR',
        );
      },
    );
    test(
      'analyzeImageFromGallery sets success state with empty list when repository returns empty',
      () async {
        final container = makeContainer();
        final viewModel = container.read(scannerViewModelProvider.notifier);
        container.listen(scannerViewModelProvider, (_, _) {});

        final file = XFile('path/to/image.jpg');

        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1500,
            imageQuality: 80,
          ),
        ).thenAnswer((_) async => file);

        when(
          () => mockReceiptRepository.analyzeReceipt(file),
        ).thenAnswer((_) async => []);

        await viewModel.analyzeImageFromGallery();

        final state = container.read(scannerViewModelProvider);
        expect(state, isA<AsyncData<List<FridgeItem>>>());
        expect(state.value, isEmpty);
      },
    );

    test('analyzeImageFromCamera success', () async {
      final container = makeContainer();
      final viewModel = container.read(scannerViewModelProvider.notifier);
      container.listen(scannerViewModelProvider, (_, _) {});

      final file = XFile('path/to/image.jpg');
      final expectedItems = [
        FridgeItem.create(
          name: 'Apple',
          storeName: 'Store',
          quantity: 1,
          unitPrice: 1.0,
        ),
      ];

      when(
        () => mockImagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1500,
          imageQuality: 80,
        ),
      ).thenAnswer((_) async => file);

      when(
        () => mockReceiptRepository.analyzeReceipt(file),
      ).thenAnswer((_) async => expectedItems);

      await viewModel.analyzeImageFromCamera();

      verify(
        () => mockImagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1500,
          imageQuality: 80,
        ),
      ).called(1);
      verify(() => mockReceiptRepository.analyzeReceipt(file)).called(1);

      final state = container.read(scannerViewModelProvider);
      expect(state, isA<AsyncData<List<FridgeItem>>>());
      expect(state.value, hasLength(1));
    });

    test(
      'analyzeImageFromCamera does nothing when image picker returns null',
      () async {
        final container = makeContainer();
        final viewModel = container.read(scannerViewModelProvider.notifier);
        container.listen(scannerViewModelProvider, (_, _) {});

        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1500,
            imageQuality: 80,
          ),
        ).thenAnswer((_) async => null);

        await viewModel.analyzeImageFromCamera();

        verify(
          () => mockImagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1500,
            imageQuality: 80,
          ),
        ).called(1);
        verifyNever(() => mockReceiptRepository.analyzeReceipt(any()));

        final state = container.read(scannerViewModelProvider);
        expect(state, isA<AsyncData<List<FridgeItem>>>());
        expect(state.value, isEmpty);
      },
    );

    test(
      'analyzeImageFromCamera sets error state when repository throws',
      () async {
        final container = makeContainer();
        final viewModel = container.read(scannerViewModelProvider.notifier);
        container.listen(scannerViewModelProvider, (_, _) {});

        final file = XFile('path/to/image.jpg');
        final exception = ReceiptAnalysisException(
          'Analysis Failed',
          code: 'TEST_ERROR',
        );

        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1500,
            imageQuality: 80,
          ),
        ).thenAnswer((_) async => file);

        when(
          () => mockReceiptRepository.analyzeReceipt(file),
        ).thenThrow(exception);

        await viewModel.analyzeImageFromCamera();

        expect(container.read(scannerViewModelProvider).hasError, true);
        expect(container.read(scannerViewModelProvider).error, exception);
      },
    );

    test('analyzeImageFromPDF success', () async {
      final container = makeContainer();
      final viewModel = container.read(scannerViewModelProvider.notifier);
      container.listen(scannerViewModelProvider, (_, _) {});

      final file = PlatformFile(
        name: 'receipt.pdf',
        size: 100,
        path: 'path/to/receipt.pdf',
      );
      final result = FilePickerResult([file]);

      final expectedItems = [
        FridgeItem.create(
          name: 'Apple',
          storeName: 'Store',
          quantity: 1,
          unitPrice: 1.0,
        ),
      ];

      when(
        () => mockFilePicker.pickFiles(
          allowedExtensions: ['pdf'],
          type: FileType.custom,
        ),
      ).thenAnswer((_) async => result);

      when(
        () => mockReceiptRepository.analyzePdfReceipt(any()),
      ).thenAnswer((_) async => expectedItems);

      await viewModel.analyzeImageFromPDF();

      verify(
        () => mockFilePicker.pickFiles(
          allowedExtensions: ['pdf'],
          type: FileType.custom,
        ),
      ).called(1);
      verify(() => mockReceiptRepository.analyzePdfReceipt(any())).called(1);

      final state = container.read(scannerViewModelProvider);
      expect(state, isA<AsyncData<List<FridgeItem>>>());
      expect(state.value, hasLength(1));
    });

    test(
      'analyzeImageFromPDF does nothing when file picker returns null (cancelled)',
      () async {
        final container = makeContainer();
        final viewModel = container.read(scannerViewModelProvider.notifier);
        container.listen(scannerViewModelProvider, (_, _) {});

        when(
          () => mockFilePicker.pickFiles(
            allowedExtensions: ['pdf'],
            type: FileType.custom,
          ),
        ).thenAnswer((_) async => null);

        await viewModel.analyzeImageFromPDF();

        verify(
          () => mockFilePicker.pickFiles(
            allowedExtensions: ['pdf'],
            type: FileType.custom,
          ),
        ).called(1);
        verifyNever(() => mockReceiptRepository.analyzePdfReceipt(any()));

        final state = container.read(scannerViewModelProvider);
        expect(state, isA<AsyncData<List<FridgeItem>>>());
        expect(state.value, isEmpty);
      },
    );

    test(
      'analyzeImageFromPDF throws FormatException when file extension is not pdf',
      () async {
        final container = makeContainer();
        final viewModel = container.read(scannerViewModelProvider.notifier);
        container.listen(scannerViewModelProvider, (_, _) {});

        final file = PlatformFile(
          name: 'receipt.jpg',
          size: 100,
          path: 'path/to/receipt.jpg',
        );
        final result = FilePickerResult([file]);

        when(
          () => mockFilePicker.pickFiles(
            allowedExtensions: ['pdf'],
            type: FileType.custom,
          ),
        ).thenAnswer((_) async => result);

        await viewModel.analyzeImageFromPDF();

        final state = container.read(scannerViewModelProvider);
        expect(state.hasError, true);
        expect(state.error, isA<FormatException>());
        expect(
          (state.error as FormatException).message,
          AppLocalizations.pleaseSelectPdf,
        );
      },
    );

    test(
      'analyzeImageFromPDF throws FormatException when path is null',
      () async {
        final container = makeContainer();
        final viewModel = container.read(scannerViewModelProvider.notifier);
        container.listen(scannerViewModelProvider, (_, _) {});

        final file = PlatformFile(name: 'receipt.pdf', size: 100, path: null);
        final result = FilePickerResult([file]);

        when(
          () => mockFilePicker.pickFiles(
            allowedExtensions: ['pdf'],
            type: FileType.custom,
          ),
        ).thenAnswer((_) async => result);

        await viewModel.analyzeImageFromPDF();

        final state = container.read(scannerViewModelProvider);
        expect(state.hasError, true);
        expect(state.error, isA<FormatException>());
        expect(
          (state.error as FormatException).message,
          AppLocalizations.pleaseSelectPdf,
        );
      },
    );

    test(
      'analyzeImageFromPDF sets error state when repository throws',
      () async {
        final container = makeContainer();
        final viewModel = container.read(scannerViewModelProvider.notifier);
        container.listen(scannerViewModelProvider, (_, _) {});

        final file = PlatformFile(
          name: 'receipt.pdf',
          size: 100,
          path: 'path/to/receipt.pdf',
        );
        final result = FilePickerResult([file]);
        final exception = ReceiptAnalysisException(
          'Analysis Failed',
          code: 'TEST_ERROR',
        );

        when(
          () => mockFilePicker.pickFiles(
            allowedExtensions: ['pdf'],
            type: FileType.custom,
          ),
        ).thenAnswer((_) async => result);

        when(
          () => mockReceiptRepository.analyzePdfReceipt(any()),
        ).thenThrow(exception);

        await viewModel.analyzeImageFromPDF();

        expect(container.read(scannerViewModelProvider).hasError, true);
        expect(container.read(scannerViewModelProvider).error, exception);
      },
    );
  });
}
