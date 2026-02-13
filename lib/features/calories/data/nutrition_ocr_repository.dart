import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/features/calories/data/nutrition_ocr_parser.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';

final nutritionOcrRepository = Provider<NutritionOcrRepository>((ref) {
  return NutritionOcrRepository(
    firebaseAiService: ref.watch(firebaseAiServiceProvider),
    imagePicker: ref.watch(imagePickerProvider),
  );
});

class NutritionOcrRepository {
  final FirebaseAiService _firebaseAiService;
  final ImagePicker _imagePicker;

  const NutritionOcrRepository({
    required FirebaseAiService firebaseAiService,
    required ImagePicker imagePicker,
  }) : _firebaseAiService = firebaseAiService,
       _imagePicker = imagePicker;

  Future<NutritionOcrParseResult?> analyzeNutritionLabelFromCamera() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1500,
      imageQuality: 80,
    );

    if (image == null) return null;
    return analyzeNutritionLabel(image);
  }

  Future<NutritionOcrParseResult> analyzeNutritionLabel(XFile imageFile) async {
    try {
      debugPrint('NutritionOCR: Starting analysis for ${imageFile.path}');
      final response = await _firebaseAiService
          .analyzeNutritionLabelImageWithGemini(imageFile);
      final parsed = parseNutritionOcrResult(response);
      debugPrint(
        'NutritionOCR: Parsed values (kcal=${parsed.per100.kcal}, sugar=${parsed.per100.sugar}, protein=${parsed.per100.protein}, carbs=${parsed.per100.carbs}, fat=${parsed.per100.fat})',
      );
      return parsed;
    } catch (e) {
      debugPrint('NutritionOCR: Analysis failed: $e');
      rethrow;
    }
  }
}
