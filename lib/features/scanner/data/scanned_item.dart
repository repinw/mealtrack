import 'package:mealtrack/features/scanner/data/discount.dart';

/// Represents one Item scanned from a receipt.
class ScannedItem {
  ScannedItem({
    required this.name,
    this.quantity = 1,
    required this.totalPrice,
    this.unitPrice,
    this.weight,
    List<Discount>? discounts,
    this.isLowConfidence = false,
    this.storeName,
  }) : discounts = discounts ?? [];

  String name;

  int quantity;

  double totalPrice;

  double? unitPrice;

  String? weight;

  List<Discount> discounts;

  bool isLowConfidence;

  String? storeName;

  double get totalDiscount => discounts.fold(0.0, (sum, d) => sum + d.amount);

  double get effectivePrice => totalPrice - totalDiscount;

  /// Calculates the effective price (total - discount) for a specific quantity,
  /// using the current unit price logic.
  double calculateEffectivePriceForQuantity(int quantity) {
    double uPrice = unitPrice ?? 0.0;
    if (uPrice == 0.0 && this.quantity > 0) {
      uPrice = totalPrice / this.quantity;
    }
    final grossTotal = uPrice * quantity;
    return grossTotal - totalDiscount;
  }

  /// Updates the item with values provided by the user.
  /// Automatically handles gross/net price calculations and confidence flags.
  void updateFromUser({
    required String name,
    required String? weight,
    required double displayedPrice,
    required int quantity,
  }) {
    this.name = name;
    this.weight = weight;
    isLowConfidence = false;

    // The user sees and edits the effective price (price - discount).
    // We need to store the gross total price.
    final grossTotalPrice = displayedPrice + totalDiscount;

    this.quantity = quantity;
    totalPrice = grossTotalPrice;

    // Recalculate unit price based on the new total and quantity
    unitPrice = quantity > 0 ? grossTotalPrice / quantity : grossTotalPrice;
  }

  @override
  String toString() {
    return 'ScannedItem(name: $name, quantity: $quantity, '
        'totalPrice: $totalPrice, unitPrice: $unitPrice, weight: $weight, '
        'discounts: $discounts, isLowConfidence: $isLowConfidence, storeName: $storeName)';
  }

  factory ScannedItem.fromJson(Map<String, dynamic> json) {
    final discountsList = json['discounts'] as List<dynamic>?;
    return ScannedItem(
      name: json['name'] as String,
      quantity: (json['quantity'] as num? ?? 1).toInt(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      weight: json['weight'] as String?,
      discounts: discountsList
          ?.map((d) => Discount.fromJson(d as Map<String, dynamic>))
          .toList(),
      isLowConfidence: json['isLowConfidence'] as bool? ?? false,
      storeName: json['storeName'] as String?,
    );
  }
}
