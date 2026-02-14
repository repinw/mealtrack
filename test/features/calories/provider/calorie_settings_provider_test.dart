import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/data/calorie_settings_repository.dart';
import 'package:mealtrack/features/calories/domain/calorie_goal_settings.dart';
import 'package:mealtrack/features/calories/provider/calorie_log_provider.dart';
import 'package:mealtrack/features/calories/provider/calorie_settings_provider.dart';

void main() {
  group('calorieGoalProgress', () {
    test('returns no goal state when settings are empty', () {
      final container = ProviderContainer(
        overrides: [
          calorieGoalSettingsStream.overrideWithValue(
            AsyncValue.data(CalorieGoalSettings.empty()),
          ),
          calorieDaySummary.overrideWithValue(
            const CalorieDaySummary(
              totalKcal: 420,
              totalProtein: 30,
              totalCarbs: 40,
              totalFat: 10,
              entryCount: 3,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final progress = container.read(calorieGoalProgress);
      expect(progress.hasGoal, isFalse);
      expect(progress.consumedKcal, 420);
      expect(progress.remainingKcal, isNull);
      expect(progress.progress01, isNull);
    });

    test('computes remaining kcal and progress for an active goal', () {
      final container = ProviderContainer(
        overrides: [
          calorieGoalSettingsStream.overrideWithValue(
            AsyncValue.data(
              CalorieGoalSettings(
                dailyKcalGoal: 2000,
                goalSource: CalorieGoalSource.manual,
                updatedAt: DateTime(2026, 2, 13),
              ),
            ),
          ),
          calorieDaySummary.overrideWithValue(
            const CalorieDaySummary(
              totalKcal: 500,
              totalProtein: 0,
              totalCarbs: 0,
              totalFat: 0,
              entryCount: 1,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final progress = container.read(calorieGoalProgress);
      expect(progress.hasGoal, isTrue);
      expect(progress.consumedKcal, 500);
      expect(progress.remainingKcal, 1500);
      expect(progress.progress01, 0.25);
    });

    test('clamps progress to 1.0 when consumed exceeds goal', () {
      final container = ProviderContainer(
        overrides: [
          calorieGoalSettingsStream.overrideWithValue(
            AsyncValue.data(
              CalorieGoalSettings(
                dailyKcalGoal: 2000,
                goalSource: CalorieGoalSource.manual,
                updatedAt: DateTime(2026, 2, 13),
              ),
            ),
          ),
          calorieDaySummary.overrideWithValue(
            const CalorieDaySummary(
              totalKcal: 2600,
              totalProtein: 0,
              totalCarbs: 0,
              totalFat: 0,
              entryCount: 2,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final progress = container.read(calorieGoalProgress);
      expect(progress.progress01, 1);
      expect(progress.remainingKcal, -600);
    });
  });

  group('calorieGoalMutations', () {
    test('delegates set and clear calls to repository', () async {
      final repository = _SpyCalorieSettingsRepository();
      final container = ProviderContainer(
        overrides: [calorieSettingsRepository.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final mutations = container.read(calorieGoalMutations);
      await mutations.setDailyGoal(1800);
      await mutations.clearGoal();

      expect(repository.lastSetGoal, 1800);
      expect(repository.clearGoalCalls, 1);
    });
  });
}

class _SpyCalorieSettingsRepository extends CalorieSettingsRepository {
  _SpyCalorieSettingsRepository()
    : super(firestore: FakeFirebaseFirestore(), uid: 'test-user');

  double? lastSetGoal;
  int clearGoalCalls = 0;

  @override
  Future<void> setDailyKcalGoal(double kcalGoal) async {
    lastSetGoal = kcalGoal;
  }

  @override
  Future<void> clearGoal() async {
    clearGoalCalls += 1;
  }
}
