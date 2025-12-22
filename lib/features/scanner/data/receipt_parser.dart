import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mealtrack/core/models/fridge_item.dart';

List<FridgeItem> parseScannedItemsFromJson(String jsonString) {
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

    return itemsList.map((itemJson) {
      final map = itemJson as Map<String, dynamic>;

      final discountsList = map['discounts'] as List<dynamic>? ?? [];
      final discounts = <String, double>{};
      for (final d in discountsList) {
        if (d is Map<String, dynamic>) {
          final name = d['name'] as String? ?? 'Rabatt';
          final amount = (d['amount'] as num?)?.toDouble() ?? 0.0;
          if (amount > 0) {
            discounts[name] = amount;
          }
        }
      }

      final name = map['name'] as String? ?? '';
      final store = map['storeName'] as String? ?? '';
      final qty = (map['quantity'] as num?)?.toInt() ?? 1;

      return FridgeItem.create(
        rawText: name.isEmpty ? 'Unbekannter Artikel' : name,
        storeName: store.isEmpty ? 'Unbekannter Laden' : store,
        quantity: qty > 0 ? qty : 1,
        unitPrice:
            (map['totalPrice'] as num?)?.toDouble() ??
            (map['unitPrice'] as num?)?.toDouble(),
        weight: map['weight'] as String?,
        brand: map['brand'] as String?,
        discounts: discounts,
      );
    }).toList();
  } catch (e, stackTrace) {
    debugPrint('Fehler beim Parsen des JSON: $e');
    debugPrintStack(stackTrace: stackTrace);
    throw FormatException('Fehler beim Parsen des JSON: $e');
  }
}
