import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';

List<ScannedItem> parseScannedItemsFromJson(String jsonString) {
  if (jsonString.trim().isEmpty) {
    throw const FormatException('Leerer JSON-String empfangen.');
  }

  // Delete Gemini Json packaging if present
  final sanitizedJson = jsonString
      .replaceAll('```json', '')
      .replaceAll('```', '')
      .trim();

  if (sanitizedJson.isEmpty) {
    throw const FormatException('Bereinigter JSON-String ist leer.');
  }

  try {
    final decodedJson = jsonDecode(sanitizedJson);

    List<dynamic> itemsList;

    if (decodedJson is Map<String, dynamic> &&
        decodedJson.containsKey('items')) {
      itemsList = decodedJson['items'] as List<dynamic>;
    } else if (decodedJson is List) {
      itemsList = decodedJson;
    } else {
      debugPrint('Unerwartetes JSON-Format empfangen: $decodedJson');
      return [];
    }

    return itemsList
        .map(
          (itemJson) => ScannedItem.fromJson(itemJson as Map<String, dynamic>),
        )
        .toList();
  } catch (e, stackTrace) {
    debugPrint('Fehler beim Parsen des JSON: $e');
    debugPrintStack(stackTrace: stackTrace);
    throw FormatException('Fehler beim Parsen des JSON: $e');
  }
}
