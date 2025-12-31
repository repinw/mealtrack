import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
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
    String? rootStoreName;
    DateTime? rootReceiptDate;
    String? rootLanguage;

    var receiptId = const Uuid().v4();
    if (decodedJson is Map<String, dynamic>) {
      rootStoreName = (decodedJson['s']) as String?;

      final receiptDateStr = (decodedJson['rd']) as String?;
      if (receiptDateStr != null) {
        rootReceiptDate = DateTime.tryParse(receiptDateStr);
      }

      rootReceiptDate ??= DateTime.now();

      rootLanguage = (decodedJson['l']) as String?;
      rootLanguage ??= 'de_DE';

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

      final discountsList = (map['d']) as List<dynamic>?;
      final discounts = <String, double>{};

      if (discountsList != null) {
        for (final discountItem in discountsList) {
          if (discountItem is Map<String, dynamic>) {
            final name = (discountItem['n']) as String?;
            final amount = _getParsedNum(
              discountItem['a'],
              rootLanguage,
            )?.toDouble();

            if (name != null && amount != null) {
              discounts[name] = amount;
            }
          }
        }
      }

      final name = (map['n']) as String? ?? '';

      final itemStore = (map['s']) as String?;
      final store = (itemStore?.isNotEmpty == true)
          ? itemStore!
          : (rootStoreName ?? '');

      final rawQty = _getParsedNum(map['q'], rootLanguage);
      final qty = rawQty?.toInt() ?? 1;
      final quantity = qty > 0 ? qty : 1;

      final rawPrice = _getParsedNum(map['p'], rootLanguage);
      final totalPrice = (rawPrice?.toDouble() ?? 0.0).abs();

      final unitPrice = quantity > 0 ? totalPrice / quantity : 0.0;

      final weight = (map['w']) as String?;
      final brand = (map['b']) as String?;

      return FridgeItem.create(
        name: name.isEmpty ? AppLocalizations.jsonParsingError : name,
        storeName: store.isEmpty ? AppLocalizations.jsonParsingError : store,
        quantity: quantity,
        unitPrice: unitPrice,
        weight: weight,
        brand: brand,
        discounts: discounts,
        receiptId: receiptId,
        receiptDate: rootReceiptDate,
        language: rootLanguage,
      );
    }).toList();
  } catch (e, stackTrace) {
    debugPrint('Error parsing JSON: $e');
    debugPrintStack(stackTrace: stackTrace);
    throw FormatException('${AppLocalizations.jsonParsingError}$e');
  }
}

num? _getParsedNum(dynamic value, String? languageCode) {
  if (value is num) return value;
  if (value is String) {
    final dotParsed = double.tryParse(value);
    if (dotParsed != null) return dotParsed;

    final commaToDot = double.tryParse(value.replaceAll(',', '.'));
    if (commaToDot != null) return commaToDot;

    try {
      return NumberFormat.decimalPattern(languageCode).parse(value).toDouble();
    } catch (_) {
      return null;
    }
  }
  return null;
}
