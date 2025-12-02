import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'fridge_item.g.dart';

@HiveType(typeId: 1)
class FridgeItem extends HiveObject with EquatableMixin {
  /// Dieser Konstruktor ist nur für die interne Verwendung und für die Hive-Serialisierung gedacht.
  /// Um eine neue Instanz zu erstellen, verwende die [FridgeItem.create] Factory.
  @internal
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
    if (rawText.trim().isEmpty) {
      throw ArgumentError.value(rawText, 'rawText', 'darf nicht leer sein');
    }
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
  List<Object?> get props => [
    id,
    rawText,
    entryDate,
    isConsumed,
    consumptionDate,
  ];

  @override
  bool? get stringify => true;

  void markAsConsumed({DateTime? consumptionTime}) {
    if (isConsumed) return;
    isConsumed = true;
    consumptionDate = consumptionTime ?? DateTime.now();
  }
}
