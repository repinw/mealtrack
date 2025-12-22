import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'fridge_item.g.dart';

@HiveType(typeId: 1)
class FridgeItem extends HiveObject with EquatableMixin {
  /// This constructor is intended for internal use and Hive serialization only.
  /// To create a new instance, use the [FridgeItem.create] factory.
  @internal
  FridgeItem({
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

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String rawText;

  @HiveField(2)
  final DateTime entryDate;

  @HiveField(3)
  final bool isConsumed;

  @HiveField(4)
  final DateTime? consumptionDate;

  @HiveField(5, defaultValue: 'Unknown')
  final String storeName;

  @HiveField(6, defaultValue: 1)
  final int quantity;

  @HiveField(7)
  final double? unitPrice;

  @HiveField(8)
  final String? weight;

  @HiveField(9, defaultValue: const <String, double>{})
  final Map<String, double> discounts;

  @HiveField(10)
  final String? receiptId;

  @HiveField(11)
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
