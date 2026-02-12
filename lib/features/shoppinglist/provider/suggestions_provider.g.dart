// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'suggestions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(suggestions)
const suggestionsProvider = SuggestionsProvider._();

final class SuggestionsProvider
    extends
        $FunctionalProvider<
          List<CategorySuggestion>,
          List<CategorySuggestion>,
          List<CategorySuggestion>
        >
    with $Provider<List<CategorySuggestion>> {
  const SuggestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suggestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suggestionsHash();

  @$internal
  @override
  $ProviderElement<List<CategorySuggestion>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<CategorySuggestion> create(Ref ref) {
    return suggestions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CategorySuggestion> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CategorySuggestion>>(value),
    );
  }
}

String _$suggestionsHash() => r'66f62991a96d389f8242970918822818b8a38f8c';

/// Raw stream from Firestore, kept separate so [suggestions] can combine it.

@ProviderFor(categoryStatsStream)
const categoryStatsStreamProvider = CategoryStatsStreamProvider._();

/// Raw stream from Firestore, kept separate so [suggestions] can combine it.

final class CategoryStatsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategorySuggestion>>,
          List<CategorySuggestion>,
          Stream<List<CategorySuggestion>>
        >
    with
        $FutureModifier<List<CategorySuggestion>>,
        $StreamProvider<List<CategorySuggestion>> {
  /// Raw stream from Firestore, kept separate so [suggestions] can combine it.
  const CategoryStatsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryStatsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryStatsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<CategorySuggestion>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CategorySuggestion>> create(Ref ref) {
    return categoryStatsStream(ref);
  }
}

String _$categoryStatsStreamHash() =>
    r'23a841b6b8d1c1a576a0e41a6ee1c7bea9d97440';
