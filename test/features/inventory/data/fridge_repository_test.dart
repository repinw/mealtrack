import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/local_storage_service.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late FridgeRepository repository;
  late MockLocalStorageService mockLocalStorageService;

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    repository = FridgeRepository(localStorageService: mockLocalStorageService);
  });

  group('FridgeRepository', () {
    test('updateQuantity consumes item when quantity reaches 0', () async {
      // Arrange
      final item = FridgeItem.create(
        name: 'TestItem',
        storeName: 'TestStore',
        quantity: 1,
        unitPrice: 1.0,
      );
      final items = [item];

      when(
        () => mockLocalStorageService.loadItems(),
      ).thenAnswer((_) async => items);
      when(
        () => mockLocalStorageService.saveItems(any()),
      ).thenAnswer((_) async {});

      // Act
      // Reduce quantity by 1 (1 - 1 = 0)
      await repository.updateQuantity(item, -1);

      // Assert
      final captured = verify(
        () => mockLocalStorageService.saveItems(captureAny()),
      ).captured;
      final savedItems = captured.first as List<FridgeItem>;
      final updatedItem = savedItems.first;

      expect(updatedItem.quantity, 0);
      expect(updatedItem.isConsumed, true);
    });

    test(
      'updateQuantity unconscumes item when quantity increases from 0',
      () async {
        // Arrange
        final item = FridgeItem.create(
          name: 'TestItem',
          storeName: 'TestStore',
          quantity: 0,
          unitPrice: 1.0,
        ).copyWith(isConsumed: true, consumptionDate: DateTime.now());
        final items = [item];

        when(
          () => mockLocalStorageService.loadItems(),
        ).thenAnswer((_) async => items);
        when(
          () => mockLocalStorageService.saveItems(any()),
        ).thenAnswer((_) async {});

        // Act
        // Increase quantity by 1 (0 + 1 = 1)
        await repository.updateQuantity(item, 1);

        // Assert
        final captured = verify(
          () => mockLocalStorageService.saveItems(captureAny()),
        ).captured;
        final savedItems = captured.first as List<FridgeItem>;
        final updatedItem = savedItems.first;

        expect(updatedItem.quantity, 1);
        expect(updatedItem.isConsumed, false);
        expect(updatedItem.consumptionDate, null);
      },
    );
  });
}
