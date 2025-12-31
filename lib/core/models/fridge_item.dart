import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

class FridgeItem extends Equatable {
  /// This constructor is intended for internal use only.
  /// To create a new instance, use the [FridgeItem.create] factory.
  @internal
  const FridgeItem({
    required this.id,
    required this.name,
    required this.entryDate,
    this.isConsumed = false,
    required this.storeName,
    required this.quantity,
    this.initialQuantity = 1,
    this.unitPrice = 0.0,
    this.weight,
    this.consumptionEvents = const [],
    this.receiptId,
    this.receiptDate,
    this.language,
    this.brand,
    this.discounts = const {},
  });

  /// Creates a new instance of [FridgeItem] with a generated UUID and the current date.
  ///
  /// Optionally accepts a [Uuid] instance and a [now] function for testing purposes.
  factory FridgeItem.create({
    required String name,
    Uuid? uuid,
    required String storeName,
    int quantity = 1,
    double unitPrice = 0,
    String? weight,
    String? receiptId,
    DateTime? receiptDate,
    String? language,
    String? brand,
    Map<String, double>? discounts,
    DateTime Function()? now,
  }) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
    if (storeName.trim().isEmpty) {
      throw ArgumentError.value(storeName, 'storeName', 'must not be empty');
    }
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', 'must be greater than 0');
    }
    if (unitPrice < 0) {
      throw ArgumentError.value(unitPrice, 'unitPrice', 'must not be negative');
    }

    return FridgeItem(
      id: (uuid ?? const Uuid()).v4(),
      name: name,
      storeName: storeName,
      quantity: quantity,
      unitPrice: unitPrice,
      weight: weight,
      entryDate: (now ?? DateTime.now)(),
      isConsumed: false,
      receiptId: receiptId,
      receiptDate: receiptDate,
      language: language,
      brand: brand,
      discounts: discounts ?? {},
      initialQuantity: quantity,
      consumptionEvents: const [],
    );
  }

  final String id;

  final String name;

  final DateTime entryDate;

  final bool isConsumed;

  final List<DateTime> consumptionEvents;

  DateTime? get consumptionDate =>
      consumptionEvents.isNotEmpty ? consumptionEvents.last : null;

  final String storeName;

  final int quantity;

  final double unitPrice;

  final String? weight;

  final Map<String, double> discounts;

  final String? receiptId;

  final DateTime? receiptDate;

  final String? language;

  final String? brand;

  final int initialQuantity;

  @override
  List<Object?> get props => [
    id,
    name,
    entryDate,
    isConsumed,
    consumptionEvents,
    storeName,
    quantity,
    unitPrice,
    weight,
    discounts,
    receiptId,
    receiptDate,
    language,
    brand,
    initialQuantity,
  ];

  @override
  bool? get stringify => true;

  /// Creates a [FridgeItem] from a JSON map.
  factory FridgeItem.fromJson(Map<String, dynamic> json) {
    // Handle legacy consumptionDate if consumptionEvents is missing
    var events =
        (json['consumptionEvents'] as List<dynamic>?)
            ?.map((e) => DateTime.parse(e as String))
            .toList() ??
        [];

    if (events.isEmpty && json['consumptionDate'] != null) {
      final legacyDate = DateTime.tryParse(json['consumptionDate'] as String);
      if (legacyDate != null) {
        events = [legacyDate];
      }
    }

    return FridgeItem(
      id: json['id'] as String,
      name: json['name'] as String,
      entryDate:
          DateTime.tryParse(json['entryDate'] as String? ?? '') ??
          DateTime.now(),
      isConsumed: json['isConsumed'] as bool? ?? false,
      consumptionEvents: events,
      storeName: json['storeName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      weight: json['weight'] as String?,
      discounts:
          (json['discounts'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          const {},
      receiptId: json['receiptId'] as String?,
      receiptDate: DateTime.tryParse(json['receiptDate'] as String? ?? ''),
      language: json['language'] as String?,
      brand: json['brand'] as String?,
      initialQuantity:
          json['initialQuantity'] as int? ?? json['quantity'] as int,
    );
  }

  /// Converts the [FridgeItem] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'entryDate': entryDate.toIso8601String(),
      'isConsumed': isConsumed,
      'consumptionEvents': consumptionEvents
          .map((e) => e.toIso8601String())
          .toList(),
      'consumptionDate': consumptionDate?.toIso8601String(), // Legacy support
      'storeName': storeName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'weight': weight,
      'discounts': discounts,
      'receiptId': receiptId,
      'receiptDate': receiptDate?.toIso8601String(),
      'language': language,
      'brand': brand,
      'initialQuantity': initialQuantity,
    };
  }

  FridgeItem copyWith({
    String? id,
    String? name,
    DateTime? entryDate,
    bool? isConsumed,
    List<DateTime>? consumptionEvents,
    String? storeName,
    int? quantity,
    double? unitPrice,
    String? weight,
    bool clearWeight = false,
    Map<String, double>? discounts,
    String? receiptId,
    String? brand,
    DateTime? receiptDate,
    String? language,
    int? initialQuantity,
  }) {
    return FridgeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      entryDate: entryDate ?? this.entryDate,
      isConsumed: isConsumed ?? this.isConsumed,
      consumptionEvents: consumptionEvents ?? this.consumptionEvents,
      storeName: storeName ?? this.storeName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      weight: clearWeight ? null : (weight ?? this.weight),
      discounts: discounts ?? this.discounts,
      receiptId: receiptId ?? this.receiptId,
      receiptDate: receiptDate ?? this.receiptDate,
      language: language ?? this.language,
      brand: brand ?? this.brand,
      initialQuantity: initialQuantity ?? this.initialQuantity,
    );
  }
}
