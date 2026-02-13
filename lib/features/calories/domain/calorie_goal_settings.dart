enum CalorieGoalSource {
  manual,
  profileAutoFuture;

  String get value => switch (this) {
    CalorieGoalSource.manual => 'manual',
    CalorieGoalSource.profileAutoFuture => 'profile_auto_future',
  };

  static CalorieGoalSource fromValue(String? value) {
    return switch (value) {
      'profile_auto_future' => CalorieGoalSource.profileAutoFuture,
      _ => CalorieGoalSource.manual,
    };
  }
}

class CalorieGoalSettings {
  final double? dailyKcalGoal;
  final CalorieGoalSource goalSource;
  final DateTime updatedAt;

  const CalorieGoalSettings({
    required this.dailyKcalGoal,
    required this.goalSource,
    required this.updatedAt,
  });

  factory CalorieGoalSettings.empty() {
    return CalorieGoalSettings(
      dailyKcalGoal: null,
      goalSource: CalorieGoalSource.manual,
      updatedAt: DateTime.now(),
    );
  }

  CalorieGoalSettings copyWith({
    double? dailyKcalGoal,
    bool clearGoal = false,
    CalorieGoalSource? goalSource,
    DateTime? updatedAt,
  }) {
    return CalorieGoalSettings(
      dailyKcalGoal: clearGoal ? null : (dailyKcalGoal ?? this.dailyKcalGoal),
      goalSource: goalSource ?? this.goalSource,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasGoal => dailyKcalGoal != null && dailyKcalGoal! > 0;

  bool get isValid =>
      dailyKcalGoal == null || (dailyKcalGoal!.isFinite && dailyKcalGoal! > 0);

  double? remainingKcal(double consumedKcal) {
    if (!hasGoal) return null;
    return (dailyKcalGoal! - consumedKcal).toDouble();
  }

  double? progress01(double consumedKcal) {
    if (!hasGoal) return null;
    if (dailyKcalGoal == 0) return 0;
    final value = consumedKcal / dailyKcalGoal!;
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyKcalGoal': dailyKcalGoal,
      'goalSource': goalSource.value,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CalorieGoalSettings.fromJson(Map<String, dynamic> json) {
    return CalorieGoalSettings(
      dailyKcalGoal: _toNullableDouble(json['dailyKcalGoal']),
      goalSource: CalorieGoalSource.fromValue(json['goalSource'] as String?),
      updatedAt: _toDateTime(json['updatedAt']),
    );
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value.replaceAll(',', '.');
      return double.tryParse(normalized);
    }
    return null;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
