import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/user_profile.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/shoppinglist/data/category_stats_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockUser extends Mock implements User {}

void main() {
  group('CategoryStatsRepository', () {
    late FakeFirebaseFirestore firestore;
    late CategoryStatsRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = CategoryStatsRepository(firestore, 'uid-1');
    });

    test('increment no-ops for invalid category or zero delta', () async {
      await repository.increment(null, 1);
      await repository.increment('   ', 1);
      await repository.increment('Dairy', 0);

      final snapshot = await firestore
          .collection('users')
          .doc('uid-1')
          .collection('category_stats')
          .get();
      expect(snapshot.docs, isEmpty);
    });

    test(
      'increment writes category and product stats with price updates',
      () async {
        await repository.increment(
          'Dairy',
          2,
          unitPrice: 1.5,
          productName: 'Milk/1.5',
        );

        final doc = await firestore
            .collection('users')
            .doc('uid-1')
            .collection('category_stats')
            .doc('dairy')
            .get();

        final data = doc.data()!;
        expect(data['name'], 'Dairy');
        expect(data['count'], 2);
        expect(data['totalPrice'], 3.0);
        expect(data['priceCount'], 2);
        expect(data['products']['milk_1_5']['name'], 'Milk/1.5');
        expect(data['products']['milk_1_5']['count'], 2);
        expect(data['products']['milk_1_5']['totalPrice'], 3.0);
        expect(data['products']['milk_1_5']['priceCount'], 2);
        expect(data['lastConsumedAt'], isNotNull);
      },
    );

    test(
      'watchTopCategories filters non-positive and calculates average price',
      () async {
        await firestore
            .collection('users')
            .doc('uid-1')
            .collection('category_stats')
            .doc('dairy')
            .set({
              'name': 'Dairy',
              'count': 3,
              'totalPrice': 9.0,
              'priceCount': 3,
            });
        await firestore
            .collection('users')
            .doc('uid-1')
            .collection('category_stats')
            .doc('skip')
            .set({
              'name': 'Skip',
              'count': 0,
              'totalPrice': 10.0,
              'priceCount': 2,
            });

        final categories = await repository.watchTopCategories(limit: 10).first;
        expect(categories.length, 1);
        expect(categories.first.name, 'Dairy');
        expect(categories.first.averagePrice, 3.0);
      },
    );

    test('watchTopCategories boosts recent categories', () async {
      final old = DateTime.now().subtract(const Duration(days: 120));
      final recent = DateTime.now().subtract(const Duration(days: 1));

      await firestore
          .collection('users')
          .doc('uid-1')
          .collection('category_stats')
          .doc('bread')
          .set({
            'name': 'Brot',
            'count': 5,
            'lastConsumedAt': Timestamp.fromDate(old),
          });
      await firestore
          .collection('users')
          .doc('uid-1')
          .collection('category_stats')
          .doc('cucumber')
          .set({
            'name': 'Gurke',
            'count': 4,
            'lastConsumedAt': Timestamp.fromDate(recent),
          });

      final categories = await repository.watchTopCategories(limit: 2).first;
      expect(categories.map((c) => c.name).toList(), ['Gurke', 'Brot']);
    });

    test('watchProductsForCategory handles empty and sorts by count', () async {
      expect(
        await repository.watchProductsForCategory('missing').first,
        isEmpty,
      );

      await firestore
          .collection('users')
          .doc('uid-1')
          .collection('category_stats')
          .doc('dairy')
          .set({
            'products': {
              'milk': {
                'name': 'Milk',
                'count': 1,
                'totalPrice': 2.0,
                'priceCount': 1,
              },
              'yogurt': {
                'name': 'Yogurt',
                'count': 3,
                'totalPrice': 9.0,
                'priceCount': 3,
              },
            },
          });

      final products = await repository.watchProductsForCategory('Dairy').first;
      expect(products.map((p) => p.name).toList(), ['Yogurt', 'Milk']);
      expect(products.first.averagePrice, 3.0);
    });

    test(
      'increment keeps existing product entries when adding new ones',
      () async {
        await repository.increment(
          'Dairy',
          1,
          unitPrice: 1.5,
          productName: 'Milk',
        );
        await repository.increment(
          'Dairy',
          1,
          unitPrice: 2.0,
          productName: 'Yogurt',
        );

        final doc = await firestore
            .collection('users')
            .doc('uid-1')
            .collection('category_stats')
            .doc('dairy')
            .get();

        final products = (doc.data()!['products'] as Map<String, dynamic>);
        expect(products['milk']['name'], 'Milk');
        expect(products['milk']['count'], 1);
        expect(products['yogurt']['name'], 'Yogurt');
        expect(products['yogurt']['count'], 1);
        expect(doc.data()!['count'], 2);
      },
    );

    test('watchTopProducts deduplicates by name and ranks by score', () async {
      final old = DateTime.now().subtract(const Duration(days: 120));
      final recent = DateTime.now().subtract(const Duration(days: 1));

      await firestore
          .collection('users')
          .doc('uid-1')
          .collection('category_stats')
          .doc('dairy')
          .set({
            'name': 'Dairy',
            'count': 10,
            'lastConsumedAt': Timestamp.fromDate(old),
            'products': {
              'milk': {
                'name': 'Milk',
                'count': 2,
                'totalPrice': 3.0,
                'priceCount': 2,
                'lastConsumedAt': Timestamp.fromDate(old),
              },
            },
          });

      await firestore
          .collection('users')
          .doc('uid-1')
          .collection('category_stats')
          .doc('bakery')
          .set({
            'name': 'Bakery',
            'count': 8,
            'lastConsumedAt': Timestamp.fromDate(recent),
            'products': {
              'bread': {
                'name': 'Bread',
                'count': 4,
                'totalPrice': 8.0,
                'priceCount': 4,
                'lastConsumedAt': Timestamp.fromDate(recent),
              },
              'milk': {
                'name': 'Milk',
                'count': 3,
                'totalPrice': 6.0,
                'priceCount': 3,
                'lastConsumedAt': Timestamp.fromDate(recent),
              },
            },
          });

      final products = await repository.watchTopProducts(limit: 2).first;
      expect(products.length, 2);
      expect(products.map((p) => p.name).toList(), ['Bread', 'Milk']);

      final milk = products.where((p) => p.name == 'Milk').first;
      expect(milk.category, 'Bakery');
      expect(milk.averagePrice, 2.0);
      expect(milk.count, 3);
    });
  });

  group('categoryStatsRepositoryProvider', () {
    late FakeFirebaseFirestore firestore;
    late _MockUser user;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      user = _MockUser();
      when(() => user.uid).thenReturn('user-id');
    });

    test('uses household id when available', () async {
      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWith((ref) => firestore),
          authStateChangesProvider.overrideWith((ref) => Stream.value(user)),
          userProfileProvider.overrideWith(
            (ref) => Stream.value(
              const UserProfile(uid: 'user-id', householdId: 'household-1'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.listen(authStateChangesProvider, (_, _) {});
      await container.read(authStateChangesProvider.future);
      container.listen(userProfileProvider, (_, _) {});
      await container.read(userProfileProvider.future);

      final repo = container.read(categoryStatsRepositoryProvider);
      await repo.increment('Fruit', 1);

      final doc = await firestore
          .collection('users')
          .doc('household-1')
          .collection('category_stats')
          .doc('fruit')
          .get();
      expect(doc.exists, isTrue);
    });

    test('throws when user is unauthenticated', () {
      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWith((ref) => firestore),
          authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
          userProfileProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      container.listen(authStateChangesProvider, (_, _) {});

      expect(
        () => container.read(categoryStatsRepositoryProvider),
        throwsA(isA<Exception>()),
      );
    });
  });
}
