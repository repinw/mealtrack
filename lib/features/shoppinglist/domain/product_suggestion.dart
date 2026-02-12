import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_suggestion.freezed.dart';

@freezed
abstract class ProductSuggestion with _$ProductSuggestion {
  const factory ProductSuggestion({
    required String name,
    required double averagePrice,
    required int count,
  }) = _ProductSuggestion;
}
