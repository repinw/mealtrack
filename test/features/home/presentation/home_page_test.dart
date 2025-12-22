import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/home/presentation/home_page.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';
import 'package:mealtrack/features/scanner/service/text_recognition_service.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockTextRecognitionService extends Mock
    implements TextRecognitionService {}

void main() {
  late MockImagePicker mockImagePicker;
  late MockTextRecognitionService mockTextRecognitionService;

  setUp(() {
    registerFallbackValue(XFile(''));
    mockImagePicker = MockImagePicker();
    mockTextRecognitionService = MockTextRecognitionService();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: HomePage(
        imagePicker: mockImagePicker,
        textRecognitionService: mockTextRecognitionService,
      ),
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
          rawText: 'Test Item',
          storeName: 'Store',
          quantity: 1,
          unitPrice: 1.99,
        ),
      ];

      final pickImageCompleter = Completer<XFile?>();

      when(
        () => mockImagePicker.pickImage(source: ImageSource.gallery),
      ).thenAnswer((_) => pickImageCompleter.future);
      when(
        () => mockTextRecognitionService.processImage(xFile),
      ).thenAnswer((_) async => scannedItems);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final galleryButton = find.text('Bild aus Galerie');
      expect(galleryButton, findsOneWidget);
      await tester.tap(galleryButton);

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(SpeedDial), findsNothing);

      pickImageCompleter.complete(xFile);

      await tester.pumpAndSettle();

      verify(
        () => mockImagePicker.pickImage(source: ImageSource.gallery),
      ).called(1);
      verify(() => mockTextRecognitionService.processImage(xFile)).called(1);

      expect(find.byType(ReceiptEditPage), findsOneWidget);
    },
  );

  testWidgets('Does nothing if image picker is cancelled', (tester) async {
    when(
      () => mockImagePicker.pickImage(source: ImageSource.gallery),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bild aus Galerie'));
    await tester.pumpAndSettle();

    verify(
      () => mockImagePicker.pickImage(source: ImageSource.gallery),
    ).called(1);
    verifyNever(() => mockTextRecognitionService.processImage(any()));
    expect(find.byType(ReceiptEditPage), findsNothing);
  });

  testWidgets('Shows error SnackBar on exception', (tester) async {
    final xFile = XFile('test_image.jpg');
    when(
      () => mockImagePicker.pickImage(source: ImageSource.gallery),
    ).thenAnswer((_) async => xFile);
    when(
      () => mockTextRecognitionService.processImage(xFile),
    ).thenThrow(Exception('Test Error'));

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bild aus Galerie'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Ein Fehler ist aufgetreten.'), findsOneWidget);
  });
}
