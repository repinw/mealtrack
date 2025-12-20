import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/inventory/provider/fridge_item_provider.dart';
import 'package:mealtrack/features/scanner/data/scanned_item.dart';
import 'package:mealtrack/features/scanner/domain/scanned_item_converter.dart';

class ReceiptEditState {
  final List<ScannedItem> items;
  final bool isSaving;

  ReceiptEditState({required this.items, this.isSaving = false});

  ReceiptEditState copyWith({List<ScannedItem>? items, bool? isSaving}) {
    return ReceiptEditState(
      items: items ?? this.items,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  double get total {
    return items.fold(0, (sum, item) {
      final discount = item.discounts.fold(0.0, (s, d) => s + d.amount);
      return sum + (item.totalPrice - discount);
    });
  }
}

class ReceiptEditController extends Notifier<ReceiptEditState> {
  @override
  ReceiptEditState build() {
    return ReceiptEditState(items: []);
  }

  void setItems(List<ScannedItem> items) {
    state = state.copyWith(items: items);
  }

  void updateMerchantName(String name) {
    for (var item in state.items) {
      item.storeName = name;
    }
    state = state.copyWith(items: [...state.items]);
  }

  void deleteItem(int index) {
    final items = [...state.items];
    items.removeAt(index);
    state = state.copyWith(items: items);
  }

  void notifyItemChanged() {
    state = state.copyWith(items: [...state.items]);
  }

  Future<bool> saveItems(String merchantName) async {
    if (state.items.isEmpty) return false;

    state = state.copyWith(isSaving: true);

    try {
      final fridgeItems = ScannedItemConverter.toFridgeItems(
        state.items,
        merchantName,
      );

      await ref.read(fridgeItemRepositoryProvider).saveItems(fridgeItems);
      return true;
    } catch (e) {
      return false;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

final receiptEditControllerProvider =
    NotifierProvider<ReceiptEditController, ReceiptEditState>(
      ReceiptEditController.new,
    );
