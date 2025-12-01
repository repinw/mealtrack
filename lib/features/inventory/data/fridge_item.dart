import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

part 'fridge_item.g.dart';

@HiveType(typeId: 1)
class FridgeItem extends HiveObject with EquatableMixin {
  FridgeItem({
    required this.id,
    required this.rawText,
    required this.entryDate,
    this.isConsumed = false,
    this.consumptionDate,
  });

  /// Erstellt eine neue Instanz von [FridgeItem] mit einer generierten UUID und dem aktuellen Datum.
  ///
  /// Akzeptiert optional eine [Uuid]-Instanz und eine [now] Funktion für Testzwecke.
  factory FridgeItem.create({
    required String rawText,
    Uuid? uuid,
    DateTime Function()? now,
  }) {
    return FridgeItem(
      id: (uuid ?? const Uuid()).v4(),
      rawText: rawText,
      entryDate: (now ?? DateTime.now)(),
      isConsumed: false,
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

  @override
  String toString() {
    return 'FridgeItem(id: $id, rawText: $rawText, entryDate: $entryDate, isConsumed: $isConsumed)';
  }

  @override
  List<Object?> get props => [
    id,
    rawText,
    entryDate,
    isConsumed,
    consumptionDate,
  ];

  @override
  bool? get stringify => true;
}
