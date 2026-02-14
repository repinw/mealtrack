import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/features/calories/data/nutrition_ocr_repository.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAiService extends Mock implements FirebaseAiService {}

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late NutritionOcrRepository repository;
  late MockFirebaseAiService mockAiService;
  late MockImagePicker mockImagePicker;

  setUp(() {
    mockAiService = MockFirebaseAiService();
    mockImagePicker = MockImagePicker();
    repository = NutritionOcrRepository(
      firebaseAiService: mockAiService,
      imagePicker: mockImagePicker,
    );

    registerFallbackValue(XFile(''));
  });

  group('NutritionOcrRepository', () {
    const validJson = '''
      {
        "n": "Skyr",
        "b": "Arla",
        "kcal": 63,
        "protein": 11,
        "carbs": 3.8,
        "fat": 0.2
      }
    ''';

    test('analyzeNutritionLabel parses service response', () async {
      final file = XFile('/tmp/nutrition.jpg');

      when(
        () => mockAiService.analyzeNutritionLabelImageWithGemini(file),
      ).thenAnswer((_) async => validJson);

      final parsed = await repository.analyzeNutritionLabel(file);

      expect(parsed.productName, 'Skyr');
      expect(parsed.brand, 'Arla');
      expect(parsed.per100.kcal, 63);
      expect(parsed.per100.protein, 11);
      expect(parsed.per100.carbs, 3.8);
      expect(parsed.per100.fat, 0.2);
      verify(
        () => mockAiService.analyzeNutritionLabelImageWithGemini(file),
      ).called(1);
    });

    test('analyzeNutritionLabel rethrows service errors', () async {
      final file = XFile('/tmp/nutrition.jpg');
      when(
        () => mockAiService.analyzeNutritionLabelImageWithGemini(file),
      ).thenThrow(Exception('AI failure'));

      expect(
        () => repository.analyzeNutritionLabel(file),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'analyzeNutritionLabelFromCamera returns null when canceled',
      () async {
        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1500,
            imageQuality: 80,
          ),
        ).thenAnswer((_) async => null);

        final result = await repository.analyzeNutritionLabelFromCamera();

        expect(result, isNull);
        verify(
          () => mockImagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1500,
            imageQuality: 80,
          ),
        ).called(1);
        verifyNever(
          () => mockAiService.analyzeNutritionLabelImageWithGemini(any()),
        );
      },
    );

    test('analyzeNutritionLabelFromCamera picks image and parses it', () async {
      final file = XFile('/tmp/nutrition.jpg');

      when(
        () => mockImagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1500,
          imageQuality: 80,
        ),
      ).thenAnswer((_) async => file);

      when(
        () => mockAiService.analyzeNutritionLabelImageWithGemini(file),
      ).thenAnswer((_) async => validJson);

      final result = await repository.analyzeNutritionLabelFromCamera();

      expect(result, isNotNull);
      expect(result!.per100.kcal, 63);
      verify(
        () => mockImagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1500,
          imageQuality: 80,
        ),
      ).called(1);
      verify(
        () => mockAiService.analyzeNutritionLabelImageWithGemini(file),
      ).called(1);
    });
  });
}
