import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// A service that uses Firebase Vertex AI with Gemini to analyze receipt images.
class FirebaseAiService {
  // Using a fast and cost-efficient model suitable for this task.
  static const _modelName = 'gemini-2.5-flash';

  static const _prompt =
      "Analysiere den Kassenbon und extrahiere strukturierte Daten."
      "Regeln für die Ausgabe: Gib das Ergebnis ausschließlich als rohes JSON-Objekt zurück. Kein Markdown, kein erklärender Text. Das JSON muss einen Schlüssel 'items' enthalten, der eine Liste von Objekten ist."
      "Regeln für die Artikel-Erkennung (WICHTIG):"
      "    Ein Eintrag im Array 'items' darf nur erstellt werden, wenn es sich um ein physisches Produkt mit einem positiven Preis handelt."
      "   Zeilen mit negativen Preisen (z.B. -1,20) oder Zeilen, die Worte wie 'Rabatt' oder 'Gutschein' im Namen enthalten, sind KEINE Artikel. Erstelle dafür kein eigenes Item-Objekt!"
      "   Stattdessen müssen diese Zeilen als Rabatt-Objekt in das Feld discounts des unmittelbar vorangegangenen Artikels eingefügt werden."
      "Struktur eines Artikel-Objekts:"
      "   name: Vollständiger Name des Artikels (String). Rate den vollen Namen. Entferne Gewichtsangaben und Hersteller aus dem Namen."
      "   brand: Marke oder Hersteller (String). Rate, falls nicht explizit genannt."
      "  quantity: Menge (Integer). Standard: 1. Wenn '2 x' davor steht, ist es 2."
      " totalPrice: Der Preis auf der rechten Seite (Float). Muss positiv sein."
      " weight: Extrahiere Gewichte/Volumen (z.B. '500g', '1L', 'ST') aus dem Text und speichere sie hier, nicht im Namen."
      "discounts: Eine Liste von Objekten. Jedes Objekt hat name (Beschreibung des Rabatts) und amount (der absolute Betrag als positive Zahl, z.B. 1.20)."
      "storeName: Name des Ladens (z.B. Netto). Wiederhole für jedes Item.,"
      "isLowConfidence: Boolean. Setze auf true, wenn du dir bei der Erkennung unsicher bist (z.B. unleserlich), sonst false."
      "Beispiel-Logik: Wenn Zeile A 'Hackfleisch 7,99' ist und Zeile B 'Rabatt -1,20' ist: Erstelle EIN Item für Hackfleisch. Füge den Rabatt von 1.20 in dessen discounts-Liste ein. Erstelle KEIN Item für Zeile B.";

  final GenerativeModel? _model;

  FirebaseAiService({GenerativeModel? model}) : _model = model;

  /// Analyzes the given image [imageData] with the Gemini model.
  ///
  /// Throws an exception if the analysis fails or returns no text.
  Future<String> analyzeImageWithGemini(XFile imageData) async {
    try {
      final model =
          _model ?? FirebaseAI.vertexAI().generativeModel(model: _modelName);

      debugPrint("Bild wird hochgeladen und analysiert...");

      final prompt = Content.multi([
        const TextPart(_prompt),
        InlineDataPart('image/jpeg', await imageData.readAsBytes()),
      ]);

      final response = await model.generateContent([prompt]);
      final extractedText = response.text;

      if (extractedText == null || extractedText.isEmpty) {
        throw Exception("Kein Text von der KI erhalten.");
      }

      debugPrint("KI Ergebnis: $extractedText", wrapWidth: 1024);
      return extractedText;
    } catch (e) {
      debugPrint("Fehler bei der KI-Anfrage: $e");
      // Rethrow the exception to be handled by the caller.
      rethrow;
    }
  }
}
