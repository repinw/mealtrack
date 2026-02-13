import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/domain/meal_type.dart';

void main() {
  group('MealType', () {
    test('sectionOrder stays stable', () {
      expect(MealType.sectionOrder, <MealType>[
        MealType.breakfast,
        MealType.lunch,
        MealType.dinner,
        MealType.snack,
      ]);
    });

    test('fromHour maps boundaries correctly', () {
      expect(MealType.fromHour(4), MealType.snack);
      expect(MealType.fromHour(5), MealType.breakfast);
      expect(MealType.fromHour(10), MealType.breakfast);
      expect(MealType.fromHour(11), MealType.lunch);
      expect(MealType.fromHour(15), MealType.lunch);
      expect(MealType.fromHour(16), MealType.dinner);
      expect(MealType.fromHour(21), MealType.dinner);
      expect(MealType.fromHour(22), MealType.snack);
      expect(MealType.fromHour(0), MealType.snack);
      expect(MealType.fromHour(23), MealType.snack);
    });

    test('defaultForDateTime delegates to hour mapping', () {
      expect(
        MealType.defaultForDateTime(DateTime(2026, 2, 13, 9, 30)),
        MealType.breakfast,
      );
      expect(
        MealType.defaultForDateTime(DateTime(2026, 2, 13, 13, 0)),
        MealType.lunch,
      );
      expect(
        MealType.defaultForDateTime(DateTime(2026, 2, 13, 18, 0)),
        MealType.dinner,
      );
      expect(
        MealType.defaultForDateTime(DateTime(2026, 2, 13, 2, 0)),
        MealType.snack,
      );
    });
  });
}
