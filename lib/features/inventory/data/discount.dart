import 'package:equatable/equatable.dart';

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

  final String name;

  final double amount;

  @override
  List<Object?> get props => [name, amount];
}
