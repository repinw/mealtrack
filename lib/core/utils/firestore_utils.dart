import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUtils {
  static const int _batchSize = 500;

  static Future<void> processInBatches<T>(
    FirebaseFirestore firestore,
    List<T> items,
    void Function(WriteBatch batch, T item) action,
  ) async {
    for (var i = 0; i < items.length; i += _batchSize) {
      final batch = firestore.batch();
      final end = (i + _batchSize < items.length)
          ? i + _batchSize
          : items.length;
      final chunk = items.sublist(i, end);

      for (final item in chunk) {
        action(batch, item);
      }
      await batch.commit();
    }
  }
}
