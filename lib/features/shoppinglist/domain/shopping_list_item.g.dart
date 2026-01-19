// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'shopping_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShoppingListItem _$ShoppingListItemFromJson(Map<String, dynamic> json) =>
    _ShoppingListItem(
      id: json['id'] as String,
      name: json['name'] as String,
      isChecked: json['isChecked'] as bool? ?? false,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      brand: json['brand'] as String?,
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ShoppingListItemToJson(_ShoppingListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isChecked': instance.isChecked,
      'quantity': instance.quantity,
      'brand': instance.brand,
      'unitPrice': instance.unitPrice,
    };
