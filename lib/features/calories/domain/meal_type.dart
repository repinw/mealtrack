enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  /// Stable display order for sections in the daily log.
  static const List<MealType> sectionOrder = [
    MealType.breakfast,
    MealType.lunch,
    MealType.dinner,
    MealType.snack,
  ];

  /// Default meal selection by local hour.
  /// 05:00-10:59 => breakfast
  /// 11:00-15:59 => lunch
  /// 16:00-21:59 => dinner
  /// otherwise   => snack
  static MealType fromHour(int hour) {
    if (hour >= 5 && hour < 11) return MealType.breakfast;
    if (hour >= 11 && hour < 16) return MealType.lunch;
    if (hour >= 16 && hour < 22) return MealType.dinner;
    return MealType.snack;
  }

  static MealType defaultForDateTime(DateTime dateTime) {
    return fromHour(dateTime.hour);
  }
}
