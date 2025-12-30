import 'package:flutter/foundation.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/core/models/fridge_item.dart';

class ReceiptEditController extends ChangeNotifier {
  final List<FridgeItem> _items = [];

  List<FridgeItem> get items => List.unmodifiable(_items);

  ReceiptEditController(List<FridgeItem>? scannedItems) {
    if (scannedItems != null) {
      _items.addAll(scannedItems);
    }
  }

  String get initialStoreName {
    try {
      return _items.firstWhere((item) => item.storeName.isNotEmpty).storeName;
    } catch (e) {
      return AppLocalizations.defaultStoreName;
    }
  }

  double get total {
    return _items.fold(
      0.0,
      (sum, item) => sum + item.unitPrice * item.quantity,
    );
  }

  int get totalQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  void updateMerchantName(String newName) {
    bool changed = false;
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].storeName != newName) {
        _items[i] = _items[i].copyWith(storeName: newName);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void deleteItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateItem(int index, FridgeItem newItem) {
    _items[index] = newItem;
    notifyListeners();
  }
}
