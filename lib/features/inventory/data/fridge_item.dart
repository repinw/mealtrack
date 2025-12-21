import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'fridge_item.g.dart';

@HiveType(typeId: 1)
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
  String rawText;

  @HiveField(2)
  final DateTime entryDate;

  @HiveField(3)
  bool isConsumed;

  @HiveField(4)
  DateTime? consumptionDate;

  @HiveField(5, defaultValue: 'Unknown')
  String storeName;

  @HiveField(6, defaultValue: 1)
  int quantity;

  @HiveField(7)
  double? unitPrice;

  @HiveField(8)
  String? weight;

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

  void markAsConsumed({DateTime? consumptionTime}) {
    if (isConsumed) return;
    isConsumed = true;
    consumptionDate = consumptionTime ?? DateTime.now();
  }
}
