import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mealtrack/features/scanner/service/image_compressor.dart';

class FirebaseAiService {
  static const String _receiptTemplateKey = 'template_id';
  static const String _nutritionTemplateKey = 'nutrition-template-id';
  static const String _legacyNutritionTemplateKey = 'nutrition_template_id';
  static const String _fallbackReceiptTemplateId = 'receiptocr';
  static const String _fallbackNutritionTemplateId = 'nutrition-template-id';

  final FirebaseRemoteConfig remoteConfig;
  final ImageCompressor imageCompressor;
  final dynamic Function()? modelProvider;

  FirebaseAiService({
    FirebaseRemoteConfig? remoteConfig,
    ImageCompressor? imageCompressor,
    this.modelProvider,
  }) : remoteConfig =
           remoteConfig ??
           FirebaseRemoteConfig.instance, // coverage:ignore-line
       imageCompressor =
           imageCompressor ?? ImageCompressor(); // coverage:ignore-line

  Future<void> initialize() async {
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: kDebugMode
            ? const Duration(seconds: 0)
            : const Duration(seconds: 3600),
      ),
    );
    await remoteConfig.setDefaults(const {
      _receiptTemplateKey: _fallbackReceiptTemplateId,
      _nutritionTemplateKey: _fallbackNutritionTemplateId,
      _legacyNutritionTemplateKey: _fallbackNutritionTemplateId,
    });
    await remoteConfig.fetchAndActivate();

    remoteConfig.onConfigUpdated.listen((event) async {
      await remoteConfig.activate();
    });
  }

  Future<String> analyzeImageWithGemini(XFile imageFile) async {
    debugPrint('Image uploading and analyzing...');
    debugPrint("Starting compression...");

    final Uint8List? compressedBytes = await imageCompressor.compressWithFile(
      imageFile.path,
      minWidth: 1024,
      minHeight: 1024,
      quality: 80,
      format: CompressFormat.jpeg,
    );

    if (compressedBytes == null) {
      throw ReceiptAnalysisException(
        "Image compression failed",
        code: 'COMPRESSION_ERROR',
      );
    }

    debugPrint("Original: ${await imageFile.length()} Bytes");
    debugPrint(
      "Optimized: ${compressedBytes.length} Bytes (Sending as image/jpeg)",
    );

    final base64Data = base64Encode(compressedBytes);
    return _analyzeContent(
      base64Data,
      'image/jpeg',
      templateKey: _receiptTemplateKey,
      fallbackTemplateId: _fallbackReceiptTemplateId,
    );
  }

  Future<String> analyzeNutritionLabelImageWithGemini(XFile imageFile) async {
    debugPrint('Nutrition label uploading and analyzing...');
    debugPrint("Starting compression...");

    final Uint8List? compressedBytes = await imageCompressor.compressWithFile(
      imageFile.path,
      minWidth: 1024,
      minHeight: 1024,
      quality: 80,
      format: CompressFormat.jpeg,
    );

    if (compressedBytes == null) {
      throw ReceiptAnalysisException(
        "Image compression failed",
        code: 'COMPRESSION_ERROR',
      );
    }

    debugPrint("Original: ${await imageFile.length()} Bytes");
    debugPrint(
      "Optimized: ${compressedBytes.length} Bytes (Sending as image/jpeg)",
    );

    final base64Data = base64Encode(compressedBytes);
    return _analyzeContent(
      base64Data,
      'image/jpeg',
      templateKey: _nutritionTemplateKey,
      secondaryTemplateKey: _legacyNutritionTemplateKey,
      fallbackTemplateId: _fallbackNutritionTemplateId,
    );
  }

  Future<String> analyzePdfWithGemini(XFile pdfFile) async {
    debugPrint("Processing PDF...");
    final bytes = await pdfFile.readAsBytes();
    debugPrint("PDF Size: ${bytes.length} Bytes");

    final base64Data = base64Encode(bytes);
    return _analyzeContent(
      base64Data,
      'application/pdf',
      templateKey: _receiptTemplateKey,
      fallbackTemplateId: _fallbackReceiptTemplateId,
    );
  }

  Future<String> _analyzeContent(
    String base64Data,
    String mimeType, {
    required String templateKey,
    String? secondaryTemplateKey,
    required String fallbackTemplateId,
  }) async {
    String templateID = remoteConfig.getString(templateKey);
    if (templateID.isEmpty && secondaryTemplateKey != null) {
      templateID = remoteConfig.getString(secondaryTemplateKey);
    }
    if (templateID.isEmpty) {
      debugPrint(
        "Remote Config '$templateKey' is empty. Using fallback: $fallbackTemplateId",
      );
      templateID = fallbackTemplateId;
    }
    try {
      // coverage:ignore-start
      final model = modelProvider != null
          ? modelProvider!()
          : FirebaseAI.vertexAI(location: 'global').templateGenerativeModel();
      // coverage:ignore-end

      final inputs = {'mimeType': mimeType, 'imageData': base64Data};
      final response = await model.generateContent(templateID, inputs: inputs);

      final extractedText = response.text;
      if (extractedText == null || extractedText.isEmpty) {
        throw ReceiptAnalysisException(
          'No text received from AI service',
          code: 'NO_TEXT',
        );
      }

      if (kDebugMode) {
        debugPrint("AI Result: $extractedText", wrapWidth: 1024);
      }
      return extractedText;
    } catch (e) {
      if (e is ReceiptAnalysisException) rethrow;
      debugPrint("AI Request Error: $e");
      throw ReceiptAnalysisException(
        'AI Request Failed',
        originalException: e,
        code: 'AI_ERROR',
      );
    }
  }
}
