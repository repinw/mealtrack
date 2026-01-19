import 'package:rxdart/rxdart.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';

class InMemoryShoppingListRepository implements ShoppingListRepository {
  final _itemsSubject = BehaviorSubject<List<ShoppingListItem>>.seeded([]);

  @override
  Future<void> addItem(ShoppingListItem item) async {
    final current = _itemsSubject.value;
    _itemsSubject.add([...current, item]);
  }

  @override
  Future<void> deleteItem(String id) async {
    final current = _itemsSubject.value;
    _itemsSubject.add(current.where((item) => item.id != id).toList());
  }

  @override
  Future<void> updateItem(ShoppingListItem item) async {
    final current = _itemsSubject.value;
    _itemsSubject.add(current.map((i) => i.id == item.id ? item : i).toList());
  }

  @override
  Future<void> clearList() async {
    _itemsSubject.add([]);
  }

  @override
  Stream<List<ShoppingListItem>> watchItems() {
    return _itemsSubject.stream;
  }
}
