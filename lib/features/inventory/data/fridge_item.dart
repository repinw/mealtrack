import 'package:hive/hive.dart';

part 'fridge_item.g.dart';

@HiveType(typeId: 1)
class FridgeItem extends HiveObject {
  FridgeItem({
    required this.id,
    required this.rawText,
    required this.entryDate,
    required this.isConsumed,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String rawText;

  @HiveField(2)
  DateTime entryDate;

  @HiveField(3)
  bool isConsumed;

  @override
  String toString() {
    return ' $id: $rawText: $entryDate: $isConsumed';
  }
}
