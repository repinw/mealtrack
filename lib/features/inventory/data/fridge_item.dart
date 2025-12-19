import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import 'package:mealtrack/features/inventory/data/discount.dart';

part 'fridge_item.g.dart';

@HiveType(typeId: 1)
// ignore: must_be_immutable
class FridgeItem extends HiveObject with EquatableMixin {
  /// Dieser Konstruktor ist nur für die interne Verwendung und für die Hive-Serialisierung gedacht.
  /// Um eine neue Instanz zu erstellen, verwende die [FridgeItem.create] Factory.
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
    List<Discount>? discounts,
  }) : discounts = discounts ?? [];

  /// Erstellt eine neue Instanz von [FridgeItem] mit einer generierten UUID und dem aktuellen Datum.
  ///
  /// Akzeptiert optional eine [Uuid]-Instanz und eine [now] Funktion für Testzwecke.
  factory FridgeItem.create({
    required String rawText,
    Uuid? uuid,
    required String storeName,
    int quantity = 1,
    double? unitPrice,
    String? weight,
    String? receiptId,
    List<Discount>? discounts,
    DateTime Function()? now,
  }) {
    if (rawText.trim().isEmpty) {
      throw ArgumentError.value(rawText, 'rawText', 'darf nicht leer sein');
    }
    if (storeName.trim().isEmpty) {
      throw ArgumentError.value(storeName, 'storeName', 'darf nicht leer sein');
    }
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', 'muss größer als 0 sein');
    }
    if (unitPrice != null && unitPrice < 0) {
      throw ArgumentError.value(
        unitPrice,
        'unitPrice',
        'darf nicht negativ sein',
      );
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
      discounts: discounts ?? [],
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

  @HiveField(5, defaultValue: 'Unbekannt')
  String storeName;

  @HiveField(6, defaultValue: 1)
  int quantity;

  @HiveField(7)
  double? unitPrice;

  @HiveField(8)
  String? weight;

  @HiveField(9, defaultValue: <Discount>[])
  List<Discount> discounts;

  @HiveField(10)
  final String? receiptId;

  @override
  List<Object?> get props => [
    id,
    rawText,
    entryDate,
    isConsumed,
    consumptionDate,
    discounts,
    receiptId,
  ];

  @override
  bool? get stringify => true;

  void markAsConsumed({DateTime? consumptionTime}) {
    if (isConsumed) return;
    isConsumed = true;
    consumptionDate = consumptionTime ?? DateTime.now();
  }
}
