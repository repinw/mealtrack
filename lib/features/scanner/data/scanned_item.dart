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
