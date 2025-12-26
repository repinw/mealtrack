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

String _$imagePickerHash() => r'4ade97b98e4e2b1423bb08eb64f280b92f8ac945';

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

String _$firebaseAiServiceHash() => r'b2144f6ef7a680ae818c9465378af01f87ef9930';
