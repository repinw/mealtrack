import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/features/calories/data/off_product_cache_repository.dart';
import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';
import 'package:mealtrack/features/calories/domain/off_product_candidate.dart';

void main() {
  group('OffProductCacheRepository', () {
    late FakeFirebaseFirestore firestore;
    late OffProductCacheRepository repository;
    const uid = 'user-1';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = OffProductCacheRepository(firestore: firestore, uid: uid);
    });

    test('getByBarcode returns null when document does not exist', () async {
      final result = await repository.getByBarcode('4001724819806');
      expect(result, isNull);
    });

    test('saveByBarcode persists candidates and metadata', () async {
      final candidate = _candidate(code: '4001724819806', name: 'Skyr');
      await repository.saveByBarcode('4001724819806', [candidate]);

      final snapshot = await firestore
          .collection(usersCollection)
          .doc(uid)
          .collection(offProductsCacheCollection)
          .doc('4001724819806')
          .get();

      expect(snapshot.exists, isTrue);
      expect(snapshot.data()!['barcode'], '4001724819806');
      expect(snapshot.data()!['source'], 'open_food_facts');
      expect(snapshot.data()!['updatedAt'], isA<Timestamp>());
      expect((snapshot.data()!['candidates'] as List), hasLength(1));
    });

    test('getByBarcode restores cached candidates', () async {
      final candidate = _candidate(code: '4001724819806', name: 'Skyr');
      await repository.saveByBarcode('4001724819806', [candidate]);

      final loaded = await repository.getByBarcode('4001724819806');

      expect(loaded, isNotNull);
      expect(loaded, hasLength(1));
      expect(loaded!.single.code, '4001724819806');
      expect(loaded.single.name, 'Skyr');
      expect(loaded.single.per100.kcal, 63);
      expect(loaded.single.hasCompleteCoreNutrition, isTrue);
    });

    test('saveByBarcode ignores empty input', () async {
      await repository.saveByBarcode('4001724819806', const []);
      final loaded = await repository.getByBarcode('4001724819806');
      expect(loaded, isNull);
    });
  });
}

OffProductCandidate _candidate({required String code, required String name}) {
  return OffProductCandidate(
    code: code,
    name: name,
    brand: 'Example',
    quantityLabel: '500 g',
    servingSizeLabel: '150 g',
    imageUrl: 'https://example.com/image.jpg',
    per100: const NutritionPer100(
      kcal: 63,
      protein: 11,
      carbs: 3.8,
      fat: 0.2,
      sugar: 3.8,
      salt: 0.12,
      saturatedFat: 0.1,
      polyunsaturatedFat: 0.0,
      fiber: 0.0,
    ),
    hasKcal: true,
    hasProtein: true,
    hasCarbs: true,
    hasFat: true,
    hasSugar: true,
    hasSalt: true,
    hasSaturatedFat: true,
    hasPolyunsaturatedFat: true,
    hasFiber: true,
    completenessScore: 1,
  );
}
