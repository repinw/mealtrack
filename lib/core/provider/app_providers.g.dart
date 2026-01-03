// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file

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

@ProviderFor(filePicker)
const filePickerProvider = FilePickerProvider._();

final class FilePickerProvider
    extends $FunctionalProvider<FilePicker, FilePicker, FilePicker>
    with $Provider<FilePicker> {
  const FilePickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filePickerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filePickerHash();

  @$internal
  @override
  $ProviderElement<FilePicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FilePicker create(Ref ref) {
    return filePicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FilePicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FilePicker>(value),
    );
  }
}

String _$filePickerHash() => r'bae1fe0c95c85532cffec63b62cfe564b8356d75';

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

@ProviderFor(firebaseAuth)
const firebaseAuthProvider = FirebaseAuthProvider._();

final class FirebaseAuthProvider
    extends $FunctionalProvider<FirebaseAuth, FirebaseAuth, FirebaseAuth>
    with $Provider<FirebaseAuth> {
  const FirebaseAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseAuthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseAuthHash();

  @$internal
  @override
  $ProviderElement<FirebaseAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseAuth create(Ref ref) {
    return firebaseAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseAuth>(value),
    );
  }
}

String _$firebaseAuthHash() => r'912368c3df3f72e4295bf7a8cda93b9c5749d923';

@ProviderFor(appInitialization)
const appInitializationProvider = AppInitializationProvider._();

final class AppInitializationProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  const AppInitializationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appInitializationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appInitializationHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return appInitialization(ref);
  }
}

String _$appInitializationHash() => r'd83fe9e43fe74edcea02a414d268b03537fb2489';

@ProviderFor(authenticatedUser)
const authenticatedUserProvider = AuthenticatedUserProvider._();

final class AuthenticatedUserProvider
    extends $FunctionalProvider<AsyncValue<User>, User, FutureOr<User>>
    with $FutureModifier<User>, $FutureProvider<User> {
  const AuthenticatedUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authenticatedUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authenticatedUserHash();

  @$internal
  @override
  $FutureProviderElement<User> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<User> create(Ref ref) {
    return authenticatedUser(ref);
  }
}

String _$authenticatedUserHash() => r'51512752e7f32d200b09e23f7a182b7f0f48a798';
