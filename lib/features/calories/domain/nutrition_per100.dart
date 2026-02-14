class NutritionPer100 {
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final double sugar;
  final double salt;
  final double? saturatedFat;
  final double? polyunsaturatedFat;
  final double? fiber;

  const NutritionPer100({
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
    required this.salt,
    this.saturatedFat,
    this.polyunsaturatedFat,
    this.fiber,
  });

  static const NutritionPer100 zero = NutritionPer100(
    kcal: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
    sugar: 0,
    salt: 0,
  );

  NutritionPer100 copyWith({
    double? kcal,
    double? protein,
    double? carbs,
    double? fat,
    double? sugar,
    double? salt,
    double? saturatedFat,
    bool clearSaturatedFat = false,
    double? polyunsaturatedFat,
    bool clearPolyunsaturatedFat = false,
    double? fiber,
    bool clearFiber = false,
  }) {
    return NutritionPer100(
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      sugar: sugar ?? this.sugar,
      salt: salt ?? this.salt,
      saturatedFat: clearSaturatedFat
          ? null
          : (saturatedFat ?? this.saturatedFat),
      polyunsaturatedFat: clearPolyunsaturatedFat
          ? null
          : (polyunsaturatedFat ?? this.polyunsaturatedFat),
      fiber: clearFiber ? null : (fiber ?? this.fiber),
    );
  }

  bool get hasNegativeValues =>
      kcal < 0 ||
      protein < 0 ||
      carbs < 0 ||
      fat < 0 ||
      sugar < 0 ||
      salt < 0 ||
      (saturatedFat != null && saturatedFat! < 0) ||
      (polyunsaturatedFat != null && polyunsaturatedFat! < 0) ||
      (fiber != null && fiber! < 0);

  bool get isZero =>
      kcal == 0 &&
      protein == 0 &&
      carbs == 0 &&
      fat == 0 &&
      sugar == 0 &&
      salt == 0 &&
      (saturatedFat == null || saturatedFat == 0) &&
      (polyunsaturatedFat == null || polyunsaturatedFat == 0) &&
      (fiber == null || fiber == 0);

  NutritionTotals scaleForAmount(double amountInGramsOrMl) {
    final factor = amountInGramsOrMl / 100;
    return NutritionTotals(
      kcal: kcal * factor,
      protein: protein * factor,
      carbs: carbs * factor,
      fat: fat * factor,
      sugar: sugar * factor,
      salt: salt * factor,
      saturatedFat: saturatedFat == null ? null : saturatedFat! * factor,
      polyunsaturatedFat: polyunsaturatedFat == null
          ? null
          : polyunsaturatedFat! * factor,
      fiber: fiber == null ? null : fiber! * factor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kcal': kcal,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'sugar': sugar,
      'salt': salt,
      if (saturatedFat != null) 'saturatedFat': saturatedFat,
      if (polyunsaturatedFat != null) 'polyunsaturatedFat': polyunsaturatedFat,
      if (fiber != null) 'fiber': fiber,
    };
  }

  factory NutritionPer100.fromJson(Map<String, dynamic> json) {
    return NutritionPer100(
      kcal: _toDouble(json['kcal']),
      protein: _toDouble(json['protein']),
      carbs: _toDouble(json['carbs']),
      fat: _toDouble(json['fat']),
      sugar: _toDouble(json['sugar']),
      salt: _toDouble(json['salt']),
      saturatedFat: _toNullableDouble(json['saturatedFat']),
      polyunsaturatedFat: _toNullableDouble(json['polyunsaturatedFat']),
      fiber: _toNullableDouble(json['fiber']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value.replaceAll(',', '.');
      return double.tryParse(normalized) ?? 0;
    }
    return 0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value.trim().replaceAll(',', '.');
      if (normalized.isEmpty) return null;
      return double.tryParse(normalized);
    }
    return null;
  }
}

class NutritionTotals {
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final double sugar;
  final double salt;
  final double? saturatedFat;
  final double? polyunsaturatedFat;
  final double? fiber;

  const NutritionTotals({
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
    required this.salt,
    this.saturatedFat,
    this.polyunsaturatedFat,
    this.fiber,
  });

  static const NutritionTotals zero = NutritionTotals(
    kcal: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
    sugar: 0,
    salt: 0,
  );

  Map<String, dynamic> toJson() {
    return {
      'kcal': kcal,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'sugar': sugar,
      'salt': salt,
      if (saturatedFat != null) 'saturatedFat': saturatedFat,
      if (polyunsaturatedFat != null) 'polyunsaturatedFat': polyunsaturatedFat,
      if (fiber != null) 'fiber': fiber,
    };
  }
}
