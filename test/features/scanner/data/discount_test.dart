import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/data/discount.dart';

void main() {
  test('create Discount', () {
    final String name = "discountItem";
    double amount = 3.33;

    final item = Discount(name: name, amount: amount);

    expect(item.name, name);
    expect(item.amount, amount);
  });

  test('create Discount from Json Factory', () {
    final String name = "discountItem";
    double amount = 3.33;

    Map<String, dynamic> json = {"name": name, "amount": amount};

    final item = Discount.fromJson(json);

    expect(item.name, name);
    expect(item.amount, amount);
  });

  test('props are correct', () {
    final item = Discount(name: 'Rabatt', amount: 100);

    expect(item.props, equals(['Rabatt', 100]));
  });

  test('supports value equality', () {
    final item1 = Discount(name: 'Rabatt 15%', amount: 500);
    final item2 = Discount(name: 'Rabatt 15%', amount: 500);

    expect(item1, equals(item2));
  });
}
