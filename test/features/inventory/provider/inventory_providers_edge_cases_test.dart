import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mocktail/mocktail.dart';
import '../../../shared/test_helpers.dart';

class MockFridgeRepository extends Mock implements FridgeRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockFridgeRepository mockRepository;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockRepository = MockFridgeRepository();
    mockSharedPreferences = MockSharedPreferences();

    when(
      () => mockRepository.watchItems(),
    ).thenAnswer((_) => Stream.value(<FridgeItem>[]));
    registerFallbackValue(<FridgeItem>[]);
    registerFallbackValue(
      createTestFridgeItem(name: 'fallback', storeName: 'fallback'),
    );

    when(() => mockSharedPreferences.getStringList(any())).thenReturn(null);
    when(
      () => mockSharedPreferences.setStringList(any(), any()),
    ).thenAnswer((_) async => true);
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        fridgeRepositoryProvider.overrideWithValue(mockRepository),
        sharedPreferencesProvider.overrideWith(
          (ref) => Future.value(mockSharedPreferences),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('CollapsedReceiptGroups Edge Cases', () {
    test('handles SharedPreferences write failure gracefully', () async {
      when(
        () => mockSharedPreferences.setStringList(any(), any()),
      ).thenThrow(Exception('Disk Full'));

      final container = makeContainer();
      container.listen(collapsedReceiptGroupsProvider, (_, _) {});
      await container.read(collapsedReceiptGroupsProvider.future);

      // Attempt to toggle
      await container
          .read(collapsedReceiptGroupsProvider.notifier)
          .toggle('receipt-1');

      // State should still be updated in memory even if persistence fails
      // (This verifies app doesn't crash and functionality remains for session)
      expect(
        container
            .read(collapsedReceiptGroupsProvider)
            .asData
            ?.value
            .contains('receipt-1'),
        isTrue,
      );
    });
  });

  group('Mixed Item States in archiveReceipt', () {
    final fixedDate = DateTime(2023, 1, 1);
    final activeItem = createTestFridgeItem(
      name: 'Active',
      storeName: 'S',
      receiptId: 'R1',
      now: () => fixedDate,
    );
    final archivedItem = createTestFridgeItem(
      name: 'Archived',
      storeName: 'S',
      receiptId: 'R1',
      now: () => fixedDate,
    ).copyWith(isArchived: true);

    test('archives all items idempotently', () async {
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([activeItem, archivedItem]));
      when(
        () => mockRepository.updateItemsBatch(any()),
      ).thenAnswer((_) async {});

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      container.listen(collapsedReceiptGroupsProvider, (_, _) {});

      await container.read(fridgeItemsProvider.future);
      await container.read(collapsedReceiptGroupsProvider.future);

      // Action
      container.read(fridgeItemsProvider.notifier).archiveReceipt('R1');
      await container.pump();

      final captured =
          verify(
                () => mockRepository.updateItemsBatch(captureAny()),
              ).captured.single
              as List<FridgeItem>;

      expect(captured.length, 2);
      expect(captured.every((i) => i.isArchived), isTrue);

      final items = container.read(fridgeItemsProvider).value!;
      expect(items.every((i) => i.isArchived), isTrue);
    });

    test('reverts state on Firestore permission-denied error', () async {
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([activeItem]));
      when(
        () => mockRepository.updateItemsBatch(any()),
      ).thenAnswer((_) async => throw Exception('permission-denied'));

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      container.listen(collapsedReceiptGroupsProvider, (_, _) {});

      await container.read(fridgeItemsProvider.future);
      await container.read(collapsedReceiptGroupsProvider.future);

      // Perform action
      container.read(fridgeItemsProvider.notifier).archiveReceipt('R1');
      await container.pump();

      // Verify Rollback
      final items = container.read(fridgeItemsProvider).value!;
      expect(items.first.isArchived, isFalse);

      // Verify Collapsed State Rollback
      expect(
        container
            .read(collapsedReceiptGroupsProvider)
            .asData
            ?.value
            .contains('R1'),
        isFalse,
      );
    });

    test('handles rapid toggle race conditions', () async {
      when(
        () => mockRepository.watchItems(),
      ).thenAnswer((_) => Stream.value([activeItem]));

      // Delays to simulate network latency
      when(() => mockRepository.updateItemsBatch(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
      });

      final container = makeContainer();
      container.listen(fridgeItemsProvider, (_, _) {});
      container.listen(collapsedReceiptGroupsProvider, (_, _) {});

      await container.read(fridgeItemsProvider.future);
      await container.read(collapsedReceiptGroupsProvider.future);

      // 1. Archive (Optimistic: Archived)
      container.read(fridgeItemsProvider.notifier).archiveReceipt('R1');

      // 2. Unarchive immediately (Optimistic: Active)
      container.read(fridgeItemsProvider.notifier).unarchiveReceipt('R1');

      await container.pump(); // Pump synchronous updates

      // Checks state immediately after sync updates
      final itemsImmediate = container.read(fridgeItemsProvider).value!;
      expect(itemsImmediate.first.isArchived, isFalse);

      // Wait for async operations
      await Future.delayed(const Duration(milliseconds: 100));
      await container.pump();

      // Final state should remain unarchived (Active)
      final itemsFinal = container.read(fridgeItemsProvider).value!;
      expect(itemsFinal.first.isArchived, isFalse);
    });
  });
}
