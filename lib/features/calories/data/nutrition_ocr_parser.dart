import 'dart:convert';

import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';

class NutritionOcrParseException implements Exception {
  final String message;
  final String? code;
  final Object? originalException;

  const NutritionOcrParseException(
    this.message, {
    this.code,
    this.originalException,
  });

  @override
  String toString() {
    return 'NutritionOcrParseException: $message'
        '${code == null ? '' : ' (Code: $code)'}';
  }
}

class NutritionOcrParseResult {
  final String? productName;
  final String? brand;
  final String? quantityLabel;
  final String? servingSizeLabel;
  final NutritionPer100 per100;
  final bool hasKcal;
  final bool hasSugar;
  final bool hasProtein;
  final bool hasCarbs;
  final bool hasFat;
  final bool hasSalt;
  final bool hasSaturatedFat;
  final bool hasPolyunsaturatedFat;
  final bool hasFiber;

  const NutritionOcrParseResult({
    required this.per100,
    required this.hasKcal,
    required this.hasSugar,
    required this.hasProtein,
    required this.hasCarbs,
    required this.hasFat,
    required this.hasSalt,
    required this.hasSaturatedFat,
    required this.hasPolyunsaturatedFat,
    required this.hasFiber,
    this.productName,
    this.brand,
    this.quantityLabel,
    this.servingSizeLabel,
  });

  bool get hasAnyNutrition =>
      hasKcal ||
      hasSugar ||
      hasProtein ||
      hasCarbs ||
      hasFat ||
      hasSalt ||
      hasSaturatedFat ||
      hasPolyunsaturatedFat ||
      hasFiber;

  bool get hasCompleteCoreNutrition =>
      hasKcal && hasSugar && hasProtein && hasCarbs && hasFat && hasSalt;
}

NutritionOcrParseResult parseNutritionOcrResult(String rawResponse) {
  if (rawResponse.trim().isEmpty) {
    throw const NutritionOcrParseException(
      'Empty OCR response',
      code: 'EMPTY_RESPONSE',
    );
  }

  final sanitized = _extractJsonPayload(rawResponse);
  if (sanitized.isEmpty) {
    throw const NutritionOcrParseException(
      'Sanitized OCR response is empty',
      code: 'SANITIZED_EMPTY',
    );
  }

  final decoded = _decodeJson(sanitized);
  final rootMap = _coerceRootMap(decoded);

  if (rootMap == null) {
    throw const NutritionOcrParseException(
      'Unexpected OCR response format',
      code: 'UNEXPECTED_FORMAT',
    );
  }

  final normalizedKeyValue = <String, dynamic>{};
  _indexMap(rootMap, normalizedKeyValue);

  final productName = _readString(normalizedKeyValue, const [
    'n',
    'name',
    'product_name',
    'productName',
    'product',
    'title',
  ]);
  final brand = _readString(normalizedKeyValue, const [
    'b',
    'brand',
    'brands',
    'brand_name',
    'manufacturer',
  ]);
  final quantityLabel = _readString(normalizedKeyValue, const [
    'q',
    'quantity',
    'pack_size',
    'net_weight',
    'net_content',
  ]);
  final servingSizeLabel = _readString(normalizedKeyValue, const [
    'ss',
    'serving_size',
    'servingsize',
    'portion_size',
    'portion',
  ]);

  final kcalValue = _readDouble(normalizedKeyValue, const [
    'kcal',
    'calories',
    'energy_kcal',
    'energykcal',
    'energy_kcal_100g',
    'energykcal100g',
    'energy_kcal_per_100g',
  ]);
  final energyKjValue = _readDouble(normalizedKeyValue, const [
    'energy_kj',
    'energykj',
    'energy_kj_100g',
    'energykj100g',
    'energy_kj_per_100g',
  ]);

  final proteinValue = _readDouble(normalizedKeyValue, const [
    'protein',
    'proteins',
    'proteins_100g',
    'protein_100g',
    'protein_per_100g',
  ]);
  final carbsValue = _readDouble(normalizedKeyValue, const [
    'carbs',
    'carbohydrates',
    'carbohydrate',
    'carbohydrates_100g',
    'carbs_100g',
    'carbs_per_100g',
  ]);
  final fatValue = _readDouble(normalizedKeyValue, const [
    'fat',
    'fats',
    'fat_100g',
    'fats_100g',
    'fat_per_100g',
  ]);
  final sugarValue = _readDouble(normalizedKeyValue, const [
    'sugar',
    'sugars',
    'sugar_100g',
    'sugars_100g',
    'sugar_per_100g',
  ]);
  final saltValue = _readDouble(normalizedKeyValue, const [
    'salt',
    'salt_100g',
    'salt_per_100g',
  ]);
  final saturatedFatValue = _readDouble(normalizedKeyValue, const [
    'saturated_fat',
    'saturatedfat',
    'saturated_fat_100g',
    'saturatedfat100g',
    'saturated_fat_per_100g',
    'saturated-fat_100g',
  ]);
  final polyunsaturatedFatValue = _readDouble(normalizedKeyValue, const [
    'polyunsaturated_fat',
    'polyunsaturatedfat',
    'polyunsaturated_fat_100g',
    'polyunsaturatedfat100g',
    'polyunsaturated_fat_per_100g',
    'polyunsaturated-fat_100g',
    'polyunsaturatedfatper100g',
  ]);
  final fiberValue = _readDouble(normalizedKeyValue, const [
    'fiber',
    'fibre',
    'fibers',
    'fibres',
    'fiber_100g',
    'fibre_100g',
    'fiber_per_100g',
  ]);

  final kcal =
      kcalValue ?? (energyKjValue == null ? null : energyKjValue / 4.184);

  return NutritionOcrParseResult(
    productName: productName,
    brand: brand,
    quantityLabel: quantityLabel,
    servingSizeLabel: servingSizeLabel,
    per100: NutritionPer100(
      kcal: kcal ?? 0,
      protein: proteinValue ?? 0,
      carbs: carbsValue ?? 0,
      fat: fatValue ?? 0,
      sugar: sugarValue ?? 0,
      salt: saltValue ?? 0,
      saturatedFat: saturatedFatValue,
      polyunsaturatedFat: polyunsaturatedFatValue,
      fiber: fiberValue,
    ),
    hasKcal: kcal != null,
    hasSugar: sugarValue != null,
    hasProtein: proteinValue != null,
    hasCarbs: carbsValue != null,
    hasFat: fatValue != null,
    hasSalt: saltValue != null,
    hasSaturatedFat: saturatedFatValue != null,
    hasPolyunsaturatedFat: polyunsaturatedFatValue != null,
    hasFiber: fiberValue != null,
  );
}

NutritionOcrParseResult? tryParseNutritionOcrResult(String rawResponse) {
  try {
    return parseNutritionOcrResult(rawResponse);
  } catch (_) {
    return null;
  }
}

String _extractJsonPayload(String raw) {
  final trimmed = raw.trim();
  final fencePattern = RegExp(r'```(?:json)?\s*(.*?)\s*```', dotAll: true);
  final match = fencePattern.firstMatch(trimmed);
  if (match != null) {
    return match.group(1)?.trim() ?? '';
  }
  return trimmed;
}

dynamic _decodeJson(String payload) {
  try {
    return jsonDecode(payload);
  } catch (e) {
    throw NutritionOcrParseException(
      'Invalid OCR JSON payload: $e',
      code: 'INVALID_JSON',
      originalException: e,
    );
  }
}

Map<String, dynamic>? _coerceRootMap(dynamic decoded) {
  if (decoded is Map<String, dynamic>) return decoded;

  if (decoded is Map) {
    return decoded.cast<String, dynamic>();
  }

  if (decoded is List) {
    for (final item in decoded) {
      final map = _coerceRootMap(item);
      if (map != null) return map;
    }
  }

  return null;
}

void _indexMap(Map<String, dynamic> input, Map<String, dynamic> output) {
  input.forEach((key, value) {
    final normalizedKey = _normalizeKey(key);

    if (_isScalar(value) && value != null) {
      output.putIfAbsent(normalizedKey, () => value);
    }

    if (value is Map<String, dynamic>) {
      _indexMap(value, output);
    } else if (value is Map) {
      _indexMap(value.cast<String, dynamic>(), output);
    } else if (value is List) {
      for (final item in value) {
        if (item is Map<String, dynamic>) {
          _indexMap(item, output);
        } else if (item is Map) {
          _indexMap(item.cast<String, dynamic>(), output);
        }
      }
    }
  });
}

bool _isScalar(Object? value) {
  return value is num || value is String || value is bool;
}

String? _readString(Map<String, dynamic> values, List<String> keys) {
  for (final key in keys) {
    final normalized = _normalizeKey(key);
    final value = values[normalized];
    if (value == null) continue;

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
      continue;
    }

    if (value is num) return value.toString();
  }
  return null;
}

double? _readDouble(Map<String, dynamic> values, List<String> keys) {
  for (final key in keys) {
    final normalized = _normalizeKey(key);
    final value = values[normalized];
    final parsed = _toDouble(value);
    if (parsed != null) return parsed;
  }
  return null;
}

double? _toDouble(dynamic value) {
  if (value == null) return null;

  if (value is num) return value.toDouble();

  if (value is bool) return value ? 1 : 0;

  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;

    final direct = double.tryParse(normalized.replaceAll(',', '.'));
    if (direct != null) return direct;

    final match = RegExp(r'-?\d+(?:[\.,]\d+)?').firstMatch(normalized);
    if (match == null) return null;

    final extracted = match.group(0)!.replaceAll(',', '.');
    return double.tryParse(extracted);
  }

  if (value is Map) {
    final map = value.cast<String, dynamic>();
    for (final nestedKey in const ['value', 'amount', 'per100', 'per_100g']) {
      if (!map.containsKey(nestedKey)) continue;
      final nested = _toDouble(map[nestedKey]);
      if (nested != null) return nested;
    }
  }

  return null;
}

String _normalizeKey(String key) {
  return key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}
