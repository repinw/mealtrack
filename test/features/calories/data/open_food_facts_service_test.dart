import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/calories/data/off_product_cache_repository.dart';
import 'package:mealtrack/features/calories/data/open_food_facts_service.dart';
import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';
import 'package:mealtrack/features/calories/domain/off_product_candidate.dart';

void main() {
  group('OpenFoodFactsService.lookupByBarcode', () {
    test('normalizes barcode before search', () async {
      String? capturedBarcode;
      final service = OpenFoodFactsService(
        searchByCodeOverride: (barcode) async {
          capturedBarcode = barcode;
          return const <OffProductCandidate>[];
        },
        fetchSingleProductOverride: (_) async => null,
      );

      await service.lookupByBarcode(' 40 017248-19806 ');

      expect(capturedBarcode, '4001724819806');
    });

    test('returns empty list for barcode without digits', () async {
      var searchCalled = false;
      var fetchCalled = false;
      final service = OpenFoodFactsService(
        searchByCodeOverride: (_) async {
          searchCalled = true;
          return const <OffProductCandidate>[];
        },
        fetchSingleProductOverride: (_) async {
          fetchCalled = true;
          return null;
        },
      );

      final result = await service.lookupByBarcode('---');

      expect(result, isEmpty);
      expect(searchCalled, isFalse);
      expect(fetchCalled, isFalse);
    });

    test('returns cached candidates and skips OFF lookup', () async {
      final cache = OffProductCacheRepository(
        firestore: FakeFirebaseFirestore(),
        uid: 'user-1',
      );
      await cache.saveByBarcode('4001724819806', [
        _candidate(code: '4001724819806', name: 'Cached Product', score: 1),
      ]);

      var searchCalled = false;
      var fetchCalled = false;
      final service = OpenFoodFactsService(
        cacheRepository: cache,
        searchByCodeOverride: (_) async {
          searchCalled = true;
          return const <OffProductCandidate>[];
        },
        fetchSingleProductOverride: (_) async {
          fetchCalled = true;
          return null;
        },
      );

      final result = await service.lookupByBarcode('4001724819806');

      expect(result, hasLength(1));
      expect(result.single.name, 'Cached Product');
      expect(searchCalled, isFalse);
      expect(fetchCalled, isFalse);
    });

    test('sorts by completeness desc and dedupes by code', () async {
      final service = OpenFoodFactsService(
        searchByCodeOverride: (_) async {
          return <OffProductCandidate>[
            _candidate(code: '111', name: 'Banana', score: 0.5),
            _candidate(code: '111', name: 'Banana Better', score: 0.9),
            _candidate(code: '222', name: 'Apple', score: 0.9),
            _candidate(code: '333', name: 'Carrot', score: 0.7),
          ];
        },
        fetchSingleProductOverride: (_) async => null,
      );

      final result = await service.lookupByBarcode('111');

      expect(result, hasLength(3));
      expect(result[0].code, '222');
      expect(result[1].code, '111');
      expect(result[2].code, '333');
      expect(result[1].name, 'Banana Better');
    });

    test(
      'falls back to single fetch when search returns no candidates',
      () async {
        var fetchCalled = false;
        final fallback = _candidate(code: '999', name: 'Fallback', score: 1);
        final service = OpenFoodFactsService(
          searchByCodeOverride: (_) async => const <OffProductCandidate>[],
          fetchSingleProductOverride: (_) async {
            fetchCalled = true;
            return fallback;
          },
        );

        final result = await service.lookupByBarcode('999');

        expect(fetchCalled, isTrue);
        expect(result, [fallback]);
      },
    );

    test('writes OFF results to cache after lookup', () async {
      final cache = OffProductCacheRepository(
        firestore: FakeFirebaseFirestore(),
        uid: 'user-1',
      );
      final candidate = _candidate(
        code: '999',
        name: 'Fetched Product',
        score: 1,
      );
      final service = OpenFoodFactsService(
        cacheRepository: cache,
        searchByCodeOverride: (_) async => [candidate],
        fetchSingleProductOverride: (_) async => null,
      );

      await service.lookupByBarcode('999');
      final cached = await cache.getByBarcode('999');

      expect(cached, isNotNull);
      expect(cached, hasLength(1));
      expect(cached!.single.name, 'Fetched Product');
    });

    test('wraps unexpected errors into OpenFoodFactsException', () async {
      final service = OpenFoodFactsService(
        searchByCodeOverride: (_) async => throw Exception('network down'),
        fetchSingleProductOverride: (_) async => null,
      );

      await expectLater(
        () => service.lookupByBarcode('4001724819806'),
        throwsA(
          isA<OpenFoodFactsException>().having(
            (e) => e.message,
            'message',
            'Open Food Facts lookup failed',
          ),
        ),
      );
    });

    test('rethrows OpenFoodFactsException without wrapping', () async {
      final service = OpenFoodFactsService(
        searchByCodeOverride: (_) async =>
            throw const OpenFoodFactsException('already normalized'),
        fetchSingleProductOverride: (_) async => null,
      );

      await expectLater(
        () => service.lookupByBarcode('4001724819806'),
        throwsA(
          isA<OpenFoodFactsException>().having(
            (e) => e.message,
            'message',
            'already normalized',
          ),
        ),
      );
    });
  });
}

OffProductCandidate _candidate({
  required String code,
  required String name,
  required double score,
}) {
  return OffProductCandidate(
    code: code,
    name: name,
    brand: null,
    quantityLabel: null,
    servingSizeLabel: null,
    imageUrl: null,
    per100: const NutritionPer100(
      kcal: 100,
      protein: 10,
      carbs: 20,
      fat: 5,
      sugar: 7,
      salt: 0.4,
      saturatedFat: null,
      polyunsaturatedFat: null,
      fiber: null,
    ),
    hasKcal: true,
    hasProtein: true,
    hasCarbs: true,
    hasFat: true,
    hasSugar: true,
    hasSalt: true,
    hasSaturatedFat: false,
    hasPolyunsaturatedFat: false,
    hasFiber: false,
    completenessScore: score,
  );
}
