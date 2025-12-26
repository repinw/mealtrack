import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:uuid/uuid.dart';

List<FridgeItem> parseScannedItemsFromJson(String jsonString) {
  if (jsonString.trim().isEmpty) {
    throw const FormatException(AppLocalizations.emptyJsonString);
  }

  // Delete Gemini Json packaging if present using Regex
  final pattern = RegExp(r'```(?:json)?\s*(.*?)\s*```', dotAll: true);
  final match = pattern.firstMatch(jsonString);
  final sanitizedJson = match != null
      ? match.group(1)!.trim()
      : jsonString.trim();

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
        itemsList = decodedJson['items'] as List<dynamic>;
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
            final amount = _parseNum(
              discountItem['a'] ?? discountItem['amount'],
            )?.toDouble();

            if (name != null && amount != null) {
              discounts[name] = amount;
            }
          }
        }
      }

      // Item-Fields (n, s, q, p...) ---

      // n = name
      final name = (map['n'] ?? map['name']) as String? ?? '';

      // s = storeName
      final store = (map['s'] ?? map['storeName']) as String? ?? '';

      // q = quantity
      final rawQty = _parseNum(map['q'] ?? map['quantity']);
      final qty = rawQty?.toInt() ?? 1;
      final quantity = qty > 0 ? qty : 1;

      // p = totalPrice
      final rawPrice = _parseNum(map['p'] ?? map['totalPrice']);
      final totalPrice = rawPrice?.toDouble() ?? 0.0;

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

num? _parseNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) {
    // Replace comma with dot for German number formats
    final sanitized = value.replaceAll(',', '.');
    return num.tryParse(sanitized);
  }
  return null;
}
