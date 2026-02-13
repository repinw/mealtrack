import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/calories/data/calorie_log_repository.dart';
import 'package:mealtrack/features/calories/domain/calorie_entry.dart';
import 'package:mealtrack/features/calories/domain/meal_type.dart';

class CalorieDaySelection extends Notifier<DateTime> {
  @override
  DateTime build() {
    return _normalize(DateTime.now());
  }

  void setDay(DateTime day) {
    state = _normalize(day);
  }

  void nextDay() {
    state = state.add(const Duration(days: 1));
  }

  void previousDay() {
    state = state.subtract(const Duration(days: 1));
  }

  static DateTime _normalize(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

class CalorieDaySummary {
  final double totalKcal;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int entryCount;

  const CalorieDaySummary({
    required this.totalKcal,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.entryCount,
  });

  static const empty = CalorieDaySummary(
    totalKcal: 0,
    totalProtein: 0,
    totalCarbs: 0,
    totalFat: 0,
    entryCount: 0,
  );
}

class CalorieLogMutations {
  final CalorieLogRepository _repository;

  const CalorieLogMutations(this._repository);

  Future<void> save(CalorieEntry entry) {
    return _repository.saveEntry(entry);
  }

  Future<void> update(CalorieEntry entry) {
    return _repository.updateEntry(entry);
  }

  Future<void> delete(String entryId) {
    return _repository.deleteEntry(entryId);
  }
}

final calorieDaySelection = NotifierProvider<CalorieDaySelection, DateTime>(
  CalorieDaySelection.new,
);

final calorieEntriesForSelectedDay = StreamProvider<List<CalorieEntry>>((ref) {
  final day = ref.watch(calorieDaySelection);
  final repository = ref.watch(calorieLogRepository);
  return repository.watchEntriesForDay(day);
});

final calorieEntriesByMeal = Provider<Map<MealType, List<CalorieEntry>>>((ref) {
  final entries =
      ref.watch(calorieEntriesForSelectedDay).value ?? const <CalorieEntry>[];
  final grouped = <MealType, List<CalorieEntry>>{
    for (final meal in MealType.sectionOrder) meal: <CalorieEntry>[],
  };

  for (final entry in entries) {
    final bucket = grouped[entry.mealType];
    if (bucket != null) {
      bucket.add(entry);
    } else {
      grouped[entry.mealType] = [entry];
    }
  }

  return grouped;
});

final calorieDaySummary = Provider<CalorieDaySummary>((ref) {
  final entries = ref.watch(calorieEntriesForSelectedDay).value;
  if (entries == null) {
    return CalorieDaySummary.empty;
  }

  final totalKcal = entries.fold<double>(
    0,
    (sum, item) => sum + item.totalKcal,
  );
  final totalProtein = entries.fold<double>(
    0,
    (sum, item) => sum + item.totalProtein,
  );
  final totalCarbs = entries.fold<double>(
    0,
    (sum, item) => sum + item.totalCarbs,
  );
  final totalFat = entries.fold<double>(0, (sum, item) => sum + item.totalFat);

  return CalorieDaySummary(
    totalKcal: totalKcal,
    totalProtein: totalProtein,
    totalCarbs: totalCarbs,
    totalFat: totalFat,
    entryCount: entries.length,
  );
});

final calorieLogMutations = Provider<CalorieLogMutations>((ref) {
  final repository = ref.watch(calorieLogRepository);
  return CalorieLogMutations(repository);
});
