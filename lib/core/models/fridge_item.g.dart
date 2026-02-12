// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'fridge_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FridgeItem _$FridgeItemFromJson(Map<String, dynamic> json) => _FridgeItem(
  id: json['id'] as String,
  name: json['name'] as String,
  entryDate: _dateTimeFromJson(json['entryDate']),
  storeName: json['storeName'] as String,
  quantity: (json['quantity'] as num).toInt(),
  initialQuantity: (json['initialQuantity'] as num?)?.toInt() ?? 1,
  unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
  weight: json['weight'] as String?,
  consumptionEvents:
      (json['consumptionEvents'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList() ??
      const [],
  receiptId: json['receiptId'] as String?,
  receiptDate: _nullableDateTimeFromJson(json['receiptDate']),
  language: json['language'] as String?,
  brand: json['brand'] as String?,
  category: json['category'] as String?,
  discounts:
      (json['discounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  isDeposit: json['isDeposit'] as bool? ?? false,
  isDiscount: json['isDiscount'] as bool? ?? false,
  isArchived: json['isArchived'] as bool? ?? false,
);

Map<String, dynamic> _$FridgeItemToJson(_FridgeItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'entryDate': instance.entryDate.toIso8601String(),
      'storeName': instance.storeName,
      'quantity': instance.quantity,
      'initialQuantity': instance.initialQuantity,
      'unitPrice': instance.unitPrice,
      'weight': instance.weight,
      'consumptionEvents': instance.consumptionEvents
          .map((e) => e.toIso8601String())
          .toList(),
      'receiptId': instance.receiptId,
      'receiptDate': instance.receiptDate?.toIso8601String(),
      'language': instance.language,
      'brand': instance.brand,
      'category': instance.category,
      'discounts': instance.discounts,
      'isDeposit': instance.isDeposit,
      'isDiscount': instance.isDiscount,
      'isArchived': instance.isArchived,
    };
