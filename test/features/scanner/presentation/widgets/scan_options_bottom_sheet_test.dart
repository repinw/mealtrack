import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mealtrack/core/l10n/l10n.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/features/scanner/data/receipt_repository.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';
import 'package:mealtrack/features/scanner/presentation/widgets/scan_options_bottom_sheet.dart';
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

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        imagePickerProvider.overrideWithValue(mockImagePicker),
        receiptRepositoryProvider.overrideWithValue(mockReceiptRepository),
        filePickerProvider.overrideWithValue(mockFilePicker),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ScanOptionsBottomSheet.show(context),
              child: const Text('Show Sheet'),
            ),
          ),
        ),
      ),
    );
  }

  group('ScanOptionsBottomSheet', () {
    testWidgets('renders all options', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.text(L10n.selectOption), findsOneWidget);
      expect(find.text(L10n.imageFromCamera), findsOneWidget);
      expect(find.text(L10n.imageFromGallery), findsOneWidget);
      expect(find.text(L10n.imageFromPdf), findsOneWidget);
    });

    testWidgets('tapping camera calls analyzeImageFromCamera', (tester) async {
      when(
        () => mockImagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1500,
          imageQuality: 80,
        ),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(L10n.imageFromCamera));
      await tester.pumpAndSettle();

      verify(
        () => mockImagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1500,
          imageQuality: 80,
        ),
      ).called(1);
    });

    testWidgets('tapping gallery calls analyzeImageFromGallery', (
      tester,
    ) async {
      when(
        () => mockImagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1500,
          imageQuality: 80,
        ),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(L10n.imageFromGallery));
      await tester.pumpAndSettle();

      verify(
        () => mockImagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1500,
          imageQuality: 80,
        ),
      ).called(1);
    });

    testWidgets('tapping PDF calls analyzeImageFromPDF', (tester) async {
      when(
        () => mockFilePicker.pickFiles(
          allowedExtensions: ['pdf'],
          type: FileType.custom,
        ),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(L10n.imageFromPdf));
      await tester.pumpAndSettle();

      verify(
        () => mockFilePicker.pickFiles(
          allowedExtensions: ['pdf'],
          type: FileType.custom,
        ),
      ).called(1);
    });

    testWidgets('navigates to ReceiptEditPage on success with items', (
      tester,
    ) async {
      final items = <FridgeItem>[
        FridgeItem.create(name: 'Milk', storeName: 'Test Store', quantity: 1),
      ];

      when(
        () => mockImagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1500,
          imageQuality: 80,
        ),
      ).thenAnswer((_) async => XFile('path/to/image.jpg'));

      when(
        () => mockReceiptRepository.analyzeReceipt(any()),
      ).thenAnswer((_) async => items);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(L10n.imageFromCamera));
      await tester.pumpAndSettle();

      expect(find.byType(ReceiptEditPage), findsOneWidget);
    });

    testWidgets('shows snackbar when no items found', (tester) async {
      when(
        () => mockImagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1500,
          imageQuality: 80,
        ),
      ).thenAnswer((_) async => XFile('path/to/image.jpg'));

      when(
        () => mockReceiptRepository.analyzeReceipt(any()),
      ).thenAnswer((_) async => <FridgeItem>[]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(L10n.imageFromCamera));
      await tester.pumpAndSettle();

      expect(find.text(L10n.noAvailableProducts), findsOneWidget);
    });

    testWidgets('shows snackbar when image picker returns null', (
      tester,
    ) async {
      when(
        () => mockImagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1500,
          imageQuality: 80,
        ),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(L10n.imageFromCamera));
      await tester.pumpAndSettle();

      expect(find.text(L10n.noAvailableProducts), findsOneWidget);
    });

    group('error handling', () {
      testWidgets('shows generic error snackbar on failure', (tester) async {
        const errorMessage = 'Read Error';
        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1500,
            imageQuality: 80,
          ),
        ).thenAnswer((_) async => XFile('path/to/image.jpg'));

        when(
          () => mockReceiptRepository.analyzeReceipt(any()),
        ).thenThrow(Exception(errorMessage));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Show Sheet'));
        await tester.pumpAndSettle();

        await tester.tap(find.text(L10n.imageFromCamera));
        await tester.pumpAndSettle();

        expect(
          find.textContaining(L10n.errorOccurred),
          findsOneWidget,
        );
      });

      testWidgets(
        'shows format error for ReceiptAnalysisException with INVALID_JSON code',
        (tester) async {
          final error = ReceiptAnalysisException(
            'JSON parse error',
            code: 'INVALID_JSON',
          );
          when(
            () => mockImagePicker.pickImage(
              source: ImageSource.camera,
              maxWidth: 1500,
              imageQuality: 80,
            ),
          ).thenAnswer((_) async => XFile('path/to/image.jpg'));

          when(
            () => mockReceiptRepository.analyzeReceipt(any()),
          ).thenThrow(error);

          await tester.pumpWidget(createWidgetUnderTest());
          await tester.tap(find.text('Show Sheet'));
          await tester.pumpAndSettle();

          await tester.tap(find.text(L10n.imageFromCamera));
          await tester.pumpAndSettle();

          expect(
            find.text(L10n.receiptReadErrorFormat),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows format error for ReceiptAnalysisException with FormatException as originalException',
        (tester) async {
          final error = ReceiptAnalysisException(
            'Parse failed',
            originalException: const FormatException('bad input'),
          );
          when(
            () => mockImagePicker.pickImage(
              source: ImageSource.camera,
              maxWidth: 1500,
              imageQuality: 80,
            ),
          ).thenAnswer((_) async => XFile('path/to/image.jpg'));

          when(
            () => mockReceiptRepository.analyzeReceipt(any()),
          ).thenThrow(error);

          await tester.pumpWidget(createWidgetUnderTest());
          await tester.tap(find.text('Show Sheet'));
          await tester.pumpAndSettle();

          await tester.tap(find.text(L10n.imageFromCamera));
          await tester.pumpAndSettle();

          expect(
            find.text(L10n.receiptReadErrorFormat),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows custom message for ReceiptAnalysisException with other error',
        (tester) async {
          const customMessage = 'Custom API error occurred';
          final error = ReceiptAnalysisException(
            customMessage,
            code: 'API_ERROR',
          );
          when(
            () => mockImagePicker.pickImage(
              source: ImageSource.camera,
              maxWidth: 1500,
              imageQuality: 80,
            ),
          ).thenAnswer((_) async => XFile('path/to/image.jpg'));

          when(
            () => mockReceiptRepository.analyzeReceipt(any()),
          ).thenThrow(error);

          await tester.pumpWidget(createWidgetUnderTest());
          await tester.tap(find.text('Show Sheet'));
          await tester.pumpAndSettle();

          await tester.tap(find.text(L10n.imageFromCamera));
          await tester.pumpAndSettle();

          expect(find.text(customMessage), findsOneWidget);
        },
      );

      testWidgets('shows format error when error contains FormatException', (
        tester,
      ) async {
        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1500,
            imageQuality: 80,
          ),
        ).thenAnswer((_) async => XFile('path/to/image.jpg'));

        when(
          () => mockReceiptRepository.analyzeReceipt(any()),
        ).thenThrow(const FormatException('unexpected character'));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Show Sheet'));
        await tester.pumpAndSettle();

        await tester.tap(find.text(L10n.imageFromCamera));
        await tester.pumpAndSettle();

        expect(
          find.text(L10n.receiptReadErrorFormat),
          findsOneWidget,
        );
      });
    });
  });
}
