import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/exceptions/storage_exception.dart';

void main() {
  group('StorageException', () {
    test('should return correct string representation with message only', () {
      final exception = StorageException('Test Error');
      expect(exception.toString(), 'StorageException: Test Error ');
    });

    test(
      'should return correct string representation with original exception',
      () {
        final original = Exception('Original Error');
        final exception = StorageException('Wrapper Error', original);
        expect(
          exception.toString(),
          'StorageException: Wrapper Error (Exception: Original Error)',
        );
      },
    );
  });
}
