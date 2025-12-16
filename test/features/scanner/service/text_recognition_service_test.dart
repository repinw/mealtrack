import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:mealtrack/features/scanner/service/text_recognition_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAiService extends Mock implements FirebaseAiService {}

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late TextRecognitionService service;
  late MockFirebaseAiService mockAiService;
  late MockImagePicker mockPicker;
  late List<ScannedItem> mockParserResult;

  setUp(() {
    mockAiService = MockFirebaseAiService();
    mockPicker = MockImagePicker();
    mockParserResult = [];
    service = TextRecognitionService(
      firebaseAiService: mockAiService,
      picker: mockPicker,
      parser: (_) => mockParserResult,
    );
  });

  group('TextRecognitionService', () {
    test('processImage returns empty list when no image is provided', () async {
      final result = await service.processImage(null);

      expect(result, isEmpty);
      verifyZeroInteractions(mockAiService);
    });

    test(
      'processImage returns scanned items when image is analyzed successfully',
      () async {
        final mockFile = XFile('test_image.jpg');
        final expectedItems = [
          const ScannedItem(name: 'Apple', totalPrice: 1.50, quantity: 1),
          const ScannedItem(name: 'Banana', totalPrice: 0.80, quantity: 2),
        ];

        mockParserResult = expectedItems;

        when(
          () => mockAiService.analyzeImageWithGemini(mockFile),
        ).thenAnswer((_) async => 'dummy_json');

        final result = await service.processImage(mockFile);

        expect(result, expectedItems);
        verify(() => mockAiService.analyzeImageWithGemini(mockFile)).called(1);
      },
    );
  });
}
