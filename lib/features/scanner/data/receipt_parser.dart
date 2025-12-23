import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/models/fridge_item.dart';

List<FridgeItem> parseScannedItemsFromJson(String jsonString) {
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

    return itemsList.map((itemJson) {
      final map = itemJson as Map<String, dynamic>;

      final discountsList = map['discounts'] as List<dynamic>?;
      final discounts = <String, double>{};
      if (discountsList != null) {
        for (final d in discountsList) {
          if (d is Map<String, dynamic>) {
            final name = d['name'] as String?;
            final amount = (d['amount'] as num?)?.toDouble();
            if (name != null && amount != null) {
              discounts[name] = amount;
            }
          }
        }
      }

      final name = map['name'] as String? ?? '';
      final store = map['storeName'] as String? ?? '';
      final qty = (map['quantity'] as num?)?.toInt() ?? 1;
      final quantity = qty > 0 ? qty : 1;
      final totalPrice = (map['totalPrice'] as num?)?.toDouble() ?? 0.0;
      final unitPrice = quantity > 0 ? totalPrice / quantity : 0.0;

      return FridgeItem.create(
        name: name.isEmpty ? 'Unbekannter Artikel' : name,
        storeName: store.isEmpty ? 'Unbekannter Laden' : store,
        quantity: quantity,
        unitPrice: unitPrice,
        weight: map['weight'] as String?,
        brand: map['brand'] as String?,
        discounts: discounts,
        receiptId: map['receiptId'] as String?,
      );
    }).toList();
  } catch (e, stackTrace) {
    debugPrint('Fehler beim Parsen des JSON: $e');
    debugPrintStack(stackTrace: stackTrace);
    throw FormatException('${AppLocalizations.jsonParsingError}$e');
  }
}
