import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/fridge_item_repository.dart';
import 'package:mealtrack/features/inventory/provider/fridge_item_provider.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_controller.dart';

// A fake repository to capture saved items
class FakeFridgeItemRepository extends Fake implements FridgeItemRepository {
  List<FridgeItem>? savedItems;

  @override
  Future<void> saveItems(List<FridgeItem> items) async {
    savedItems = items;
  }
}

void main() {
  test('ReceiptEditController saves items correctly', () async {
    // 1. Setup the fake repository
    final fakeRepository = FakeFridgeItemRepository();

    // 2. Create a container with the overridden repository provider
    final container = ProviderContainer(
      overrides: [
        fridgeItemRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );

    final controller = container.read(receiptEditControllerProvider.notifier);

    // 3. Set up initial data
    final items = [
      ScannedItem(name: 'Milk', totalPrice: 1.50)..quantity = 1,
      ScannedItem(name: 'Bread', totalPrice: 2.00)..quantity = 2,
    ];
    controller.setItems(items);

    // Verify state update
    expect(container.read(receiptEditControllerProvider).items.length, 2);

    // 4. Perform the save action
    final success = await controller.saveItems('Supermarket');

    // 5. Assertions
    expect(success, isTrue);
    expect(fakeRepository.savedItems, isNotNull);
    expect(fakeRepository.savedItems!.length, 2);

    // Verify conversion logic implicitly (store name and item details)
    expect(fakeRepository.savedItems![0].storeName, 'Supermarket');
    expect(fakeRepository.savedItems![0].rawText, 'Milk');
    expect(fakeRepository.savedItems![1].rawText, 'Bread');
  });
}
