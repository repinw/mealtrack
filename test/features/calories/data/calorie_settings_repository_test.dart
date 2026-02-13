import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/features/calories/data/calorie_settings_repository.dart';
import 'package:mealtrack/features/calories/domain/calorie_goal_settings.dart';

void main() {
  group('CalorieSettingsRepository', () {
    late FakeFirebaseFirestore firestore;
    late CalorieSettingsRepository repository;
    const uid = 'user-1';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = CalorieSettingsRepository(firestore: firestore, uid: uid);
    });

    test('getSettings returns empty when settings do not exist', () async {
      final settings = await repository.getSettings();
      expect(settings.hasGoal, isFalse);
      expect(settings.dailyKcalGoal, isNull);
      expect(settings.goalSource, CalorieGoalSource.manual);
    });

    test('saveSettings persists and getSettings restores values', () async {
      final toSave = CalorieGoalSettings(
        dailyKcalGoal: 2100,
        goalSource: CalorieGoalSource.manual,
        updatedAt: DateTime(2026, 2, 13, 9, 0),
      );

      await repository.saveSettings(toSave);
      final loaded = await repository.getSettings();

      expect(loaded.dailyKcalGoal, 2100);
      expect(loaded.goalSource, CalorieGoalSource.manual);
      expect(loaded.updatedAt.isAfter(DateTime(2026, 2, 13, 8, 59)), isTrue);

      final rawDoc = await firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(calorieSettingsCollection)
          .doc('default')
          .get();
      expect(rawDoc.exists, isTrue);
      expect(rawDoc.data()!['updatedAt'], isA<Timestamp>());
    });

    test('setDailyKcalGoal stores manual goal', () async {
      await repository.setDailyKcalGoal(1850);
      final loaded = await repository.getSettings();

      expect(loaded.hasGoal, isTrue);
      expect(loaded.dailyKcalGoal, 1850);
      expect(loaded.goalSource, CalorieGoalSource.manual);
      expect(loaded.isValid, isTrue);
    });

    test('clearGoal removes existing goal', () async {
      await repository.setDailyKcalGoal(2000);
      await repository.clearGoal();

      final loaded = await repository.getSettings();
      expect(loaded.hasGoal, isFalse);
      expect(loaded.dailyKcalGoal, isNull);
      expect(loaded.goalSource, CalorieGoalSource.manual);
    });

    test('watchSettings emits updated values', () async {
      final goalReached = expectLater(
        repository.watchSettings(),
        emitsThrough(
          predicate<CalorieGoalSettings>(
            (s) =>
                s.dailyKcalGoal == 1700 &&
                s.goalSource == CalorieGoalSource.manual,
          ),
        ),
      );

      await repository.setDailyKcalGoal(1700);
      await goalReached;
    });
  });
}
