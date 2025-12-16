import 'package:equatable/equatable.dart';
import 'package:mealtrack/features/scanner/data/discount.dart';

/// Repräsentiert einen einzelnen Posten, der von einem Kassenbon gescannt wurde.
class ScannedItem extends Equatable {
  const ScannedItem({
    required this.name,
    this.quantity = 1,
    required this.totalPrice,
    this.unitPrice,
    this.weight,
    this.discounts = const [],
  });

  /// Der Name des Produkts.
  final String name;

  /// Die Menge (z.B. 2x). Standard ist 1.
  final int quantity;

  /// Der Gesamtpreis für diesen Posten (Menge * Einzelpreis).
  final double totalPrice;

  /// Der Einzelpreis, falls explizit angegeben.
  final double? unitPrice;

  /// Das extrahierte Gewicht oder Volumen (z.B. "500g").
  final String? weight;

  /// Eine Liste von Rabatten, die auf diesen Posten angewendet werden.
  final List<Discount> discounts;

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
      discounts:
          discountsList
              ?.map((d) => Discount.fromJson(d as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
