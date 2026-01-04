import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/inventory/domain/inventory_filter_type.dart';

void main() {
  group('InventoryFilterType', () {
    test('should contain all, available, and empty values', () {
      expect(InventoryFilterType.values, contains(InventoryFilterType.all));
      expect(
        InventoryFilterType.values,
        contains(InventoryFilterType.available),
      );
      expect(InventoryFilterType.values, contains(InventoryFilterType.empty));
      expect(InventoryFilterType.values.length, 3);
    });
  });
}
