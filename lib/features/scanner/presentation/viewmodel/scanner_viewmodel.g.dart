// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

part of 'scanner_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScannerViewModel)
const scannerViewModelProvider = ScannerViewModelProvider._();

final class ScannerViewModelProvider
    extends $AsyncNotifierProvider<ScannerViewModel, List<FridgeItem>> {
  const ScannerViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scannerViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scannerViewModelHash();

  @$internal
  @override
  ScannerViewModel create() => ScannerViewModel();
}

String _$scannerViewModelHash() => r'a474c1255f2d8765f74bc1a0afec5b7fafb92523';

abstract class _$ScannerViewModel extends $AsyncNotifier<List<FridgeItem>> {
  FutureOr<List<FridgeItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<FridgeItem>>, List<FridgeItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FridgeItem>>, List<FridgeItem>>,
              AsyncValue<List<FridgeItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
