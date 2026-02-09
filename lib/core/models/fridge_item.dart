import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'fridge_item.freezed.dart';
part 'fridge_item.g.dart';

@freezed
abstract class FridgeItem with _$FridgeItem {
  const FridgeItem._();

  const factory FridgeItem({
    required String id,
    required String name,
    required DateTime entryDate,
    @Default(false) bool isConsumed,
    required String storeName,
    required int quantity,
    @Default(1) int initialQuantity,
    @Default(0.0) double unitPrice,
    String? weight,
    @Default([]) List<DateTime> consumptionEvents,
    String? receiptId,
    DateTime? receiptDate,
    String? language,
    String? brand,
    @Default({}) Map<String, double> discounts,
    @Default(false) bool isDeposit,
    @Default(false) bool isDiscount,
    @Default(false) bool isArchived,
  }) = _FridgeItem;

  /// Creates a new instance of [FridgeItem] with a generated UUID and the current date.
  ///
  /// Optionally accepts a [Uuid] instance and a [now] function for testing purposes.
  factory FridgeItem.create({
    required String name,
    Uuid? uuid,
    required String storeName,
    int quantity = 1,
    double unitPrice = 0,
    String? weight,
    String? receiptId,
    DateTime? receiptDate,
    String? language,
    String? brand,
    Map<String, double>? discounts,
    DateTime Function()? now,
    bool isDeposit = false,
    bool isDiscount = false,
    bool isArchived = false,
  }) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
    if (storeName.trim().isEmpty) {
      throw ArgumentError.value(storeName, 'storeName', 'must not be empty');
    }
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', 'must be greater than 0');
    }

    return FridgeItem(
      id: (uuid ?? const Uuid()).v4(),
      name: name,
      storeName: storeName,
      quantity: quantity,
      unitPrice: unitPrice,
      weight: weight,
      entryDate: (now ?? DateTime.now)(),
      isConsumed: false,
      receiptId: receiptId,
      receiptDate: receiptDate,
      language: language,
      brand: brand,
      discounts: discounts ?? {},
      initialQuantity: quantity,
      consumptionEvents: const [],
      isDeposit: isDeposit,
      isDiscount: isDiscount,
      isArchived: isArchived,
    );
  }

  factory FridgeItem.fromJson(Map<String, dynamic> json) =>
      _$FridgeItemFromJson(json);

  DateTime? get consumptionDate =>
      consumptionEvents.isNotEmpty ? consumptionEvents.last : null;

  double get effectiveUnitPrice {
    if (discounts.isEmpty) return unitPrice;
    final totalDiscount = discounts.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );
    return unitPrice + totalDiscount;
  }

  double get totalPrice => quantity * effectiveUnitPrice;

  /// Returns a new [FridgeItem] with the quantity adjusted by [delta].
  ///
  /// This method encapsulates all logic for quantity changes:
  /// - Adjusts the quantity by the given delta
  /// - Adds a consumption event when quantity decreases (delta < 0)
  /// - Removes the last consumption event when quantity increases (delta > 0)
  /// - Sets isConsumed to true when quantity reaches 0
  /// - Sets isConsumed to false when quantity increases from 0
  ///
  /// The [now] parameter allows injecting a custom DateTime for testing.
  FridgeItem adjustQuantity(int delta, {DateTime Function()? now}) {
    final currentTime = (now ?? DateTime.now)();

    var newQuantity = quantity + delta;
    var newIsConsumed = isConsumed;
    final newConsumptionEvents = List<DateTime>.from(consumptionEvents);

    if (delta < 0) {
      newConsumptionEvents.addAll(
        List.generate(delta.abs(), (_) => currentTime),
      );
    } else if (delta > 0) {
      final eventsToRemove = delta.clamp(0, newConsumptionEvents.length);
      newConsumptionEvents.removeRange(
        newConsumptionEvents.length - eventsToRemove,
        newConsumptionEvents.length,
      );
    }

    if (newQuantity <= 0) {
      newQuantity = 0;
      newIsConsumed = true;
    } else if (newIsConsumed) {
      newIsConsumed = false;
    }

    return copyWith(
      quantity: newQuantity,
      isConsumed: newIsConsumed,
      consumptionEvents: newConsumptionEvents,
    );
  }
}
