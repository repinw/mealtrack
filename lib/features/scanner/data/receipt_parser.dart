import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';

List<ScannedItem> parseScannedItemsFromJson(String jsonString) {
  if (jsonString.trim().isEmpty) {
    throw const FormatException(AppLocalizations.emptyJsonString);
  }

  // Delete Gemini Json packaging if present
  final sanitizedJson = jsonString
      .replaceAll('```json', '')
      .replaceAll('```', '')
      .trim();

  if (sanitizedJson.isEmpty) {
    throw const FormatException(AppLocalizations.sanitizedJsonEmpty);
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
      debugPrint('${AppLocalizations.unexpectedJsonFormat}$decodedJson');
      return [];
    }

    return itemsList
        .map(
          (itemJson) => ScannedItem.fromJson(itemJson as Map<String, dynamic>),
        )
        .toList();
  } catch (e, stackTrace) {
    // Fangt Parsing-Fehler ab, loggt sie und gebt eine leere Liste zurück.
    debugPrint('${AppLocalizations.jsonParsingError}$e');
    debugPrintStack(stackTrace: stackTrace);
    throw FormatException('${AppLocalizations.jsonParsingError}$e');
  }
}
