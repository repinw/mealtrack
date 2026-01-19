import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'shopping_list_item.freezed.dart';

@freezed
abstract class ShoppingListItem with _$ShoppingListItem {
  const factory ShoppingListItem({
    required String id,
    required String name,
    @Default(false) bool isChecked,
    @Default(1) int quantity,
    String? brand,
  }) = _ShoppingListItem;

  factory ShoppingListItem.create({
    required String name,
    int quantity = 1,
    String? brand,
  }) {
    return ShoppingListItem(
      id: const Uuid().v4(),
      name: name,
      quantity: quantity,
      brand: brand,
    );
  }
}
