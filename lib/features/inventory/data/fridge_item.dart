import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import 'package:mealtrack/features/inventory/data/discount.dart';

// ignore: must_be_immutable
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
    List<Discount>? discounts,
  }) : discounts = discounts ?? [];

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
    List<Discount>? discounts,
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
      discounts: discounts ?? [],
    );
  }

  final String id;

  String rawText;

  final DateTime entryDate;

  bool isConsumed;

  DateTime? consumptionDate;

  String storeName;

  int quantity;

  double? unitPrice;

  String? weight;

  List<Discount> discounts;

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

  void markAsConsumed({DateTime? consumptionTime}) {
    if (isConsumed) return;
    isConsumed = true;
    consumptionDate = consumptionTime ?? DateTime.now();
  }
}
