// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fridge_item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fridgeItemRepository)
const fridgeItemRepositoryProvider = FridgeItemRepositoryProvider._();

final class FridgeItemRepositoryProvider
    extends
        $FunctionalProvider<
          FridgeItemRepository,
          FridgeItemRepository,
          FridgeItemRepository
        >
    with $Provider<FridgeItemRepository> {
  const FridgeItemRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fridgeItemRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fridgeItemRepositoryHash();

  @$internal
  @override
  $ProviderElement<FridgeItemRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FridgeItemRepository create(Ref ref) {
    return fridgeItemRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FridgeItemRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FridgeItemRepository>(value),
    );
  }
}

String _$fridgeItemRepositoryHash() =>
    r'8ac878db1328744d27b4f120011dafaff127268c';

@ProviderFor(fridgeItem)
const fridgeItemProvider = FridgeItemProvider._();

final class FridgeItemProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FridgeItem>>,
          List<FridgeItem>,
          Stream<List<FridgeItem>>
        >
    with $FutureModifier<List<FridgeItem>>, $StreamProvider<List<FridgeItem>> {
  const FridgeItemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fridgeItemProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fridgeItemHash();

  @$internal
  @override
  $StreamProviderElement<List<FridgeItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FridgeItem>> create(Ref ref) {
    return fridgeItem(ref);
  }
}

String _$fridgeItemHash() => r'91d28f6a91018a7769f631ccbf757801fea2a4d2';

@ProviderFor(availableFridgeItems)
const availableFridgeItemsProvider = AvailableFridgeItemsProvider._();

final class AvailableFridgeItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FridgeItem>>,
          List<FridgeItem>,
          FutureOr<List<FridgeItem>>
        >
    with $FutureModifier<List<FridgeItem>>, $FutureProvider<List<FridgeItem>> {
  const AvailableFridgeItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableFridgeItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableFridgeItemsHash();

  @$internal
  @override
  $FutureProviderElement<List<FridgeItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FridgeItem>> create(Ref ref) {
    return availableFridgeItems(ref);
  }
}

String _$availableFridgeItemsHash() =>
    r'bd4648783d09512d70902c3daab6030b2358b698';

@ProviderFor(groupedFridgeItems)
const groupedFridgeItemsProvider = GroupedFridgeItemsProvider._();

final class GroupedFridgeItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MapEntry<String, List<FridgeItem>>>>,
          List<MapEntry<String, List<FridgeItem>>>,
          FutureOr<List<MapEntry<String, List<FridgeItem>>>>
        >
    with
        $FutureModifier<List<MapEntry<String, List<FridgeItem>>>>,
        $FutureProvider<List<MapEntry<String, List<FridgeItem>>>> {
  const GroupedFridgeItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupedFridgeItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupedFridgeItemsHash();

  @$internal
  @override
  $FutureProviderElement<List<MapEntry<String, List<FridgeItem>>>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MapEntry<String, List<FridgeItem>>>> create(Ref ref) {
    return groupedFridgeItems(ref);
  }
}

String _$groupedFridgeItemsHash() =>
    r'cebb5cd3ea1d95d75bcba6dcb82bf6e1d2c2fab6';

@ProviderFor(fridgeItemController)
const fridgeItemControllerProvider = FridgeItemControllerProvider._();

final class FridgeItemControllerProvider
    extends
        $FunctionalProvider<
          FridgeItemController,
          FridgeItemController,
          FridgeItemController
        >
    with $Provider<FridgeItemController> {
  const FridgeItemControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fridgeItemControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fridgeItemControllerHash();

  @$internal
  @override
  $ProviderElement<FridgeItemController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FridgeItemController create(Ref ref) {
    return fridgeItemController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FridgeItemController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FridgeItemController>(value),
    );
  }
}

String _$fridgeItemControllerHash() =>
    r'e75cca0f0ded1de4a793c4060da4afaa5ffdaa4b';

@ProviderFor(reducedFridgeItem)
const reducedFridgeItemProvider = ReducedFridgeItemProvider._();

final class ReducedFridgeItemProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FridgeItem>>,
          List<FridgeItem>,
          FutureOr<List<FridgeItem>>
        >
    with $FutureModifier<List<FridgeItem>>, $FutureProvider<List<FridgeItem>> {
  const ReducedFridgeItemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reducedFridgeItemProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reducedFridgeItemHash();

  @$internal
  @override
  $FutureProviderElement<List<FridgeItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FridgeItem>> create(Ref ref) {
    return reducedFridgeItem(ref);
  }
}

String _$reducedFridgeItemHash() => r'e0e7829a4966ad1ea240fd81eb8f14f18a0f36e1';
