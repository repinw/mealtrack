import 'package:mealtrack/features/calories/domain/meal_type.dart';
import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';

enum CalorieEntrySource {
  offBarcode,
  ocrLabel,
  manual;

  String get value => switch (this) {
    CalorieEntrySource.offBarcode => 'off_barcode',
    CalorieEntrySource.ocrLabel => 'ocr_label',
    CalorieEntrySource.manual => 'manual',
  };

  static CalorieEntrySource fromValue(String? value) {
    return switch (value) {
      'off_barcode' => CalorieEntrySource.offBarcode,
      'ocr_label' => CalorieEntrySource.ocrLabel,
      _ => CalorieEntrySource.manual,
    };
  }
}

enum ConsumedUnit {
  grams,
  milliliters;

  String get value => switch (this) {
    ConsumedUnit.grams => 'g',
    ConsumedUnit.milliliters => 'ml',
  };

  static ConsumedUnit fromValue(String? value) {
    return switch (value) {
      'ml' => ConsumedUnit.milliliters,
      _ => ConsumedUnit.grams,
    };
  }
}

class CalorieEntry {
  final String id;
  final String userId;
  final String productName;
  final String? brand;
  final String? barcode;
  final String? offProductRef;
  final CalorieEntrySource source;
  final MealType mealType;
  final double consumedAmount;
  final ConsumedUnit consumedUnit;
  final NutritionPer100 per100;
  final double totalKcal;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final DateTime loggedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CalorieEntry({
    required this.id,
    required this.userId,
    required this.productName,
    required this.source,
    required this.mealType,
    required this.consumedAmount,
    required this.consumedUnit,
    required this.per100,
    required this.totalKcal,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.loggedAt,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
    this.barcode,
    this.offProductRef,
  });

  factory CalorieEntry.create({
    required String id,
    required String userId,
    required String productName,
    required CalorieEntrySource source,
    required MealType mealType,
    required double consumedAmount,
    required ConsumedUnit consumedUnit,
    required NutritionPer100 per100,
    DateTime? loggedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? brand,
    String? barcode,
    String? offProductRef,
  }) {
    final now = DateTime.now();
    final totals = per100.scaleForAmount(consumedAmount);

    return CalorieEntry(
      id: id,
      userId: userId,
      productName: productName,
      source: source,
      mealType: mealType,
      consumedAmount: consumedAmount,
      consumedUnit: consumedUnit,
      per100: per100,
      totalKcal: totals.kcal,
      totalProtein: totals.protein,
      totalCarbs: totals.carbs,
      totalFat: totals.fat,
      loggedAt: loggedAt ?? now,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      brand: brand,
      barcode: barcode,
      offProductRef: offProductRef,
    );
  }

  CalorieEntry copyWith({
    String? id,
    String? userId,
    String? productName,
    String? brand,
    String? barcode,
    String? offProductRef,
    CalorieEntrySource? source,
    MealType? mealType,
    double? consumedAmount,
    ConsumedUnit? consumedUnit,
    NutritionPer100? per100,
    double? totalKcal,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    DateTime? loggedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalorieEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productName: productName ?? this.productName,
      source: source ?? this.source,
      mealType: mealType ?? this.mealType,
      consumedAmount: consumedAmount ?? this.consumedAmount,
      consumedUnit: consumedUnit ?? this.consumedUnit,
      per100: per100 ?? this.per100,
      totalKcal: totalKcal ?? this.totalKcal,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      offProductRef: offProductRef ?? this.offProductRef,
    );
  }

  CalorieEntry recalculateTotals({DateTime? updatedAt}) {
    final totals = per100.scaleForAmount(consumedAmount);
    return copyWith(
      totalKcal: totals.kcal,
      totalProtein: totals.protein,
      totalCarbs: totals.carbs,
      totalFat: totals.fat,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  bool get isValid =>
      productName.trim().isNotEmpty &&
      userId.trim().isNotEmpty &&
      consumedAmount > 0 &&
      !per100.hasNegativeValues &&
      totalKcal >= 0 &&
      totalProtein >= 0 &&
      totalCarbs >= 0 &&
      totalFat >= 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productName': productName,
      'brand': brand,
      'barcode': barcode,
      'offProductRef': offProductRef,
      'source': source.value,
      'mealType': mealType.name,
      'consumedAmount': consumedAmount,
      'consumedUnit': consumedUnit.value,
      'per100': per100.toJson(),
      'totalKcal': totalKcal,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'loggedAt': loggedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CalorieEntry.fromJson(Map<String, dynamic> json) {
    return CalorieEntry(
      id: (json['id'] as String?) ?? '',
      userId: (json['userId'] as String?) ?? '',
      productName: (json['productName'] as String?) ?? '',
      source: CalorieEntrySource.fromValue(json['source'] as String?),
      mealType: _mealTypeFromValue(json['mealType'] as String?),
      consumedAmount: _toDouble(json['consumedAmount']),
      consumedUnit: ConsumedUnit.fromValue(json['consumedUnit'] as String?),
      per100: NutritionPer100.fromJson(
        (json['per100'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
      totalKcal: _toDouble(json['totalKcal']),
      totalProtein: _toDouble(json['totalProtein']),
      totalCarbs: _toDouble(json['totalCarbs']),
      totalFat: _toDouble(json['totalFat']),
      loggedAt: _toDateTime(json['loggedAt']),
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
      brand: json['brand'] as String?,
      barcode: json['barcode'] as String?,
      offProductRef: json['offProductRef'] as String?,
    );
  }

  static MealType _mealTypeFromValue(String? value) {
    return MealType.values.where((item) => item.name == value).firstOrNull ??
        MealType.snack;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value.replaceAll(',', '.');
      return double.tryParse(normalized) ?? 0;
    }
    return 0;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
