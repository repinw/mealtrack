import 'package:mealtrack/features/inventory/data/discount.dart' as inventory;
import 'package:mealtrack/features/inventory/data/fridge_item.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';
import 'package:uuid/uuid.dart';

class ScannedItemConverter {
  static List<FridgeItem> toFridgeItems(
    List<ScannedItem> items,
    String storeName,
  ) {
    final receiptId = const Uuid().v4();
    return items.where((item) => item.quantity > 0).map((item) {
      final unitPrice = item.totalPrice / item.quantity;
      final discounts = item.discounts
          .map((d) => inventory.Discount(name: d.name, amount: d.amount))
          .toList();

      return FridgeItem.create(
        rawText: item.name,
        storeName: storeName,
        quantity: item.quantity,
        unitPrice: unitPrice,
        weight: item.weight,
        discounts: discounts,
        receiptId: receiptId,
      );
    }).toList();
  }
}
