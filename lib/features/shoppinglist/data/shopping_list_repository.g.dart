// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'shopping_list_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shoppingListRepository)
const shoppingListRepositoryProvider = ShoppingListRepositoryProvider._();

final class ShoppingListRepositoryProvider
    extends
        $FunctionalProvider<
          ShoppingListRepository,
          ShoppingListRepository,
          ShoppingListRepository
        >
    with $Provider<ShoppingListRepository> {
  const ShoppingListRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shoppingListRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shoppingListRepositoryHash();

  @$internal
  @override
  $ProviderElement<ShoppingListRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShoppingListRepository create(Ref ref) {
    return shoppingListRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShoppingListRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShoppingListRepository>(value),
    );
  }
}

String _$shoppingListRepositoryHash() =>
    r'adec8ac445abde9549eaa3a95466a637db229e3a';
