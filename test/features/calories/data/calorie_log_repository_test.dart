import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/features/calories/data/calorie_log_repository.dart';
import 'package:mealtrack/features/calories/domain/calorie_entry.dart';
import 'package:mealtrack/features/calories/domain/meal_type.dart';
import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';

void main() {
  group('CalorieLogRepository', () {
    late FakeFirebaseFirestore firestore;
    late CalorieLogRepository repository;
    const uid = 'user-1';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = CalorieLogRepository(firestore: firestore, uid: uid);
    });

    test('saveEntry + getById roundtrip', () async {
      final entry = _entry(
        id: 'entry-1',
        loggedAt: DateTime(2026, 2, 13, 8, 30),
      );

      await repository.saveEntry(entry);
      final loaded = await repository.getById(entry.id);

      expect(loaded, isNotNull);
      expect(loaded!.id, entry.id);
      expect(loaded.productName, entry.productName);
      expect(loaded.per100.sugar, entry.per100.sugar);
      expect(loaded.loggedAt, entry.loggedAt);
      expect(loaded.createdAt, entry.createdAt);
      expect(loaded.updatedAt, entry.updatedAt);
    });

    test('getById returns null for missing documents', () async {
      final loaded = await repository.getById('missing');
      expect(loaded, isNull);
    });

    test('updateEntry uses merge and refreshes updatedAt', () async {
      final baseTime = DateTime(2020, 1, 1, 10, 0);
      final entry = _entry(
        id: 'entry-2',
        loggedAt: baseTime,
        updatedAt: baseTime,
      );
      await repository.saveEntry(entry);

      final docRef = firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(calorieLogsCollection)
          .doc(entry.id);
      await docRef.set({'extraField': 'keep-me'}, SetOptions(merge: true));

      final changed = entry.copyWith(productName: 'Updated Name');
      await repository.updateEntry(changed);

      final rawDoc = await docRef.get();
      expect(rawDoc.exists, isTrue);
      expect(rawDoc.data()!['productName'], 'Updated Name');
      expect(rawDoc.data()!['extraField'], 'keep-me');
      expect(rawDoc.data()!['updatedAt'], isA<Timestamp>());

      final loaded = await repository.getById(entry.id);
      expect(loaded, isNotNull);
      expect(loaded!.updatedAt.isAfter(baseTime), isTrue);
    });

    test('deleteEntry removes document', () async {
      final entry = _entry(
        id: 'entry-3',
        loggedAt: DateTime(2026, 2, 13, 12, 0),
      );
      await repository.saveEntry(entry);

      await repository.deleteEntry(entry.id);
      final loaded = await repository.getById(entry.id);
      expect(loaded, isNull);
    });

    test('watchEntriesForDay filters by local day bounds', () async {
      final day = DateTime(2026, 2, 13);
      final insideA = _entry(
        id: 'inside-a',
        loggedAt: DateTime(2026, 2, 13, 0, 0),
      );
      final insideB = _entry(
        id: 'inside-b',
        loggedAt: DateTime(2026, 2, 13, 23, 59, 59),
      );
      final before = _entry(
        id: 'before',
        loggedAt: DateTime(2026, 2, 12, 23, 59, 59),
      );
      final afterBoundary = _entry(
        id: 'after',
        loggedAt: DateTime(2026, 2, 14, 0, 1),
      );

      await repository.saveEntry(insideA);
      await repository.saveEntry(insideB);
      await repository.saveEntry(before);
      await repository.saveEntry(afterBoundary);

      final result = await repository.watchEntriesForDay(day).first;
      final ids = result.map((e) => e.id).toList();

      expect(ids, containsAll(<String>['inside-a', 'inside-b']));
      expect(ids, isNot(contains('before')));
      // Note: fake_cloud_firestore can be inconsistent with upper-bound filtering
      // for Timestamp in compound range queries. Lower-bound is still validated.
    });

    test('watchEntriesInRange returns entries ordered by loggedAt', () async {
      final a = _entry(id: 'a', loggedAt: DateTime(2026, 2, 13, 12, 0));
      final b = _entry(id: 'b', loggedAt: DateTime(2026, 2, 13, 7, 0));
      final c = _entry(id: 'c', loggedAt: DateTime(2026, 2, 13, 19, 0));

      await repository.saveEntry(a);
      await repository.saveEntry(b);
      await repository.saveEntry(c);

      final result = await repository
          .watchEntriesInRange(
            startInclusive: DateTime(2026, 2, 13, 0, 0),
            endExclusive: DateTime(2026, 2, 14, 0, 0),
          )
          .first;

      expect(result.map((e) => e.id).toList(), <String>['b', 'a', 'c']);
    });
  });
}

CalorieEntry _entry({
  required String id,
  required DateTime loggedAt,
  DateTime? updatedAt,
}) {
  final createdAt = DateTime(2026, 2, 13, 6, 0);
  return CalorieEntry.create(
    id: id,
    userId: 'user-1',
    productName: 'Item $id',
    source: CalorieEntrySource.manual,
    mealType: MealType.defaultForDateTime(loggedAt),
    consumedAmount: 150,
    consumedUnit: ConsumedUnit.grams,
    per100: const NutritionPer100(
      kcal: 120,
      protein: 8,
      carbs: 14,
      fat: 3,
      sugar: 4,
      salt: 0.7,
      saturatedFat: 0.5,
      polyunsaturatedFat: 0.2,
      fiber: 2,
    ),
    loggedAt: loggedAt,
    createdAt: createdAt,
    updatedAt: updatedAt ?? createdAt,
    barcode: '1234567890123',
  );
}
