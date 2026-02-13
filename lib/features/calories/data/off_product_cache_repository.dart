import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/calories/domain/off_product_candidate.dart';

final offProductCacheRepository = Provider<OffProductCacheRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final user = ref.watch(authStateChangesProvider).value;

  if (user == null) {
    throw Exception('User must be logged in to access product cache.');
  }

  return OffProductCacheRepository(firestore: firestore, uid: user.uid);
});

class OffProductCacheRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  const OffProductCacheRepository({
    required FirebaseFirestore firestore,
    required String uid,
  }) : _firestore = firestore,
       _uid = uid;

  CollectionReference<Map<String, dynamic>> get _collection => _firestore
      .collection(usersCollection)
      .doc(_uid)
      .collection(offProductsCacheCollection);

  Future<List<OffProductCandidate>?> getByBarcode(String barcode) async {
    final normalizedBarcode = barcode.trim();
    if (normalizedBarcode.isEmpty) return null;

    final snapshot = await _collection.doc(normalizedBarcode).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) return null;

    final rawCandidates = data['candidates'];
    if (rawCandidates is! List) return null;

    final parsed = <OffProductCandidate>[];
    for (final item in rawCandidates) {
      if (item is! Map) continue;
      final candidateJson = Map<String, dynamic>.from(item);
      parsed.add(OffProductCandidate.fromJson(candidateJson));
    }

    if (parsed.isEmpty) return null;
    return parsed;
  }

  Future<void> saveByBarcode(
    String barcode,
    List<OffProductCandidate> candidates,
  ) async {
    final normalizedBarcode = barcode.trim();
    if (normalizedBarcode.isEmpty || candidates.isEmpty) return;

    await _collection.doc(normalizedBarcode).set({
      'barcode': normalizedBarcode,
      'candidates': candidates.map((candidate) => candidate.toJson()).toList(),
      'source': 'open_food_facts',
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
