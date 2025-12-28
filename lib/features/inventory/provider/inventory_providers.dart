import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';

part 'inventory_providers.g.dart';

@riverpod
class FridgeItems extends _$FridgeItems {
  @override
  Future<List<FridgeItem>> build() async {
    final repository = ref.watch(fridgeRepositoryProvider);
    return repository.getItems();
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(fridgeRepositoryProvider);
      return repository.getItems();
    });
  }

  Future<void> addItems(List<FridgeItem> items) async {
    final repository = ref.read(fridgeRepositoryProvider);
    await repository.addItems(items);
    ref.invalidateSelf();
  }

  Future<void> updateItem(FridgeItem item) async {
    final repository = ref.read(fridgeRepositoryProvider);
    await repository.updateItem(item);
    ref.invalidateSelf();
  }

  Future<void> updateQuantity(FridgeItem item, int delta) async {
    // FIX: Statt state.valueOrNull nutzen wir state.asData?.value
    // Das prüft: "Haben wir Daten?" -> Wenn ja, gib mir den Wert.
    final previousList = state.asData?.value;

    // Wenn die Liste noch lädt oder null ist, brechen wir ab
    if (previousList == null) return;

    final newQuantity = item.quantity + delta;

    // Optimistic Update: Neue Liste erstellen
    final updatedList = [
      for (final i in previousList)
        if (i.id == item.id) i.copyWith(quantity: newQuantity) else i,
    ];

    // State sofort aktualisieren (ohne Loading Screen)
    state = AsyncValue.data(updatedList);

    // DB Update im Hintergrund
    try {
      final repository = ref.read(fridgeRepositoryProvider);
      await repository.updateQuantity(item, delta);
    } catch (e, st) {
      // Falls DB fehlschlägt: Fehler anzeigen und alten State wiederherstellen
      // oder Liste neu laden.
      state = AsyncValue.error(e, st);
      // Optional: ref.invalidateSelf(); um die echten Daten neu zu laden
    }
  }

  Future<void> deleteAll() async {
    final repository = ref.read(fridgeRepositoryProvider);
    await repository.deleteAllItems();
    ref.invalidateSelf();
  }

  Future<void> deleteItem(String id) async {
    final repository = ref.read(fridgeRepositoryProvider);
    await repository.deleteItem(id);
    ref.invalidateSelf();
  }
}

@riverpod
class InventoryFilter extends _$InventoryFilter {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

@riverpod
Future<List<FridgeItem>> availableFridgeItems(Ref ref) async {
  final items = await ref.watch(fridgeItemsProvider.future);
  return items.where((item) => item.quantity > 0).toList();
}

@riverpod
Future<List<MapEntry<String, List<FridgeItem>>>> groupedFridgeItems(
  Ref ref,
) async {
  final items = await ref.watch(fridgeItemsProvider.future);
  final groupedMap = <String, List<FridgeItem>>{};

  for (final item in items) {
    final key = item.receiptId ?? '';
    if (!groupedMap.containsKey(key)) {
      groupedMap[key] = [];
    }
    groupedMap[key]!.add(item);
  }

  return groupedMap.entries.toList();
}

// 1. Definiere ein konstantes Fallback-Item
final _loadingItem = FridgeItem(
  id: 'loading',
  name: 'Loading...',
  quantity: 0,
  storeName: '',
  entryDate: DateTime(1970),
);

final fridgeItemProvider = Provider.autoDispose.family<FridgeItem, String>((
  ref,
  id,
) {
  return ref.watch(
    fridgeItemsProvider.select((state) {
      // 2. Sicherer Zugriff auf die Liste
      final items = state.asData?.value;

      // Wenn die Liste noch lädt (null ist), geben wir sofort das konstante Item zurück
      if (items == null) return _loadingItem;

      // 3. Suche das Item
      try {
        return items.firstWhere(
          (element) => element.id == id,
          // Falls ID nicht gefunden: Konstantes Item zurückgeben
          orElse: () => _loadingItem,
        );
      } catch (_) {
        return _loadingItem;
      }
    }),
  );
});
