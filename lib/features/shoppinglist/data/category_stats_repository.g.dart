// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'category_stats_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categoryStatsRepository)
const categoryStatsRepositoryProvider = CategoryStatsRepositoryProvider._();

final class CategoryStatsRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryStatsRepository,
          CategoryStatsRepository,
          CategoryStatsRepository
        >
    with $Provider<CategoryStatsRepository> {
  const CategoryStatsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryStatsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryStatsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryStatsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryStatsRepository create(Ref ref) {
    return categoryStatsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryStatsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryStatsRepository>(value),
    );
  }
}

String _$categoryStatsRepositoryHash() =>
    r'ebd524966bc1b1772ab8cb8fbf7b85e8de5e3dec';
