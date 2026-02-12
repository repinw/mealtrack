import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mealtrack/features/shoppinglist/domain/category_suggestion.dart';
import 'package:mealtrack/features/shoppinglist/domain/product_suggestion.dart';

part 'category_stats_repository.g.dart';

typedef ProductQuickSuggestion = ({
  String name,
  String category,
  double averagePrice,
  int count,
});

@riverpod
CategoryStatsRepository categoryStatsRepository(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final user = ref.watch(authStateChangesProvider).value;
  final userProfile = ref.watch(userProfileProvider).value;

  if (user == null) {
    throw Exception('User must be logged in to access category stats.');
  }

  final targetUid = userProfile?.householdId ?? user.uid;
  return CategoryStatsRepository(firestore, targetUid);
}

class CategoryStatsRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  CategoryStatsRepository(this._firestore, this._uid);

  CollectionReference<Map<String, dynamic>> get _collection => _firestore
      .collection(usersCollection)
      .doc(_uid)
      .collection(categoryStatsCollection);

  /// Atomically increment the consumption counter and accumulate price.
  /// Also stores [productName] within the category's products map.
  Future<void> increment(
    String? category,
    int delta, {
    double unitPrice = 0.0,
    String? productName,
  }) async {
    if (category == null || category.trim().isEmpty || delta == 0) return;

    final categoryName = category.trim();
    final docId = categoryName.toLowerCase();
    final docRef = _collection.doc(docId);

    final writeData = <String, dynamic>{
      'name': categoryName,
      'count': FieldValue.increment(delta),
    };
    if (delta > 0) {
      writeData['lastConsumedAt'] = FieldValue.serverTimestamp();
    }

    if (unitPrice > 0) {
      writeData['totalPrice'] = FieldValue.increment(unitPrice * delta);
      writeData['priceCount'] = FieldValue.increment(delta);
    }

    if (productName != null && productName.trim().isNotEmpty) {
      final normalizedProductName = productName.trim();
      final productKey = productName.trim().toLowerCase().replaceAll(
        RegExp(r'[./]'),
        '_',
      );
      final productData = <String, dynamic>{
        'name': normalizedProductName,
        'count': FieldValue.increment(delta),
      };
      if (delta > 0) {
        productData['lastConsumedAt'] = FieldValue.serverTimestamp();
      }
      if (unitPrice > 0) {
        productData['totalPrice'] = FieldValue.increment(unitPrice * delta);
        productData['priceCount'] = FieldValue.increment(delta);
      }
      writeData['products'] = {productKey: productData};
    }

    // Single atomic write avoids partial category/product updates.
    await docRef.set(writeData, SetOptions(merge: true));
  }

  /// Streams the top [limit] categories ordered by consumption count descending.
  Stream<List<CategorySuggestion>> watchTopCategories({int limit = 10}) {
    return _collection
        .orderBy('count', descending: true)
        .limit(limit * 3)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final ranked = snapshot.docs
              .map((doc) {
                final data = doc.data();
                final count = (data['count'] as num?)?.toInt() ?? 0;
                if (count <= 0) return null;

                final name = data['name'] as String? ?? doc.id;
                final totalPrice =
                    (data['totalPrice'] as num?)?.toDouble() ?? 0;
                final priceCount = (data['priceCount'] as num?)?.toInt() ?? 0;
                final avgPrice = priceCount > 0 ? totalPrice / priceCount : 0.0;

                final lastConsumedAt = _asDateTime(data['lastConsumedAt']);
                final daysSinceLast = lastConsumedAt == null
                    ? 365
                    : now.difference(lastConsumedAt).inDays;
                final recencyBoost = (30 - daysSinceLast).clamp(0, 30) / 10.0;

                return (
                  suggestion: CategorySuggestion(
                    name: name,
                    averagePrice: avgPrice,
                  ),
                  count: count,
                  score: count + recencyBoost,
                );
              })
              .whereType<
                ({CategorySuggestion suggestion, int count, double score})
              >()
              .toList();

          final frequent = ranked.where((item) => item.count >= 2).toList();
          final source = frequent.isNotEmpty ? frequent : ranked;
          source.sort((a, b) => b.score.compareTo(a.score));

          return source.take(limit).map((item) => item.suggestion).toList();
        });
  }

  /// Streams products for a given [category], sorted by consumption count.
  Stream<List<ProductSuggestion>> watchProductsForCategory(String category) {
    final docId = category.trim().toLowerCase();
    return _collection.doc(docId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return <ProductSuggestion>[];

      final products = data['products'] as Map<String, dynamic>? ?? {};
      final suggestions = products.entries.map((entry) {
        final product = entry.value as Map<String, dynamic>;
        final name = product['name'] as String? ?? entry.key;
        final count = (product['count'] as num?)?.toInt() ?? 0;
        final totalPrice = (product['totalPrice'] as num?)?.toDouble() ?? 0;
        final priceCount = (product['priceCount'] as num?)?.toInt() ?? 0;
        final avgPrice = priceCount > 0 ? totalPrice / priceCount : 0.0;
        return ProductSuggestion(
          name: name,
          averagePrice: avgPrice,
          count: count,
        );
      }).toList();

      // Sort by count descending
      suggestions.sort((a, b) => b.count.compareTo(a.count));
      return suggestions;
    });
  }

  /// Streams top products across all categories for quick-add suggestions.
  Stream<List<ProductQuickSuggestion>> watchTopProducts({int limit = 10}) {
    return _collection
        .orderBy('count', descending: true)
        .limit(limit * 3)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final byName =
              <String, ({ProductQuickSuggestion suggestion, double score})>{};

          for (final doc in snapshot.docs) {
            final categoryData = doc.data();
            final categoryName = categoryData['name'] as String? ?? doc.id;
            final categoryLastConsumed = _asDateTime(
              categoryData['lastConsumedAt'],
            );

            final products =
                categoryData['products'] as Map<String, dynamic>? ?? {};
            for (final entry in products.entries) {
              final productData = entry.value as Map<String, dynamic>;
              final count = (productData['count'] as num?)?.toInt() ?? 0;
              if (count <= 0) continue;

              final name = productData['name'] as String? ?? entry.key;
              final totalPrice =
                  (productData['totalPrice'] as num?)?.toDouble() ?? 0;
              final priceCount =
                  (productData['priceCount'] as num?)?.toInt() ?? 0;
              final avgPrice = priceCount > 0 ? totalPrice / priceCount : 0.0;

              final lastConsumed =
                  _asDateTime(productData['lastConsumedAt']) ??
                  categoryLastConsumed;
              final daysSinceLast = lastConsumed == null
                  ? 365
                  : now.difference(lastConsumed).inDays;
              final recencyBoost = (30 - daysSinceLast).clamp(0, 30) / 10.0;
              final score = count + recencyBoost;

              final suggestion = (
                name: name,
                category: categoryName,
                averagePrice: avgPrice,
                count: count,
              );
              final key = name.toLowerCase();
              final existing = byName[key];
              if (existing == null || score > existing.score) {
                byName[key] = (suggestion: suggestion, score: score);
              }
            }
          }

          final ranked = byName.values.toList()
            ..sort((a, b) => b.score.compareTo(a.score));

          final frequent = ranked
              .where((item) => item.suggestion.count >= 2)
              .toList();
          final source = frequent.isNotEmpty ? frequent : ranked;

          return source.take(limit).map((item) => item.suggestion).toList();
        });
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
