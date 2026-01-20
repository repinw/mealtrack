import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_stats.freezed.dart';

@freezed
abstract class InventoryStats with _$InventoryStats {
  const factory InventoryStats({
    required double totalValue,
    required int scanCount,
    required int articleCount,
  }) = _InventoryStats;

  static const empty = InventoryStats(
    totalValue: 0,
    scanCount: 0,
    articleCount: 0,
  );
}
