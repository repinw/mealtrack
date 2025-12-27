import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/home/presentation/home_viewmodel.dart';
import 'package:mealtrack/features/scanner/data/receipt_repository.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockReceiptRepository extends Mock implements ReceiptRepository {}

void main() {
  late MockImagePicker mockImagePicker;
  late MockReceiptRepository mockReceiptRepository;

  setUp(() {
    mockImagePicker = MockImagePicker();
    mockReceiptRepository = MockReceiptRepository();
    registerFallbackValue(XFile(''));
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        imagePickerProvider.overrideWithValue(mockImagePicker),
        receiptRepositoryProvider.overrideWithValue(mockReceiptRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('HomeViewModel', () {
    test('initial state is AsyncData([])', () async {
      final container = makeContainer();
      container.listen(homeViewModelProvider, (_, _) {});

      await container.read(homeViewModelProvider.future);

      final state = container.read(homeViewModelProvider);
      expect(state, isA<AsyncData<List<FridgeItem>>>());
      expect(state.value, isEmpty);
    });

    test('analyzeImageFromGallery success', () async {
      final container = makeContainer();
      final viewModel = container.read(homeViewModelProvider.notifier);
      container.listen(homeViewModelProvider, (_, _) {});

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

      final state = container.read(homeViewModelProvider);
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
        final viewModel = container.read(homeViewModelProvider.notifier);
        container.listen(homeViewModelProvider, (_, _) {});

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

        final state = container.read(homeViewModelProvider);
        expect(state, isA<AsyncData<List<FridgeItem>>>());
        expect(state.value, isEmpty);
      },
    );

    test(
      'analyzeImageFromGallery sets error state when repository throws',
      () async {
        final container = makeContainer();
        final viewModel = container.read(homeViewModelProvider.notifier);
        container.listen(homeViewModelProvider, (_, _) {});

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

        expect(container.read(homeViewModelProvider).hasError, true);
        expect(container.read(homeViewModelProvider).error, exception);
      },
    );

    test(
      'analyzeImageFromGallery sets error state when image compression fails',
      () async {
        final container = makeContainer();
        final viewModel = container.read(homeViewModelProvider.notifier);
        container.listen(homeViewModelProvider, (_, _) {});

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

        final state = container.read(homeViewModelProvider);
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
        final viewModel = container.read(homeViewModelProvider.notifier);
        container.listen(homeViewModelProvider, (_, _) {});

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

        final state = container.read(homeViewModelProvider);
        expect(state, isA<AsyncData<List<FridgeItem>>>());
        expect(state.value, isEmpty);
      },
    );
  });
}
