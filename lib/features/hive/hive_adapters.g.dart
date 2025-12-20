// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class FridgeItemAdapter extends TypeAdapter<FridgeItem> {
  @override
  final typeId = 0;

  @override
  FridgeItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FridgeItem(
      id: fields[0] as String,
      rawText: fields[1] as String,
      entryDate: fields[2] as DateTime,
      isConsumed: fields[3] == null ? false : fields[3] as bool,
      storeName: fields[5] as String,
      quantity: (fields[6] as num).toInt(),
      unitPrice: (fields[7] as num?)?.toDouble(),
      weight: fields[8] as String?,
      consumptionDate: fields[4] as DateTime?,
      receiptId: fields[10] as String?,
      brand: fields[11] as String?,
      discounts: (fields[9] as List?)?.cast<Discount>(),
    );
  }

  @override
  void write(BinaryWriter writer, FridgeItem obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.rawText)
      ..writeByte(2)
      ..write(obj.entryDate)
      ..writeByte(3)
      ..write(obj.isConsumed)
      ..writeByte(4)
      ..write(obj.consumptionDate)
      ..writeByte(5)
      ..write(obj.storeName)
      ..writeByte(6)
      ..write(obj.quantity)
      ..writeByte(7)
      ..write(obj.unitPrice)
      ..writeByte(8)
      ..write(obj.weight)
      ..writeByte(9)
      ..write(obj.discounts)
      ..writeByte(10)
      ..write(obj.receiptId)
      ..writeByte(11)
      ..write(obj.brand);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FridgeItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DiscountAdapter extends TypeAdapter<Discount> {
  @override
  final typeId = 1;

  @override
  Discount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Discount(
      name: fields[0] as String,
      amount: (fields[1] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, Discount obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
