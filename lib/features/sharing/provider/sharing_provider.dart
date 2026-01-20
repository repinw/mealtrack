import 'package:mealtrack/features/sharing/data/household_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      final repository = ref.read(householdRepositoryProvider);
      return await repository.generateInviteCode();
    });
    if (ref.mounted) {
      state = result;
    }
  }

  Future<void> joinHousehold(String code) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final repository = ref.read(householdRepositoryProvider);
      await repository.joinHousehold(code);
      return 'JOINED';
    });

    if (ref.mounted) {
      state = result;
    }
  }
}
