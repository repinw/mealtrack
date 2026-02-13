import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/calories/domain/calorie_goal_settings.dart';

const _calorieSettingsDefaultDocId = 'default';

final calorieSettingsRepository = Provider<CalorieSettingsRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final user = ref.watch(authStateChangesProvider).value;

  if (user == null) {
    throw Exception('User must be logged in to access calorie settings.');
  }

  return CalorieSettingsRepository(firestore: firestore, uid: user.uid);
});

class CalorieSettingsRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  const CalorieSettingsRepository({
    required FirebaseFirestore firestore,
    required String uid,
  }) : _firestore = firestore,
       _uid = uid;

  CollectionReference<Map<String, dynamic>> get _collection => _firestore
      .collection(usersCollection)
      .doc(_uid)
      .collection(calorieSettingsCollection);

  DocumentReference<Map<String, dynamic>> get _defaultDoc =>
      _collection.doc(_calorieSettingsDefaultDocId);

  Stream<CalorieGoalSettings> watchSettings() {
    return _defaultDoc.snapshots().map((snapshot) {
      if (!snapshot.exists) return CalorieGoalSettings.empty();
      final data = snapshot.data();
      if (data == null) return CalorieGoalSettings.empty();
      return _fromFirestoreJson(data);
    });
  }

  Future<CalorieGoalSettings> getSettings() async {
    final snapshot = await _defaultDoc.get();
    if (!snapshot.exists) return CalorieGoalSettings.empty();
    final data = snapshot.data();
    if (data == null) return CalorieGoalSettings.empty();
    return _fromFirestoreJson(data);
  }

  Future<void> saveSettings(CalorieGoalSettings settings) async {
    await _defaultDoc.set(
      _toFirestoreJson(settings.copyWith(updatedAt: DateTime.now())),
      SetOptions(merge: true),
    );
  }

  Future<void> setDailyKcalGoal(double kcalGoal) async {
    final current = await getSettings();
    final updated = current.copyWith(
      dailyKcalGoal: kcalGoal,
      goalSource: CalorieGoalSource.manual,
      updatedAt: DateTime.now(),
    );
    await saveSettings(updated);
  }

  Future<void> clearGoal() async {
    final current = await getSettings();
    final updated = current.copyWith(
      clearGoal: true,
      updatedAt: DateTime.now(),
    );
    await saveSettings(updated);
  }

  Map<String, dynamic> _toFirestoreJson(CalorieGoalSettings settings) {
    final json = settings.toJson();
    json['updatedAt'] = Timestamp.fromDate(settings.updatedAt);
    return json;
  }

  CalorieGoalSettings _fromFirestoreJson(Map<String, dynamic> raw) {
    final json = Map<String, dynamic>.from(raw);
    json['updatedAt'] = _timestampToDateTime(json['updatedAt']);
    return CalorieGoalSettings.fromJson(json);
  }

  static DateTime _timestampToDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
