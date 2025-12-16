import 'package:equatable/equatable.dart';

class Discount extends Equatable {
  const Discount({required this.name, required this.amount});

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
