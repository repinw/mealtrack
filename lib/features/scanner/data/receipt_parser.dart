import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:uuid/uuid.dart';

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

    var receiptId = const Uuid().v4();
    if (decodedJson is Map<String, dynamic>) {
      if (decodedJson.containsKey('i')) {
        itemsList = decodedJson['i'] as List<dynamic>;
      } else if (decodedJson.containsKey('items')) {
        itemsList =
            decodedJson['items'] as List<dynamic>;
      } else {
        itemsList = [];
      }
    } else if (decodedJson is List) {
      itemsList = decodedJson;
    } else {
      debugPrint('${AppLocalizations.unexpectedJsonFormat}$decodedJson');
      return [];
    }

    return itemsList.map((itemJson) {
      final map = itemJson as Map<String, dynamic>;

      final discountsList = (map['d'] ?? map['discounts']) as List<dynamic>?;
      final discounts = <String, double>{};

      if (discountsList != null) {
        for (final discountItem in discountsList) {
          if (discountItem is Map<String, dynamic>) {
            // n = name, a = amount
            final name = (discountItem['n'] ?? discountItem['name']) as String?;
            final amount =
                ((discountItem['a'] ?? discountItem['amount']) as num?)
                    ?.toDouble();

            if (name != null && amount != null) {
              discounts[name] = amount;
            }
          }
        }
      }

      // --- ÄNDERUNG 3: Item-Fields (n, s, q, p...) ---

      // n = name
      final name = (map['n'] ?? map['name']) as String? ?? '';

      // s = storeName
      final store = (map['s'] ?? map['storeName']) as String? ?? '';

      // q = quantity
      final qty = ((map['q'] ?? map['quantity']) as num?)?.toInt() ?? 1;
      final quantity = qty > 0 ? qty : 1;

      // p = totalPrice
      final totalPrice =
          ((map['p'] ?? map['totalPrice']) as num?)?.toDouble() ?? 0.0;

      final unitPrice = quantity > 0 ? totalPrice / quantity : 0.0;

      // w = weight, b = brand
      final weight = (map['w'] ?? map['weight']) as String?;
      final brand = (map['b'] ?? map['brand']) as String?;

      return FridgeItem.create(
        name: name.isEmpty ? AppLocalizations.jsonParsingError : name,
        storeName: store.isEmpty ? AppLocalizations.jsonParsingError : store,
        quantity: quantity,
        unitPrice: unitPrice,
        weight: weight,
        brand: brand,
        discounts: discounts,
        receiptId: receiptId,
      );
    }).toList();
  } catch (e, stackTrace) {
    debugPrint('Error parsing JSON: $e');
    debugPrintStack(stackTrace: stackTrace);
    throw FormatException('${AppLocalizations.jsonParsingError}$e');
  }
}
