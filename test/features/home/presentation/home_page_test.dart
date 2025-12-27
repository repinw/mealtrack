import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mealtrack/features/home/presentation/home_page.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_viewmodel.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';
import 'package:mealtrack/features/scanner/data/receipt_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockReceiptRepository extends Mock implements ReceiptRepository {}

void main() {
  late MockImagePicker mockImagePicker;
  late MockReceiptRepository mockReceiptRepository;

  setUp(() {
    registerFallbackValue(XFile(''));
    mockImagePicker = MockImagePicker();
    mockReceiptRepository = MockReceiptRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        imagePickerProvider.overrideWithValue(mockImagePicker),
        receiptRepositoryProvider.overrideWithValue(mockReceiptRepository),
        // Override inventoryDisplayListProvider to return empty list
        inventoryDisplayListProvider.overrideWith((ref) async => []),
      ],
      child: const MaterialApp(home: HomePage()),
    );
  }

  testWidgets('HomePage displays InventoryPage and SpeedDial initially', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(InventoryPage), findsOneWidget);
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

      final galleryButton = find.text('Bild aus Galerie');
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

    await tester.tap(find.text('Bild aus Galerie'));
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

      await tester.tap(find.text('Bild aus Galerie'));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Keine Produkte erkannt'), findsOneWidget);
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

      await tester.tap(find.text('Bild aus Galerie'));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Ein Fehler ist aufgetreten: Exception: Generic API Error'),
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

      await tester.tap(find.text('Bild aus Galerie'));
      await tester.pump(); // Trigger analysis
      await tester.pump(); // Handle error
      await tester.pump(); // Show snackbar

      expect(
        find.text('Der Kassenbon konnte nicht gelesen werden (Format-Fehler).'),
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

      await tester.tap(find.text('Bild aus Galerie'));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Der Kassenbon konnte nicht gelesen werden (Format-Fehler).'),
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

      final cameraButton = find.text('Bild aufnehmen');
      expect(cameraButton, findsOneWidget);
      await tester.tap(cameraButton);

      await tester.pump();
      await tester.pump(); // loading
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

    await tester.tap(find.text('Bild aufnehmen'));
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
}
