import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';

void main() {
  group('ShoppingListItem', () {
    test('supports value equality', () {
      const item1 = ShoppingListItem(id: '1', name: 'Milk');
      const item2 = ShoppingListItem(id: '1', name: 'Milk');

      expect(item1, equals(item2));
    });

    test('defaults are correct', () {
      const item = ShoppingListItem(id: '1', name: 'Milk');
      expect(item.isChecked, false);
      expect(item.quantity, 1);
      expect(item.brand, null);
    });

    test('copyWith updates properties', () {
      const item = ShoppingListItem(id: '1', name: 'Milk');
      final updated = item.copyWith(
        name: 'Eggs',
        isChecked: true,
        quantity: 2,
        brand: 'Farm',
      );

      expect(updated.id, '1');
      expect(updated.name, 'Eggs');
      expect(updated.isChecked, true);
      expect(updated.quantity, 2);
      expect(updated.brand, 'Farm');
    });

    test('copyWith retains old properties if params are null', () {
      const item = ShoppingListItem(id: '1', name: 'Milk', isChecked: true);
      final updated = item.copyWith();

      expect(updated, item);
    });
  });
}
