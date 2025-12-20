import 'dart:async';
import 'package:hive_ce/hive.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';
import 'package:mealtrack/features/hive/hive_adapters.dart';

class FridgeItemRepository {
  /// Initializes the repository.
  /// Should be called at the start of the app (e.g. in main.dart).
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(FridgeItemAdapter().typeId)) {
      Hive.registerAdapter(FridgeItemAdapter());
    }
    if (!Hive.isAdapterRegistered(DiscountAdapter().typeId)) {
      Hive.registerAdapter(DiscountAdapter());
    }
    await Hive.openBox<FridgeItem>(inventoryBoxName);
  }

  Future<void> saveItems(List<FridgeItem> items) async {
    await _box.addAll(items);
  }

  List<FridgeItem> getAllItems() {
    return _box.values.toList();
  }

  Future<void> deleteAllItems() async {
    await _box.clear();
  }

  Stream<List<FridgeItem>> watchItems() {
    late StreamController<List<FridgeItem>> controller;
    StreamSubscription? subscription;
    Timer? debounceTimer;

    controller = StreamController<List<FridgeItem>>(
      onListen: () {
        controller.add(getAllItems());

        subscription = _box.watch().listen((_) {
          debounceTimer?.cancel();
          debounceTimer = Timer(const Duration(milliseconds: 50), () {
            if (!controller.isClosed) {
              controller.add(getAllItems());
            }
          });
        });
      },
      onCancel: () {
        debounceTimer?.cancel();
        subscription?.cancel();
      },
    );

    return controller.stream;
  }

  Box<FridgeItem> get _box => Hive.box<FridgeItem>(inventoryBoxName);
}
