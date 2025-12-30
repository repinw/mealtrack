import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_viewmodel.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';
import 'package:mealtrack/features/scanner/data/receipt_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockReceiptRepository extends Mock implements ReceiptRepository {}

class MockFilePicker extends Mock implements FilePicker {}

void main() {
  late MockImagePicker mockImagePicker;
  late MockReceiptRepository mockReceiptRepository;
  late MockFilePicker mockFilePicker;

  setUp(() {
    registerFallbackValue(XFile(''));
    mockImagePicker = MockImagePicker();
    mockReceiptRepository = MockReceiptRepository();
    mockFilePicker = MockFilePicker();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        imagePickerProvider.overrideWithValue(mockImagePicker),
        receiptRepositoryProvider.overrideWithValue(mockReceiptRepository),
        filePickerProvider.overrideWithValue(mockFilePicker),
        inventoryDisplayListProvider.overrideWith(
          (ref) => const AsyncValue.data(<InventoryDisplayItem>[]),
        ),
      ],
      child: const MaterialApp(home: InventoryPage(title: 'Digital Fridge')),
    );
  }

  group('InventorySpeedDial and Scanner Integration', () {
    testWidgets('InventoryPage displays SpeedDial initially', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(SpeedDial), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets(
      'Tapping gallery option picks image and navigates to ReceiptEditPage',
      (tester) async {
        final xFile = XFile('test_image.jpg');
        final scannedItems = [
          FridgeItem.create(
            name: 'Test Item',
            storeName: 'Store',
            quantity: 1,
            unitPrice: 1.99,
          ),
        ];

        final pickImageCompleter = Completer<XFile?>();
        final processImageCompleter = Completer<List<FridgeItem>>();

        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: any(named: 'maxWidth'),
            imageQuality: any(named: 'imageQuality'),
          ),
        ).thenAnswer((_) => pickImageCompleter.future);
        when(
          () => mockReceiptRepository.analyzeReceipt(xFile),
        ).thenAnswer((_) => processImageCompleter.future);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        final galleryButton = find.text(AppLocalizations.imageFromGallery);
        expect(galleryButton, findsOneWidget);
        await tester.tap(galleryButton);

        await tester.pump();

        pickImageCompleter.complete(xFile);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(SpeedDial), findsNothing);

        processImageCompleter.complete(scannedItems);
        await tester.pumpAndSettle();

        verify(
          () => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: any(named: 'maxWidth'),
            imageQuality: any(named: 'imageQuality'),
          ),
        ).called(1);
        verify(() => mockReceiptRepository.analyzeReceipt(xFile)).called(1);

        expect(find.byType(ReceiptEditPage), findsOneWidget);
      },
    );

    testWidgets('Does nothing if image picker is cancelled', (tester) async {
      when(
        () => mockImagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: any(named: 'maxWidth'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppLocalizations.imageFromGallery));
      await tester.pumpAndSettle();

      verify(
        () => mockImagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: any(named: 'maxWidth'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).called(1);
      verifyNever(() => mockReceiptRepository.analyzeReceipt(any()));
      expect(find.byType(ReceiptEditPage), findsNothing);
    });

    testWidgets(
      'Shows SnackBar and does not navigate when scanner returns empty list',
      (WidgetTester tester) async {
        final xFile = XFile('dummy_path/image.jpg');

        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: any(named: 'maxWidth'),
            imageQuality: any(named: 'imageQuality'),
          ),
        ).thenAnswer((_) async => xFile);
        when(
          () => mockReceiptRepository.analyzeReceipt(xFile),
        ).thenAnswer((_) async => []);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppLocalizations.imageFromGallery));
        await tester.pump();
        await tester.pump();
        await tester.pump();

        expect(find.text(AppLocalizations.noAvailableProducts), findsOneWidget);
        expect(find.byType(ReceiptEditPage), findsNothing);
      },
    );

    testWidgets(
      'Shows generic error SnackBar when scanner throws generic exception',
      (WidgetTester tester) async {
        final xFile = XFile('dummy_path/image.jpg');

        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: any(named: 'maxWidth'),
            imageQuality: any(named: 'imageQuality'),
          ),
        ).thenAnswer((_) async => xFile);
        when(
          () => mockReceiptRepository.analyzeReceipt(xFile),
        ).thenThrow(Exception('Generic API Error'));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppLocalizations.imageFromGallery));
        await tester.pump();
        await tester.pump();
        await tester.pump();

        expect(
          find.text(
            '${AppLocalizations.errorOccurred}Exception: Generic API Error',
          ),
          findsOneWidget,
        );
        expect(find.byType(ReceiptEditPage), findsNothing);
      },
    );

    testWidgets(
      'Shows formatted error SnackBar when ReceiptAnalysisException with INVALID_JSON code is thrown',
      (WidgetTester tester) async {
        final xFile = XFile('dummy_path/image.jpg');
        final exception = ReceiptAnalysisException(
          'Invalid JSON',
          code: 'INVALID_JSON',
        );

        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: any(named: 'maxWidth'),
            imageQuality: any(named: 'imageQuality'),
          ),
        ).thenAnswer((_) async => xFile);
        when(
          () => mockReceiptRepository.analyzeReceipt(xFile),
        ).thenThrow(exception);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppLocalizations.imageFromGallery));
        await tester.pump();
        await tester.pump();
        await tester.pump();

        expect(
          find.text(AppLocalizations.receiptReadErrorFormat),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Shows formatted error SnackBar when ReceiptAnalysisException wraps FormatException',
      (WidgetTester tester) async {
        final xFile = XFile('dummy_path/image.jpg');
        final exception = ReceiptAnalysisException(
          'Parsing failed',
          originalException: const FormatException('Invalid JSON'),
        );

        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: any(named: 'maxWidth'),
            imageQuality: any(named: 'imageQuality'),
          ),
        ).thenAnswer((_) async => xFile);
        when(
          () => mockReceiptRepository.analyzeReceipt(xFile),
        ).thenThrow(exception);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppLocalizations.imageFromGallery));
        await tester.pump();
        await tester.pump();
        await tester.pump();

        expect(
          find.text(AppLocalizations.receiptReadErrorFormat),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Tapping camera option picks image from camera and navigates to ReceiptEditPage',
      (tester) async {
        final xFile = XFile('test_image_camera.jpg');
        final scannedItems = [
          FridgeItem.create(
            name: 'Camera Item',
            storeName: 'Store',
            quantity: 1,
            unitPrice: 1.99,
          ),
        ];

        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: any(named: 'maxWidth'),
            imageQuality: any(named: 'imageQuality'),
          ),
        ).thenAnswer((_) async => xFile);
        when(
          () => mockReceiptRepository.analyzeReceipt(xFile),
        ).thenAnswer((_) async => scannedItems);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        final cameraButton = find.text(AppLocalizations.imageFromCamera);
        expect(cameraButton, findsOneWidget);
        await tester.tap(cameraButton);

        await tester.pump();
        await tester.pump();
        await tester.pumpAndSettle();

        verify(
          () => mockImagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: any(named: 'maxWidth'),
            imageQuality: any(named: 'imageQuality'),
          ),
        ).called(1);
        verify(() => mockReceiptRepository.analyzeReceipt(xFile)).called(1);

        expect(find.byType(ReceiptEditPage), findsOneWidget);
        expect(find.text('Camera Item'), findsOneWidget);
      },
    );

    testWidgets('Does nothing if image picker (camera) is cancelled', (
      tester,
    ) async {
      when(
        () => mockImagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: any(named: 'maxWidth'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppLocalizations.imageFromCamera));
      await tester.pumpAndSettle();

      verify(
        () => mockImagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: any(named: 'maxWidth'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).called(1);
      verifyNever(() => mockReceiptRepository.analyzeReceipt(any()));
      expect(find.byType(ReceiptEditPage), findsNothing);
    });

    testWidgets(
      'Tapping PDF option picks file and navigates to ReceiptEditPage',
      (tester) async {
        final file = PlatformFile(
          name: 'receipt.pdf',
          size: 100,
          path: 'path/to/receipt.pdf',
        );
        final result = FilePickerResult([file]);
        final scannedItems = [
          FridgeItem.create(
            name: 'PDF Item',
            storeName: 'Store',
            quantity: 1,
            unitPrice: 1.99,
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
        ).thenAnswer((_) async => scannedItems);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        final pdfButton = find.text(AppLocalizations.imageFromPdf);
        expect(pdfButton, findsOneWidget);
        await tester.tap(pdfButton);

        await tester.pump();
        await tester.pump();
        await tester.pumpAndSettle();

        verify(
          () => mockFilePicker.pickFiles(
            allowedExtensions: ['pdf'],
            type: FileType.custom,
          ),
        ).called(1);
        verify(() => mockReceiptRepository.analyzePdfReceipt(any())).called(1);

        expect(find.byType(ReceiptEditPage), findsOneWidget);
        expect(find.text('PDF Item'), findsOneWidget);
      },
    );

    testWidgets('Does nothing if file picker (PDF) is cancelled', (
      tester,
    ) async {
      when(
        () => mockFilePicker.pickFiles(
          allowedExtensions: ['pdf'],
          type: FileType.custom,
        ),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppLocalizations.imageFromPdf));
      await tester.pumpAndSettle();

      verify(
        () => mockFilePicker.pickFiles(
          allowedExtensions: ['pdf'],
          type: FileType.custom,
        ),
      ).called(1);
      verifyNever(() => mockReceiptRepository.analyzePdfReceipt(any()));
      expect(find.byType(ReceiptEditPage), findsNothing);
    });

    testWidgets(
      'Shows error message from ReceiptAnalysisException when not INVALID_JSON and not wrapping FormatException',
      (WidgetTester tester) async {
        final xFile = XFile('dummy_path/image.jpg');
        final exception = ReceiptAnalysisException(
          'Custom error message',
          code: 'SOME_OTHER_CODE',
        );

        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: any(named: 'maxWidth'),
            imageQuality: any(named: 'imageQuality'),
          ),
        ).thenAnswer((_) async => xFile);
        when(
          () => mockReceiptRepository.analyzeReceipt(xFile),
        ).thenThrow(exception);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppLocalizations.imageFromGallery));
        await tester.pump();
        await tester.pump();
        await tester.pump();

        expect(find.text('Custom error message'), findsOneWidget);
      },
    );

    testWidgets(
      'Shows formatted error SnackBar when error string contains FormatException',
      (WidgetTester tester) async {
        final xFile = XFile('dummy_path/image.jpg');

        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: any(named: 'maxWidth'),
            imageQuality: any(named: 'imageQuality'),
          ),
        ).thenAnswer((_) async => xFile);
        when(
          () => mockReceiptRepository.analyzeReceipt(xFile),
        ).thenThrow(const FormatException('Bad data'));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppLocalizations.imageFromGallery));
        await tester.pump();
        await tester.pump();
        await tester.pump();

        expect(
          find.text(AppLocalizations.receiptReadErrorFormat),
          findsOneWidget,
        );
      },
    );
  });
}
