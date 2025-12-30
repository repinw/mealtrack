// coverage:ignore-file
class StorageException implements Exception {
  final String message;
  final Object? originalException;

  StorageException(this.message, [this.originalException]);

  @override
  String toString() =>
      'StorageException: $message ${originalException != null ? '($originalException)' : ''}';
}
