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

String _$shoppingListHash() => r'e623251912f2806a5a0580c85b0468b8034f6543';

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
