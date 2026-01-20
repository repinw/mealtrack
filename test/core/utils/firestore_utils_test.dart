import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/utils/firestore_utils.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('FirestoreUtils', () {
    test('processInBatches should split items into batches of 500', () async {
      final items = List.generate(1001, (i) => i);
      int actionCount = 0;

      // We'll use a real collection to verify the commits
      final collection = fakeFirestore.collection('test_collection');

      await FirestoreUtils.processInBatches<int>(fakeFirestore, items, (
        batch,
        item,
      ) {
        actionCount++;
        batch.set(collection.doc('doc_$item'), {'val': item});
      });

      expect(actionCount, 1001);

      // Verify all items were committed
      final snapshot = await collection.get();
      expect(snapshot.size, 1001);
    });

    test('processInBatches with exactly 500 items', () async {
      final items = List.generate(500, (i) => i);
      int actionCount = 0;
      final collection = fakeFirestore.collection('batch_500');

      await FirestoreUtils.processInBatches<int>(fakeFirestore, items, (
        batch,
        item,
      ) {
        actionCount++;
        batch.set(collection.doc('doc_$item'), {'val': item});
      });

      expect(actionCount, 500);
      final snapshot = await collection.get();
      expect(snapshot.size, 500);
    });

    test('processInBatches with empty list', () async {
      final items = <int>[];
      int actionCount = 0;

      await FirestoreUtils.processInBatches<int>(fakeFirestore, items, (
        batch,
        item,
      ) {
        actionCount++;
      });

      expect(actionCount, 0);
    });
  });
}
