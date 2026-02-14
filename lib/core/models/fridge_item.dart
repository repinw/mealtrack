// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'fridge_item.freezed.dart';
part 'fridge_item.g.dart';

const double fridgeItemAmountEpsilon = 0.000001;

enum FridgeItemAmountUnit { gram, milliliter }

enum FridgeItemRemovalType { eaten, thrownAway }

extension FridgeItemAmountUnitLabel on FridgeItemAmountUnit {
  String get symbol {
    switch (this) {
      case FridgeItemAmountUnit.gram:
        return 'g';
      case FridgeItemAmountUnit.milliliter:
        return 'ml';
    }
  }
}

class NormalizedWeightAmount {
  final double amountBase;
  final FridgeItemAmountUnit unit;

  const NormalizedWeightAmount({required this.amountBase, required this.unit});
}

class NormalizedItemAmounts {
  final FridgeItemAmountUnit unit;
  final double initialAmountBase;
  final double remainingAmountBase;

  const NormalizedItemAmounts({
    required this.unit,
    required this.initialAmountBase,
    required this.remainingAmountBase,
  });
}

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

NormalizedWeightAmount? parseNormalizedWeightAmount(String? rawWeight) {
  if (rawWeight == null) return null;
  final normalized = rawWeight.trim();
  if (normalized.isEmpty) return null;

  final match = RegExp(
    r'^([0-9]+(?:[.,][0-9]+)?)\s*([a-zA-Z]+)$',
  ).firstMatch(normalized);
  if (match == null) return null;

  final amount = double.tryParse(match.group(1)!.replaceAll(',', '.'));
  final unit = match.group(2)?.toLowerCase();
  if (amount == null || amount <= 0 || unit == null) return null;

  switch (unit) {
    case 'mg':
      return NormalizedWeightAmount(
        amountBase: amount / 1000,
        unit: FridgeItemAmountUnit.gram,
      );
    case 'g':
      return NormalizedWeightAmount(
        amountBase: amount,
        unit: FridgeItemAmountUnit.gram,
      );
    case 'kg':
      return NormalizedWeightAmount(
        amountBase: amount * 1000,
        unit: FridgeItemAmountUnit.gram,
      );
    case 'oz':
      return NormalizedWeightAmount(
        amountBase: amount * 28.349523125,
        unit: FridgeItemAmountUnit.gram,
      );
    case 'lb':
    case 'lbs':
      return NormalizedWeightAmount(
        amountBase: amount * 453.59237,
        unit: FridgeItemAmountUnit.gram,
      );
    case 'ml':
      return NormalizedWeightAmount(
        amountBase: amount,
        unit: FridgeItemAmountUnit.milliliter,
      );
    case 'cl':
      return NormalizedWeightAmount(
        amountBase: amount * 10,
        unit: FridgeItemAmountUnit.milliliter,
      );
    case 'l':
      return NormalizedWeightAmount(
        amountBase: amount * 1000,
        unit: FridgeItemAmountUnit.milliliter,
      );
    default:
      return null;
  }
}

NormalizedItemAmounts normalizeItemAmounts({
  required int quantity,
  required int initialQuantity,
  String? weight,
  FridgeItemAmountUnit defaultUnit = FridgeItemAmountUnit.gram,
}) {
  final safeInitialQuantity = initialQuantity < 1 ? 1 : initialQuantity;
  final safeQuantity = quantity.clamp(0, safeInitialQuantity);
  final normalizedWeight = parseNormalizedWeightAmount(weight);

  if (normalizedWeight != null) {
    final initialAmount = normalizedWeight.amountBase * safeInitialQuantity;
    final remainingAmount = normalizedWeight.amountBase * safeQuantity;
    return NormalizedItemAmounts(
      unit: normalizedWeight.unit,
      initialAmountBase: initialAmount,
      remainingAmountBase: remainingAmount,
    );
  }

  return NormalizedItemAmounts(
    unit: defaultUnit,
    initialAmountBase: safeInitialQuantity.toDouble(),
    remainingAmountBase: safeQuantity.toDouble(),
  );
}

FridgeItem normalizeFridgeItemForStorage(
  FridgeItem item, {
  bool resetRemovalCounters = false,
}) {
  final normalized = normalizeItemAmounts(
    quantity: item.quantity,
    initialQuantity: item.initialQuantity,
    weight: item.weight,
    defaultUnit: item.amountUnit,
  );

  return item.copyWith(
    amountUnit: normalized.unit,
    initialAmountBase: normalized.initialAmountBase,
    remainingAmountBase: normalized.remainingAmountBase,
    eatenAmountBase: resetRemovalCounters ? 0.0 : item.eatenAmountBase,
    thrownAwayAmountBase: resetRemovalCounters
        ? 0.0
        : item.thrownAwayAmountBase,
  );
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
    @Default(FridgeItemAmountUnit.gram) FridgeItemAmountUnit amountUnit,
    @Default(0.0) double initialAmountBase,
    @Default(0.0) double remainingAmountBase,
    @Default(0.0) double eatenAmountBase,
    @Default(0.0) double thrownAwayAmountBase,
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

  bool get isConsumed => resolvedRemainingAmountBase <= fridgeItemAmountEpsilon;

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

  FridgeItemAmountUnit get resolvedAmountUnit {
    return amountUnit;
  }

  double get resolvedInitialAmountBase {
    if (initialAmountBase > fridgeItemAmountEpsilon) {
      return initialAmountBase;
    }
    return initialQuantity.toDouble();
  }

  double get resolvedRemainingAmountBase {
    if (remainingAmountBase > fridgeItemAmountEpsilon ||
        initialAmountBase > fridgeItemAmountEpsilon) {
      return remainingAmountBase.clamp(0.0, resolvedInitialAmountBase);
    }
    return quantity.toDouble().clamp(0.0, resolvedInitialAmountBase);
  }

  double get amountPerPieceBase {
    if (initialQuantity <= 0) return resolvedInitialAmountBase;
    return resolvedInitialAmountBase / initialQuantity;
  }

  int estimatePieceDeltaForAmount(double amountBase) {
    final perPiece = amountPerPieceBase;
    if (perPiece <= fridgeItemAmountEpsilon) return 0;
    return (amountBase / perPiece).ceil();
  }

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

    final updatedItem = copyWith(
      quantity: clampedQuantity,
      consumptionEvents: newConsumptionEvents,
    );

    if (initialAmountBase <= fridgeItemAmountEpsilon &&
        remainingAmountBase <= fridgeItemAmountEpsilon) {
      return updatedItem;
    }

    final initialAmount = resolvedInitialAmountBase;
    final perPiece = amountPerPieceBase;
    final nextRemaining = perPiece <= fridgeItemAmountEpsilon
        ? clampedQuantity.toDouble()
        : (clampedQuantity * perPiece).clamp(0.0, initialAmount);

    return updatedItem.copyWith(
      amountUnit: resolvedAmountUnit,
      initialAmountBase: initialAmount,
      remainingAmountBase: nextRemaining,
    );
  }

  FridgeItem adjustAmount({
    required double amountDeltaBase,
    required FridgeItemRemovalType removalType,
    DateTime Function()? now,
  }) {
    if (amountDeltaBase == 0 ||
        amountDeltaBase.isNaN ||
        amountDeltaBase.isInfinite) {
      return this;
    }

    final initialAmount = resolvedInitialAmountBase;
    if (initialAmount <= fridgeItemAmountEpsilon) return this;

    final currentRemaining = resolvedRemainingAmountBase.clamp(
      0.0,
      initialAmount,
    );
    final nextRemaining = (currentRemaining + amountDeltaBase).clamp(
      0.0,
      initialAmount,
    );
    final appliedDelta = nextRemaining - currentRemaining;
    if (appliedDelta.abs() <= fridgeItemAmountEpsilon) return this;

    final removedDelta = -appliedDelta;
    final updatedEaten = removalType == FridgeItemRemovalType.eaten
        ? (eatenAmountBase + removedDelta).clamp(0.0, initialAmount)
        : eatenAmountBase;
    final updatedThrownAway = removalType == FridgeItemRemovalType.thrownAway
        ? (thrownAwayAmountBase + removedDelta).clamp(0.0, initialAmount)
        : thrownAwayAmountBase;

    final perPiece = amountPerPieceBase;
    final calculatedQuantity = perPiece <= fridgeItemAmountEpsilon
        ? quantity
        : (nextRemaining / perPiece).ceil();
    final clampedQuantity = calculatedQuantity
        .clamp(0, initialQuantity)
        .toInt();

    final newConsumptionEvents = List<DateTime>.from(consumptionEvents);
    if (appliedDelta < 0) {
      newConsumptionEvents.add((now ?? DateTime.now)());
    } else if (appliedDelta > 0 && newConsumptionEvents.isNotEmpty) {
      newConsumptionEvents.removeLast();
    }

    return copyWith(
      quantity: clampedQuantity,
      amountUnit: resolvedAmountUnit,
      initialAmountBase: initialAmount,
      remainingAmountBase: nextRemaining,
      eatenAmountBase: updatedEaten,
      thrownAwayAmountBase: updatedThrownAway,
      consumptionEvents: newConsumptionEvents,
    );
  }
}
