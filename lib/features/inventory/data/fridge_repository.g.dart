// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'fridge_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fridgeRepository)
const fridgeRepositoryProvider = FridgeRepositoryProvider._();

final class FridgeRepositoryProvider
    extends
        $FunctionalProvider<
          FridgeRepository,
          FridgeRepository,
          FridgeRepository
        >
    with $Provider<FridgeRepository> {
  const FridgeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fridgeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fridgeRepositoryHash();

  @$internal
  @override
  $ProviderElement<FridgeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FridgeRepository create(Ref ref) {
    return fridgeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FridgeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FridgeRepository>(value),
    );
  }
}

String _$fridgeRepositoryHash() => r'43bd8b2a7db857898ca49dfc9ed84fb01deb815f';
