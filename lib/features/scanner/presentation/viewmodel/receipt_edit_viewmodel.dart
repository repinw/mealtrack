import 'package:mealtrack/core/l10n/l10n.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'receipt_edit_viewmodel.g.dart';

class ReceiptEditState {
  final List<FridgeItem> items;

  const ReceiptEditState({required this.items});

  String get initialStoreName {
    try {
      return items.firstWhere((item) => item.storeName.isNotEmpty).storeName;
    } catch (e) {
      return L10n.defaultStoreName;
    }
  }

  double get total {
    return items.fold(0.0, (sum, item) => sum + item.unitPrice * item.quantity);
  }

  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  ReceiptEditState copyWith({List<FridgeItem>? items}) {
    return ReceiptEditState(items: items ?? this.items);
  }
}

@riverpod
class ReceiptEditViewModel extends _$ReceiptEditViewModel {
  @override
  ReceiptEditState build() {
    final homeState = ref.read(scannerViewModelProvider);
    final items = homeState.value ?? [];
    return ReceiptEditState(items: items);
  }

  void updateMerchantName(String newName) {
    final updatedItems = state.items.map((item) {
      if (item.storeName != newName) {
        return item.copyWith(storeName: newName);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  void deleteItem(int index) {
    final updatedItems = List<FridgeItem>.from(state.items);
    updatedItems.removeAt(index);
    state = state.copyWith(items: updatedItems);
  }

  void updateItem(int index, FridgeItem newItem) {
    final updatedItems = List<FridgeItem>.from(state.items);
    updatedItems[index] = newItem;
    state = state.copyWith(items: updatedItems);
  }
}
