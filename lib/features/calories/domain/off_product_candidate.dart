import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';

class OffProductCandidate {
  final String code;
  final String name;
  final String? brand;
  final String? quantityLabel;
  final String? servingSizeLabel;
  final String? imageUrl;
  final NutritionPer100 per100;
  final bool hasKcal;
  final bool hasProtein;
  final bool hasCarbs;
  final bool hasFat;
  final bool hasSugar;
  final bool hasSalt;
  final bool hasSaturatedFat;
  final bool hasPolyunsaturatedFat;
  final bool hasFiber;
  final double completenessScore;

  const OffProductCandidate({
    required this.code,
    required this.name,
    required this.per100,
    required this.hasKcal,
    required this.hasProtein,
    required this.hasCarbs,
    required this.hasFat,
    required this.hasSugar,
    required this.hasSalt,
    required this.hasSaturatedFat,
    required this.hasPolyunsaturatedFat,
    required this.hasFiber,
    required this.completenessScore,
    this.brand,
    this.quantityLabel,
    this.servingSizeLabel,
    this.imageUrl,
  });

  bool get hasCompleteCoreNutrition =>
      hasKcal && hasProtein && hasCarbs && hasFat && hasSugar && hasSalt;

  bool get hasAnyNutrition =>
      hasKcal ||
      hasProtein ||
      hasCarbs ||
      hasFat ||
      hasSugar ||
      hasSalt ||
      hasSaturatedFat ||
      hasPolyunsaturatedFat ||
      hasFiber;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'brand': brand,
      'quantityLabel': quantityLabel,
      'servingSizeLabel': servingSizeLabel,
      'imageUrl': imageUrl,
      'per100': per100.toJson(),
      'hasKcal': hasKcal,
      'hasProtein': hasProtein,
      'hasCarbs': hasCarbs,
      'hasFat': hasFat,
      'hasSugar': hasSugar,
      'hasSalt': hasSalt,
      'hasSaturatedFat': hasSaturatedFat,
      'hasPolyunsaturatedFat': hasPolyunsaturatedFat,
      'hasFiber': hasFiber,
      'completenessScore': completenessScore,
    };
  }

  factory OffProductCandidate.fromJson(Map<String, dynamic> json) {
    return OffProductCandidate(
      code: _asString(json['code']),
      name: _asString(json['name']),
      brand: _asNullableString(json['brand']),
      quantityLabel: _asNullableString(json['quantityLabel']),
      servingSizeLabel: _asNullableString(json['servingSizeLabel']),
      imageUrl: _asNullableString(json['imageUrl']),
      per100: NutritionPer100.fromJson(
        (json['per100'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
      hasKcal: _toBool(json['hasKcal']),
      hasProtein: _toBool(json['hasProtein']),
      hasCarbs: _toBool(json['hasCarbs']),
      hasFat: _toBool(json['hasFat']),
      hasSugar: _toBool(json['hasSugar']),
      hasSalt: _toBool(json['hasSalt']),
      hasSaturatedFat: _toBool(json['hasSaturatedFat']),
      hasPolyunsaturatedFat: _toBool(json['hasPolyunsaturatedFat']),
      hasFiber: _toBool(json['hasFiber']),
      completenessScore: _toDouble(json['completenessScore']) ?? 0,
    );
  }

  factory OffProductCandidate.fromOffJson(Map<String, dynamic> json) {
    final nutriments =
        (json['nutriments'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    final kcalRaw = _firstPresent(nutriments, const [
      'energy-kcal_100g',
      'energy-kcal',
      'energy_100g',
    ]);
    final proteinRaw = _firstPresent(nutriments, const ['proteins_100g']);
    final carbsRaw = _firstPresent(nutriments, const [
      'carbohydrates_100g',
      'carbs_100g',
    ]);
    final energyKjRaw = _firstPresent(nutriments, const [
      'energy-kj_100g',
      'energy-kj',
      'energy_kj_100g',
      'energy_kj',
    ]);
    final fatRaw = _firstPresent(nutriments, const ['fat_100g']);
    final sugarRaw = _firstPresent(nutriments, const [
      'sugars_100g',
      'sugar_100g',
    ]);
    final saltRaw = _firstPresent(nutriments, const ['salt_100g']);
    final saturatedFatRaw = _firstPresent(nutriments, const [
      'saturated-fat_100g',
      'saturated_fat_100g',
    ]);
    final polyunsaturatedFatRaw = _firstPresent(nutriments, const [
      'polyunsaturated-fat_100g',
      'polyunsaturated_fat_100g',
      'polyunsaturated-fat',
      'polyunsaturated_fat',
    ]);
    final fiberRaw = _firstPresent(nutriments, const [
      'fiber_100g',
      'fibres_100g',
    ]);

    final parsedKcalFromRaw = _toDouble(kcalRaw);
    final parsedEnergyKjFromRaw = _toDouble(energyKjRaw);
    final resolvedKcal =
        parsedKcalFromRaw ??
        (parsedEnergyKjFromRaw == null ? null : parsedEnergyKjFromRaw / 4.184);

    final hasKcal = resolvedKcal != null;
    final hasProtein = proteinRaw != null;
    final hasCarbs = carbsRaw != null;
    final hasFat = fatRaw != null;
    final hasSugar = sugarRaw != null;
    final hasSalt = saltRaw != null;
    final hasSaturatedFat = saturatedFatRaw != null;
    final hasPolyunsaturatedFat = polyunsaturatedFatRaw != null;
    final hasFiber = fiberRaw != null;

    final code = (json['code'] as String?)?.trim() ?? '';
    final name = _firstNonEmpty([
      json['product_name'] as String?,
      json['product_name_en'] as String?,
      json['generic_name'] as String?,
    ]);
    final brand = _firstNonEmpty([
      json['brands'] as String?,
      json['brand_owner'] as String?,
    ]);
    final quantity = (json['quantity'] as String?)?.trim();
    final servingSize = (json['serving_size'] as String?)?.trim();
    final imageUrl = _firstNonEmpty([
      json['image_front_small_url'] as String?,
      json['image_front_url'] as String?,
      json['image_url'] as String?,
    ]);

    final per100 = NutritionPer100(
      kcal: resolvedKcal ?? 0,
      protein: _toDouble(proteinRaw) ?? 0,
      carbs: _toDouble(carbsRaw) ?? 0,
      fat: _toDouble(fatRaw) ?? 0,
      sugar: _toDouble(sugarRaw) ?? 0,
      salt: _toDouble(saltRaw) ?? 0,
      saturatedFat: _toDouble(saturatedFatRaw),
      polyunsaturatedFat: _toDouble(polyunsaturatedFatRaw),
      fiber: _toDouble(fiberRaw),
    );

    final completenessScore = _computeScore(
      hasName: name.isNotEmpty,
      hasKcal: hasKcal,
      hasProtein: hasProtein,
      hasCarbs: hasCarbs,
      hasFat: hasFat,
      hasSugar: hasSugar,
      hasSalt: hasSalt,
    );

    return OffProductCandidate(
      code: code,
      name: name.isEmpty ? code : name,
      brand: brand,
      quantityLabel: quantity?.isEmpty == true ? null : quantity,
      servingSizeLabel: servingSize?.isEmpty == true ? null : servingSize,
      imageUrl: imageUrl,
      per100: per100,
      hasKcal: hasKcal,
      hasProtein: hasProtein,
      hasCarbs: hasCarbs,
      hasFat: hasFat,
      hasSugar: hasSugar,
      hasSalt: hasSalt,
      hasSaturatedFat: hasSaturatedFat,
      hasPolyunsaturatedFat: hasPolyunsaturatedFat,
      hasFiber: hasFiber,
      completenessScore: completenessScore,
    );
  }

  static dynamic _firstPresent(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        return map[key];
      }
    }
    return null;
  }

  static String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }
    return '';
  }

  static String _asString(dynamic value) {
    if (value is String) return value.trim();
    return '';
  }

  static String? _asNullableString(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value.trim().replaceAll(',', '.');
      return double.tryParse(normalized);
    }
    return null;
  }

  static double _computeScore({
    required bool hasName,
    required bool hasKcal,
    required bool hasProtein,
    required bool hasCarbs,
    required bool hasFat,
    required bool hasSugar,
    required bool hasSalt,
  }) {
    final dimensions = <bool>[
      hasName,
      hasKcal,
      hasProtein,
      hasCarbs,
      hasFat,
      hasSugar,
      hasSalt,
    ];
    final hits = dimensions.where((value) => value).length;
    return hits / dimensions.length;
  }
}
