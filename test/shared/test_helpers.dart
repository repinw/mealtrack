import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:uuid/uuid.dart';

FridgeItem createTestFridgeItem({
  String? id,
  String name = 'Test Item',
  String storeName = 'Test Store',
  int quantity = 1,
  double unitPrice = 0,
  String? weight,
  String? receiptId,
  DateTime? receiptDate,
  String? language,
  String? brand,
  String? category,
  Map<String, double>? discounts,
  DateTime Function()? now,
  bool isDeposit = false,
  bool isDiscount = false,
  bool isArchived = false,
  DateTime? entryDate,
}) {
  final normalizedAmounts = normalizeItemAmounts(
    quantity: quantity,
    initialQuantity: quantity,
    weight: weight,
  );

  return FridgeItem(
    id: id ?? const Uuid().v4(),
    name: name,
    storeName: storeName,
    quantity: quantity,
    initialQuantity: quantity,
    unitPrice: unitPrice,
    weight: weight,
    amountUnit: normalizedAmounts.unit,
    initialAmountBase: normalizedAmounts.initialAmountBase,
    remainingAmountBase: normalizedAmounts.remainingAmountBase,
    entryDate: entryDate ?? (now ?? DateTime.now)(),
    receiptId: receiptId,
    receiptDate: receiptDate,
    language: language,
    brand: brand,
    category: category,
    discounts: discounts ?? {},
    consumptionEvents: const [],
    isDeposit: isDeposit,
    isDiscount: isDiscount,
    isArchived: isArchived,
  );
}
