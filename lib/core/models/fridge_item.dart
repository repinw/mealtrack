import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

class FridgeItem extends Equatable {
  /// This constructor is intended for internal use only.
  /// To create a new instance, use the [FridgeItem.create] factory.
  @internal
  const FridgeItem({
    required this.id,
    required this.rawText,
    required this.entryDate,
    this.isConsumed = false,
    required this.storeName,
    required this.quantity,
    this.unitPrice,
    this.weight,
    this.consumptionDate,
    this.receiptId,
    this.brand,
    this.discounts = const {},
  });

  /// Creates a new instance of [FridgeItem] with a generated UUID and the current date.
  ///
  /// Optionally accepts a [Uuid] instance and a [now] function for testing purposes.
  factory FridgeItem.create({
    required String rawText,
    Uuid? uuid,
    required String storeName,
    int quantity = 1,
    double? unitPrice,
    String? weight,
    String? receiptId,
    String? brand,
    Map<String, double>? discounts,
    DateTime Function()? now,
  }) {
    if (rawText.trim().isEmpty) {
      throw ArgumentError.value(rawText, 'rawText', 'must not be empty');
    }
    if (storeName.trim().isEmpty) {
      throw ArgumentError.value(storeName, 'storeName', 'must not be empty');
    }
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', 'must be greater than 0');
    }
    if (unitPrice != null && unitPrice < 0) {
      throw ArgumentError.value(unitPrice, 'unitPrice', 'must not be negative');
    }

    return FridgeItem(
      id: (uuid ?? const Uuid()).v4(),
      rawText: rawText,
      storeName: storeName,
      quantity: quantity,
      unitPrice: unitPrice,
      weight: weight,
      entryDate: (now ?? DateTime.now)(),
      isConsumed: false,
      receiptId: receiptId,
      brand: brand,
      discounts: discounts ?? {},
    );
  }

  final String id;

  final String rawText;

  final DateTime entryDate;

  final bool isConsumed;

  final DateTime? consumptionDate;

  final String storeName;

  final int quantity;

  final double? unitPrice;

  final String? weight;

  final Map<String, double> discounts;

  final String? receiptId;

  final String? brand;

  @override
  List<Object?> get props => [
    id,
    rawText,
    entryDate,
    isConsumed,
    consumptionDate,
    storeName,
    quantity,
    unitPrice,
    weight,
    discounts,
    receiptId,
    brand,
  ];

  @override
  bool? get stringify => true;

  /// Creates a [FridgeItem] from a JSON map.
  factory FridgeItem.fromJson(Map<String, dynamic> json) {
    return FridgeItem(
      id: json['id'] as String,
      rawText: json['rawText'] as String,
      entryDate: DateTime.parse(json['entryDate'] as String),
      isConsumed: json['isConsumed'] as bool? ?? false,
      consumptionDate: json['consumptionDate'] != null
          ? DateTime.parse(json['consumptionDate'] as String)
          : null,
      storeName: json['storeName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      weight: json['weight'] as String?,
      discounts:
          (json['discounts'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          const {},
      receiptId: json['receiptId'] as String?,
      brand: json['brand'] as String?,
    );
  }

  /// Converts the [FridgeItem] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rawText': rawText,
      'entryDate': entryDate.toIso8601String(),
      'isConsumed': isConsumed,
      'consumptionDate': consumptionDate?.toIso8601String(),
      'storeName': storeName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'weight': weight,
      'discounts': discounts,
      'receiptId': receiptId,
      'brand': brand,
    };
  }

  FridgeItem copyWith({
    String? id,
    String? rawText,
    DateTime? entryDate,
    bool? isConsumed,
    DateTime? consumptionDate,
    String? storeName,
    int? quantity,
    double? unitPrice,
    String? weight,
    Map<String, double>? discounts,
    String? receiptId,
    String? brand,
  }) {
    return FridgeItem(
      id: id ?? this.id,
      rawText: rawText ?? this.rawText,
      entryDate: entryDate ?? this.entryDate,
      isConsumed: isConsumed ?? this.isConsumed,
      consumptionDate: consumptionDate ?? this.consumptionDate,
      storeName: storeName ?? this.storeName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      weight: weight ?? this.weight,
      discounts: discounts ?? this.discounts,
      receiptId: receiptId ?? this.receiptId,
      brand: brand ?? this.brand,
    );
  }
}
