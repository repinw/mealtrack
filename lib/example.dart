import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseAiService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> analyzeImageWithGemini() async {
    try {
      // 1. Modell initialisieren
      // 'gemini-1.5-flash' ist schnell und kostengünstig für solche Aufgaben
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-2.5-flash-lite',
      );

      // 2. Bild auswählen
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      print("Bild wird hochgeladen und analysiert...");

      // 3. Bilddaten laden
      final imageBytes = await image.readAsBytes();

      // 4. Der Prompt (Der Befehl an die KI)
      // Wir bitten die KI, nur den Text zurückzugeben.
      final prompt = Content.multi([
        TextPart(
          "Entferne das Gewicht aus dem Namen. Rabatt steht jeweils unter dem Artikel und es können mehrere Rabatte vorkommen. Gibt mir eine Json-Datei zurück, keine Einleitungen. Für alle Artikel die du findest. Ignoriere keinen Abschnitt. Bei Eiern wird Stückzahl im Namen hinterlegt. Zum beispiel: 10STR"
          "Erstelle mir ein jeweils ein Objekt für die Artikel. Es besteht aus Anzahl, Namen, Gewicht, Preis, Rabatt passenden Rabatt.",
        ),
        InlineDataPart('image/jpeg', imageBytes), // Bild anhängen
      ]);

      // 5. Anfrage an Firebase Vertex AI senden
      final GenerateContentResponse response = await model.generateContent([
        prompt,
      ]);

      final String? extractedText = response.text;

      if (extractedText == null || extractedText.isEmpty) {
        print("Kein Text von der KI erhalten.");
        return;
      }

      debugPrint("KI Ergebnis: $extractedText", wrapWidth: 1024);

      // 7. In Firestore speichern

      print("Erfolgreich via Vertex AI gespeichert!");
    } catch (e) {
      print("Fehler bei der KI-Anfrage: $e");
    }
  }
}
