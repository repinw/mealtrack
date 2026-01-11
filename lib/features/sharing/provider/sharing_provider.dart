import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mealtrack/core/provider/firestore_service.dart';

part 'sharing_provider.g.dart';

@riverpod
class SharingViewModel extends _$SharingViewModel {
  @override
  AsyncValue<String?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> generateCode() async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreServiceProvider);
      return await firestore.generateInviteCode();
    });
    if (ref.mounted) {
      state = result;
    }
  }

  Future<void> joinHousehold(String code) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreServiceProvider);
      await firestore.joinHousehold(code);
      return 'JOINED';
    });

    if (ref.mounted) {
      state = result;
    }
  }
}
