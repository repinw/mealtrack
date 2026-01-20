import 'package:freezed_annotation/freezed_annotation.dart';

part 'shopping_list_stats.freezed.dart';

@freezed
abstract class ShoppingListStats with _$ShoppingListStats {
  const factory ShoppingListStats({
    required double totalValue,
    required int scanCount,
    required int articleCount,
  }) = _ShoppingListStats;

  static const empty = ShoppingListStats(
    totalValue: 0,
    scanCount: 0,
    articleCount: 0,
  );
}
