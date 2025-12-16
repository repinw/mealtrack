import 'package:equatable/equatable.dart';

class ScannedItem extends Equatable {
  const ScannedItem({
    required this.name,
    this.quantity = 1,
    required this.totalPrice,
    this.unitPrice,
    this.weight,
    this.discounts = const {},
  });

  final String name;

  final int quantity;

  final double totalPrice;

  final double? unitPrice;

  final String? weight;

  final Map<String, double> discounts;

  @override
  List<Object?> get props => [
    name,
    quantity,
    totalPrice,
    unitPrice,
    weight,
    discounts,
  ];

  @override
  String toString() {
    return 'ScannedItem(name: $name, quantity: $quantity, '
        'totalPrice: $totalPrice, unitPrice: $unitPrice, weight: $weight, '
        'discounts: $discounts)';
  }

  factory ScannedItem.fromJson(Map<String, dynamic> json) {
    final discountsList = json['discounts'] as List<dynamic>?;
    return ScannedItem(
      name: json['name'] as String,
      quantity: (json['quantity'] as num? ?? 1).toInt(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      weight: json['weight'] as String?,
      discounts: discountsList != null
          ? {
              for (var item in discountsList)
                item['name'] as String: (item['amount'] as num).toDouble(),
            }
          : const {},
    );
  }
}
