import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'discount.g.dart';

@HiveType(typeId: 2)
class Discount extends Equatable {
  Discount({required this.name, required this.amount}) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'darf nicht leer sein');
    }
    if (amount < 0) {
      throw ArgumentError.value(amount, 'amount', 'darf nicht negativ sein');
    }
  }

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  @HiveField(0)
  final String name;

  @HiveField(1)
  final double amount;

  @override
  List<Object?> get props => [name, amount];
}
