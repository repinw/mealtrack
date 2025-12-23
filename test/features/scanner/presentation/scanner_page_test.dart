import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';
import 'package:mealtrack/features/scanner/presentation/scanner_page.dart';
import 'package:mealtrack/features/scanner/service/text_recognition_service.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockTextRecognitionService extends Mock
    implements TextRecognitionService {}

void main() {
  late MockImagePicker mockPicker;
  late MockTextRecognitionService mockTextRecognitionService;

  setUp(() {
    mockPicker = MockImagePicker();
    mockTextRecognitionService = MockTextRecognitionService();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ScannerPage(
        picker: mockPicker,
        textRecognitionService: mockTextRecognitionService,
      ),
    );
  }

  testWidgets('ScannerPage displays initial state correctly', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Scanner'), findsOneWidget);
    expect(find.text('Galerie öffnen'), findsOneWidget);
    expect(
      find.text('Klicke auf den Button, um einen Beispielbeleg zu scannen.'),
      findsOneWidget,
    );
  });

  testWidgets('ScannerPage processes image and navigates to results page', (
    tester,
  ) async {
    // Arrange
    final xFile = XFile('test_image.jpg');
    final scannedItems = [
      FridgeItem.create(
        name: 'Test Product',
        quantity: 1,
        weight: '500g',
        unitPrice: 1.99,
        storeName: 'Test Store',
      ),
    ];

    when(
      () => mockPicker.pickImage(source: ImageSource.gallery),
    ).thenAnswer((_) async => xFile);
    when(
      () => mockTextRecognitionService.processImage(xFile),
    ).thenAnswer((_) async => scannedItems);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Galerie öffnen'));

    // Assert loading state
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Act: wait for futures to complete (image processing and navigation)
    await tester.pumpAndSettle();

    // Assert: Verify results are displayed
    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('1.99 €'), findsOneWidget);
    expect(find.textContaining('Menge: 1'), findsOneWidget);
    expect(find.textContaining('500g'), findsOneWidget);
    expect(find.text('Test Store'), findsOneWidget);
  });

  testWidgets('ScannerPage handles errors gracefully', (tester) async {
    final xFile = XFile('test_image.jpg');

    when(
      () => mockPicker.pickImage(source: ImageSource.gallery),
    ).thenAnswer((_) async => xFile);
    when(
      () => mockTextRecognitionService.processImage(xFile),
    ).thenThrow(Exception('OCR Failed'));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Galerie öffnen'));

    await tester.pumpAndSettle();

    expect(find.text('Exception: OCR Failed'), findsOneWidget);
  });
}
