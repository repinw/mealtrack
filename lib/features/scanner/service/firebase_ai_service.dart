import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Das Paket brauchst du
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/scanner/data/receipt_parser.dart';

class FirebaseAiService {
  final remoteConfig = FirebaseRemoteConfig.instance;

  Future<List<FridgeItem>> analyzeImageWithGemini(XFile imageData) async {
    String templateID = remoteConfig.getString("template_id");
    if (templateID.isEmpty) templateID = "kassenbon-analyse-v1";

    try {
      // 1. WIR BLEIBEN BEIM TEMPLATE!
      final model = FirebaseAI.vertexAI(
        location: 'global',
      ).templateGenerativeModel();

      debugPrint(AppLocalizations.imageUploading);
      debugPrint("Starte Kompression...");

      // 2. Komprimierung & Umwandlung in JPEG
      // Egal ob PNG, HEIC oder WebP reinkommt -> es kommt ein kleines JPEG raus.
      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithFile(
            imageData.path,
            minWidth: 1024, // Breite begrenzen (spart MBs)
            minHeight: 1024,
            quality: 60, // Gute Balance
            format: CompressFormat.jpeg, // ZWANG: Wir machen ein JPEG draus!
          );

      if (compressedBytes == null) {
        throw Exception("Bildkompression fehlgeschlagen");
      }

      final base64Image = base64Encode(compressedBytes);

      debugPrint("Original: ${await imageData.length()} Bytes");
      debugPrint(
        "Optimiert: ${compressedBytes.length} Bytes (Sende als image/jpeg)",
      );

      // 3. Inputs für das Template
      // Wir nutzen die Split-Methode, die wir zuletzt besprochen hatten.
      // Da wir konvertiert haben, ist der MimeType jetzt IMMER 'image/jpeg'.
      final inputs = {'mimeType': 'image/jpeg', 'imageData': base64Image};

      // 4. Aufruf ans Template
      final response = await model.generateContent(templateID, inputs: inputs);

      final extractedText = response.text;
      if (extractedText == null || extractedText.isEmpty) {
        throw Exception(AppLocalizations.noTextFromAi);
      }

      debugPrint("${AppLocalizations.aiResult}$extractedText", wrapWidth: 1024);
      return parseScannedItemsFromJson(extractedText);
    } catch (e) {
      debugPrint("${AppLocalizations.aiRequestError}$e");
      rethrow;
    }
  }
}
