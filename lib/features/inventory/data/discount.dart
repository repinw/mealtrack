import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'discount.g.dart';

@HiveType(typeId: 2)
class Discount extends Equatable {
  const Discount({required this.name, required this.amount});

  @HiveField(0)
  final String name;

  @HiveField(1)
  final double amount;

  @override
  List<Object?> get props => [name, amount];
}
