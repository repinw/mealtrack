import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/domain/calorie_goal_settings.dart';

void main() {
  group('CalorieGoalSource', () {
    test('value mapping and fallback', () {
      expect(CalorieGoalSource.manual.value, 'manual');
      expect(CalorieGoalSource.profileAutoFuture.value, 'profile_auto_future');
      expect(
        CalorieGoalSource.fromValue('profile_auto_future'),
        CalorieGoalSource.profileAutoFuture,
      );
      expect(CalorieGoalSource.fromValue('x'), CalorieGoalSource.manual);
    });
  });

  group('CalorieGoalSettings', () {
    test('empty settings have no goal and are valid', () {
      final settings = CalorieGoalSettings.empty();
      expect(settings.hasGoal, isFalse);
      expect(settings.isValid, isTrue);
      expect(settings.dailyKcalGoal, isNull);
    });

    test('hasGoal and isValid depend on dailyKcalGoal', () {
      final valid = CalorieGoalSettings(
        dailyKcalGoal: 2000,
        goalSource: CalorieGoalSource.manual,
        updatedAt: DateTime(2026, 2, 13),
      );
      final invalid = valid.copyWith(dailyKcalGoal: -10);

      expect(valid.hasGoal, isTrue);
      expect(valid.isValid, isTrue);
      expect(invalid.hasGoal, isFalse);
      expect(invalid.isValid, isFalse);
    });

    test('copyWith can clear goal', () {
      final settings = CalorieGoalSettings(
        dailyKcalGoal: 1800,
        goalSource: CalorieGoalSource.manual,
        updatedAt: DateTime(2026, 2, 13, 8, 0),
      );

      final cleared = settings.copyWith(
        clearGoal: true,
        updatedAt: DateTime(2026, 2, 13, 9, 0),
      );

      expect(cleared.dailyKcalGoal, isNull);
      expect(cleared.hasGoal, isFalse);
      expect(cleared.updatedAt, DateTime(2026, 2, 13, 9, 0));
    });

    test('remainingKcal and progress01 calculations', () {
      final settings = CalorieGoalSettings(
        dailyKcalGoal: 2000,
        goalSource: CalorieGoalSource.manual,
        updatedAt: DateTime(2026, 2, 13),
      );

      expect(settings.remainingKcal(500), 1500);
      expect(settings.remainingKcal(2300), -300);
      expect(settings.progress01(500), 0.25);
      expect(settings.progress01(2300), 1);
      expect(settings.progress01(-200), 0);
    });

    test('remainingKcal and progress01 return null without goal', () {
      final settings = CalorieGoalSettings(
        dailyKcalGoal: null,
        goalSource: CalorieGoalSource.manual,
        updatedAt: DateTime(2026, 2, 13),
      );

      expect(settings.remainingKcal(300), isNull);
      expect(settings.progress01(300), isNull);
    });

    test('toJson and fromJson roundtrip including comma parsing', () {
      final settings = CalorieGoalSettings(
        dailyKcalGoal: 1950.5,
        goalSource: CalorieGoalSource.profileAutoFuture,
        updatedAt: DateTime(2026, 2, 13, 9, 30),
      );

      final json = settings.toJson();
      final restored = CalorieGoalSettings.fromJson(json);

      expect(restored.dailyKcalGoal, 1950.5);
      expect(restored.goalSource, CalorieGoalSource.profileAutoFuture);
      expect(restored.updatedAt, DateTime(2026, 2, 13, 9, 30));

      final parsedComma = CalorieGoalSettings.fromJson({
        'dailyKcalGoal': '2100,4',
        'goalSource': 'manual',
        'updatedAt': '2026-02-13T10:00:00.000',
      });
      expect(parsedComma.dailyKcalGoal, 2100.4);
      expect(parsedComma.goalSource, CalorieGoalSource.manual);
    });
  });
}
