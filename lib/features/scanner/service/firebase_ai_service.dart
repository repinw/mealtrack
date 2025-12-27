import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/features/scanner/service/image_compressor.dart';

class FirebaseAiService {
  static const String _fallbackTemplateId = 'receiptocr';

  final FirebaseRemoteConfig remoteConfig;
  final ImageCompressor imageCompressor;

  FirebaseAiService({
    FirebaseRemoteConfig? remoteConfig,
    ImageCompressor? imageCompressor,
  }) : remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance,
       imageCompressor = imageCompressor ?? DefaultImageCompressor();

  Future<void> initialize() async {
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 3600),
        minimumFetchInterval: kDebugMode
            ? const Duration(seconds: 0)
            : const Duration(seconds: 3600),
      ),
    );
    await remoteConfig.setDefaults(const {"template_id": _fallbackTemplateId});
    await remoteConfig.fetchAndActivate();

    remoteConfig.onConfigUpdated.listen((event) async {
      await remoteConfig.activate();
    });
  }

  Future<String> analyzeImageWithGemini(XFile imageFile) async {
    debugPrint(AppLocalizations.imageUploading);
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
    return _analyzeContent(base64Data, 'image/jpeg');
  }

  Future<String> analyzePdfWithGemini(XFile pdfFile) async {
    debugPrint("Processing PDF...");
    final bytes = await pdfFile.readAsBytes();
    debugPrint("PDF Size: ${bytes.length} Bytes");

    final base64Data = base64Encode(bytes);
    return _analyzeContent(base64Data, 'application/pdf');
  }

  Future<String> _analyzeContent(String base64Data, String mimeType) async {
    String templateID = remoteConfig.getString("template_id");
    if (templateID.isEmpty) {
      debugPrint(
        "Remote Config 'template_id' is empty. Using fallback: $_fallbackTemplateId",
      );
      templateID = _fallbackTemplateId;
    }
    try {
      final model = FirebaseAI.vertexAI(
        location: 'global',
      ).templateGenerativeModel();

      final inputs = {'mimeType': mimeType, 'imageData': base64Data};
      final response = await model.generateContent(templateID, inputs: inputs);

      final extractedText = response.text;
      if (extractedText == null || extractedText.isEmpty) {
        throw ReceiptAnalysisException(
          'No text received from AI service',
          code: 'NO_TEXT',
        );
      }

      debugPrint("${AppLocalizations.aiResult}$extractedText", wrapWidth: 1024);
      return extractedText;
    } catch (e) {
      if (e is ReceiptAnalysisException) rethrow;
      debugPrint("${AppLocalizations.aiRequestError}$e");
      throw ReceiptAnalysisException(
        'AI Request Failed',
        originalException: e,
        code: 'AI_ERROR',
      );
    }
  }
}
