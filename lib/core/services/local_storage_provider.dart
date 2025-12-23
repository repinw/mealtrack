import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'local_storage_service.dart';

part 'local_storage_provider.g.dart';

@riverpod
LocalStorageService localStorageService(Ref ref) {
  return LocalStorageService();
}
