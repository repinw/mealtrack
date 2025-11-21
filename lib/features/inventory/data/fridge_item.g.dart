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
    );
  }

  @override
  void write(BinaryWriter writer, FridgeItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.rawText)
      ..writeByte(2)
      ..write(obj.entryDate)
      ..writeByte(3)
      ..write(obj.isConsumed);
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
