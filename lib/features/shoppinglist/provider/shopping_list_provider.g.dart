// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'shopping_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ShoppingList)
const shoppingListProvider = ShoppingListProvider._();

final class ShoppingListProvider
    extends $StreamNotifierProvider<ShoppingList, List<ShoppingListItem>> {
  const ShoppingListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shoppingListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shoppingListHash();

  @$internal
  @override
  ShoppingList create() => ShoppingList();
}

String _$shoppingListHash() => r'177b67dbc926c5896a8bf72b5764ee16cd4e2f90';

abstract class _$ShoppingList extends $StreamNotifier<List<ShoppingListItem>> {
  Stream<List<ShoppingListItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ShoppingListItem>>, List<ShoppingListItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ShoppingListItem>>,
                List<ShoppingListItem>
              >,
              AsyncValue<List<ShoppingListItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(shoppingListStats)
const shoppingListStatsProvider = ShoppingListStatsProvider._();

final class ShoppingListStatsProvider
    extends
        $FunctionalProvider<
          ShoppingListStats,
          ShoppingListStats,
          ShoppingListStats
        >
    with $Provider<ShoppingListStats> {
  const ShoppingListStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shoppingListStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shoppingListStatsHash();

  @$internal
  @override
  $ProviderElement<ShoppingListStats> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShoppingListStats create(Ref ref) {
    return shoppingListStats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShoppingListStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShoppingListStats>(value),
    );
  }
}

String _$shoppingListStatsHash() => r'818badc18c564db9ea5c1126bbf81ba4a87e005f';
