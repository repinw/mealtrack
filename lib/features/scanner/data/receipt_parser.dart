import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mealtrack/core/errors/exceptions.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:uuid/uuid.dart';

// Mappings for the minified JSON keys used in the LLM prompt to save tokens:
// n = name
// s = storeName
// q = quantity
// p = totalPrice
// w = weight
// b = brand
// d = discounts
// a = amount (in discount)

List<FridgeItem> parseScannedItemsFromJson(String jsonString) {
  if (jsonString.trim().isEmpty) {
    throw const FormatException(AppLocalizations.emptyJsonString);
  }

  final pattern = RegExp(r'```(?:json)?\s*(.*?)\s*```', dotAll: true);
  final match = pattern.firstMatch(jsonString);
  final sanitizedJson = match != null
      ? match.group(1)!.trim()
      : jsonString.trim();

  if (sanitizedJson.isEmpty) {
    throw const FormatException(AppLocalizations.sanitizedJsonEmpty);
  }

  dynamic decodedJson;
  try {
    decodedJson = jsonDecode(sanitizedJson);
  } catch (e) {
    throw ReceiptAnalysisException(
      '${AppLocalizations.jsonParsingError}$e',
      code: 'INVALID_JSON',
      originalException: e,
    );
  }

  try {
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
      final totalPrice = (rawPrice?.toDouble() ?? 0.0).abs();

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
    if (value.trim().isEmpty) return null;
    try {
      String s = value.trim();
      // Handle typical formats:
      // If valid standard number (e.g. 12.34), helper methods handle it.
      // But we need to handle locale-specific formats.

      // Check for mixed separators to guess locale
      if (s.contains(',') && s.contains('.')) {
        final lastComma = s.lastIndexOf(',');
        final lastDot = s.lastIndexOf('.');
        if (lastComma > lastDot) {
          // German/EU format: 1.234,56 -> remove dots, replace comma with dot
          s = s.replaceAll('.', '').replaceAll(',', '.');
        } else {
          // US/UK format: 1,234.56 -> remove commas
          s = s.replaceAll(',', '');
        }
      } else if (s.contains(',')) {
        // Only comma: 2,50 -> 2.50
        // Or 1,200 (could be 1200 or 1.2). Assume decimal separator if < 3 decimals or > 3?
        // Safer strict rule: If comma is present, and NO dots, replace with dot for parsing.
        s = s.replaceAll(',', '.');
      }
      // Cleanup spaces
      s = s.replaceAll(RegExp(r'\s+'), '');
      return num.tryParse(s);
    } catch (e) {
      return null;
    }
  }
  return null;
}
