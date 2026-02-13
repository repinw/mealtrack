import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/calories/data/calorie_settings_repository.dart';
import 'package:mealtrack/features/calories/domain/calorie_goal_settings.dart';
import 'package:mealtrack/features/calories/provider/calorie_log_provider.dart';

class CalorieGoalMutations {
  final CalorieSettingsRepository _repository;

  const CalorieGoalMutations(this._repository);

  Future<void> setDailyGoal(double kcalGoal) {
    return _repository.setDailyKcalGoal(kcalGoal);
  }

  Future<void> clearGoal() {
    return _repository.clearGoal();
  }
}

class CalorieGoalProgress {
  final CalorieGoalSettings settings;
  final double consumedKcal;
  final double? remainingKcal;
  final double? progress01;

  const CalorieGoalProgress({
    required this.settings,
    required this.consumedKcal,
    required this.remainingKcal,
    required this.progress01,
  });

  bool get hasGoal => settings.hasGoal;
}

final calorieGoalSettingsStream = StreamProvider<CalorieGoalSettings>((ref) {
  final repository = ref.watch(calorieSettingsRepository);
  return repository.watchSettings();
});

final calorieGoalMutations = Provider<CalorieGoalMutations>((ref) {
  final repository = ref.watch(calorieSettingsRepository);
  return CalorieGoalMutations(repository);
});

final calorieGoalProgress = Provider<CalorieGoalProgress>((ref) {
  final settings =
      ref.watch(calorieGoalSettingsStream).value ?? CalorieGoalSettings.empty();
  final consumedKcal = ref.watch(calorieDaySummary).totalKcal;

  return CalorieGoalProgress(
    settings: settings,
    consumedKcal: consumedKcal,
    remainingKcal: settings.remainingKcal(consumedKcal),
    progress01: settings.progress01(consumedKcal),
  );
});
