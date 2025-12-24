import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/provider/local_storage_service.dart';

void main() {
  test('localStorageServiceProvider returns correct instance', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final service = container.read(localStorageServiceProvider);

    expect(service, isA<LocalStorageService>());
  });
}
