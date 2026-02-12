import 'package:freezed_annotation/freezed_annotation.dart';

part 'fridge_item.freezed.dart';
part 'fridge_item.g.dart';

/// Robust DateTime parser that returns DateTime.now() on invalid/null input
DateTime _dateTimeFromJson(dynamic json) {
  if (json == null) return DateTime.now();
  if (json is DateTime) return json;
  if (json is String && json.isNotEmpty) {
    return DateTime.tryParse(json) ?? DateTime.now();
  }
  return DateTime.now();
}

/// Robust nullable DateTime parser that returns null on invalid input
DateTime? _nullableDateTimeFromJson(dynamic json) {
  if (json == null) return null;
  if (json is DateTime) return json;
  if (json is String && json.isNotEmpty) {
    return DateTime.tryParse(json);
  }
  return null;
}

@freezed
abstract class FridgeItem with _$FridgeItem {
  const FridgeItem._();

  const factory FridgeItem({
    required String id,
    required String name,
    @JsonKey(fromJson: _dateTimeFromJson) required DateTime entryDate,
    required String storeName,
    required int quantity,
    @Default(1) int initialQuantity,
    @Default(0.0) double unitPrice,
    String? weight,
    @Default([]) List<DateTime> consumptionEvents,
    String? receiptId,
    @JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? receiptDate,
    String? language,
    String? brand,
    String? category,
    @Default({}) Map<String, double> discounts,
    @Default(false) bool isDeposit,
    @Default(false) bool isDiscount,
    @Default(false) bool isArchived,
  }) = _FridgeItem;

  /// Computed property: an item is consumed when its quantity reaches 0.
  bool get isConsumed => quantity == 0;

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
  /// - Clamps quantity at 0
  /// - Adds consumption events only for effective decrements
  /// - Removes consumption events only for effective increments
  ///
  /// The [now] parameter allows injecting a custom DateTime for testing.
  FridgeItem adjustQuantity(int delta, {DateTime Function()? now}) {
    final candidateQuantity = quantity + delta;
    final clampedQuantity = candidateQuantity < 0 ? 0 : candidateQuantity;
    final appliedDelta = clampedQuantity - quantity;

    if (appliedDelta == 0) return this;

    final newConsumptionEvents = List<DateTime>.from(consumptionEvents);

    if (appliedDelta < 0) {
      final currentTime = (now ?? DateTime.now)();
      newConsumptionEvents.addAll(
        List.generate(-appliedDelta, (_) => currentTime),
      );
    } else {
      final eventsToRemove = appliedDelta.clamp(0, newConsumptionEvents.length);
      newConsumptionEvents.removeRange(
        newConsumptionEvents.length - eventsToRemove,
        newConsumptionEvents.length,
      );
    }

    return copyWith(
      quantity: clampedQuantity,
      consumptionEvents: newConsumptionEvents,
    );
  }
}
