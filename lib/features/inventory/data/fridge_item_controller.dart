import 'package:mealtrack/features/inventory/data/fridge_item.dart';

class FridgeItemController {
  Future<void> updateQuantity(FridgeItem item, int delta) async {
    final previousQuantity = item.quantity;
    final previousConsumed = item.isConsumed;
    final previousDate = item.consumptionDate;

    item.quantity += delta;
    if (item.quantity <= 0) {
      item.quantity = 0;
      item.markAsConsumed();
    } else if (item.isConsumed) {
      item.isConsumed = false;
      item.consumptionDate = null;
    }

    try {
      await item.save();
    } catch (e) {
      // Rollback bei Fehler
      item.quantity = previousQuantity;
      item.isConsumed = previousConsumed;
      item.consumptionDate = previousDate;
      rethrow;
    }
  }
}
