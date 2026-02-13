import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/calories/domain/calorie_entry.dart';

final calorieLogRepository = Provider<CalorieLogRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final user = ref.watch(authStateChangesProvider).value;

  if (user == null) {
    throw Exception('User must be logged in to access calorie logs.');
  }

  return CalorieLogRepository(firestore: firestore, uid: user.uid);
});

class CalorieLogRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  CalorieLogRepository({
    required FirebaseFirestore firestore,
    required String uid,
  }) : _firestore = firestore,
       _uid = uid;

  CollectionReference<Map<String, dynamic>> get _collection => _firestore
      .collection(usersCollection)
      .doc(_uid)
      .collection(calorieLogsCollection);

  Stream<List<CalorieEntry>> watchEntriesForDay(DateTime day) {
    final bounds = _dayBoundsLocal(day);
    return watchEntriesInRange(
      startInclusive: bounds.startInclusive,
      endExclusive: bounds.endExclusive,
    );
  }

  Stream<List<CalorieEntry>> watchEntriesInRange({
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) {
    return _collection
        .where(
          'loggedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startInclusive),
          isLessThan: Timestamp.fromDate(endExclusive),
        )
        .orderBy('loggedAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _fromFirestoreJson(doc.data()))
              .toList(),
        );
  }

  Future<void> saveEntry(CalorieEntry entry) async {
    await _collection.doc(entry.id).set(_toFirestoreJson(entry));
  }

  Future<void> updateEntry(CalorieEntry entry) async {
    await _collection
        .doc(entry.id)
        .set(
          _toFirestoreJson(entry.copyWith(updatedAt: DateTime.now())),
          SetOptions(merge: true),
        );
  }

  Future<void> deleteEntry(String entryId) async {
    await _collection.doc(entryId).delete();
  }

  Future<CalorieEntry?> getById(String entryId) async {
    final doc = await _collection.doc(entryId).get();
    if (!doc.exists) return null;
    return _fromFirestoreJson(doc.data()!);
  }

  Map<String, dynamic> _toFirestoreJson(CalorieEntry entry) {
    final json = entry.toJson();
    json['loggedAt'] = Timestamp.fromDate(entry.loggedAt);
    json['createdAt'] = Timestamp.fromDate(entry.createdAt);
    json['updatedAt'] = Timestamp.fromDate(entry.updatedAt);
    return json;
  }

  CalorieEntry _fromFirestoreJson(Map<String, dynamic> raw) {
    final json = Map<String, dynamic>.from(raw);
    json['loggedAt'] = _timestampToDateTime(json['loggedAt']);
    json['createdAt'] = _timestampToDateTime(json['createdAt']);
    json['updatedAt'] = _timestampToDateTime(json['updatedAt']);
    return CalorieEntry.fromJson(json);
  }

  static DateTime _timestampToDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static ({DateTime startInclusive, DateTime endExclusive}) _dayBoundsLocal(
    DateTime date,
  ) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (startInclusive: start, endExclusive: end);
  }
}
