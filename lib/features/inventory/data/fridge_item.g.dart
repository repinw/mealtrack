// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fridge_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FridgeItemAdapter extends TypeAdapter<FridgeItem> {
  @override
  final int typeId = 1;

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
      isConsumed: fields[3] as bool,
      storeName: fields[5] == null ? 'Unknown' : fields[5] as String,
      quantity: fields[6] == null ? 1 : fields[6] as int,
      unitPrice: fields[7] as double?,
      weight: fields[8] as String?,
      consumptionDate: fields[4] as DateTime?,
      receiptId: fields[10] as String?,
      brand: fields[11] as String?,
      discounts:
          fields[9] == null ? {} : (fields[9] as Map).cast<String, double>(),
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
