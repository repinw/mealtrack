// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(imagePicker)
const imagePickerProvider = ImagePickerProvider._();

final class ImagePickerProvider
    extends $FunctionalProvider<ImagePicker, ImagePicker, ImagePicker>
    with $Provider<ImagePicker> {
  const ImagePickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imagePickerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imagePickerHash();

  @$internal
  @override
  $ProviderElement<ImagePicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ImagePicker create(Ref ref) {
    return imagePicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImagePicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImagePicker>(value),
    );
  }
}

String _$imagePickerHash() => r'7877699a862be48e962306635347623c45e91971';

@ProviderFor(firebaseAiService)
const firebaseAiServiceProvider = FirebaseAiServiceProvider._();

final class FirebaseAiServiceProvider
    extends
        $FunctionalProvider<
          FirebaseAiService,
          FirebaseAiService,
          FirebaseAiService
        >
    with $Provider<FirebaseAiService> {
  const FirebaseAiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseAiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseAiServiceHash();

  @$internal
  @override
  $ProviderElement<FirebaseAiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseAiService create(Ref ref) {
    return firebaseAiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseAiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseAiService>(value),
    );
  }
}

String _$firebaseAiServiceHash() => r'73b132728dd2e16fdd3c577c4aaed9d27c233587';
