import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_suggestion.freezed.dart';

@freezed
abstract class CategorySuggestion with _$CategorySuggestion {
  const factory CategorySuggestion({
    required String name,
    required double averagePrice,
  }) = _CategorySuggestion;
}
