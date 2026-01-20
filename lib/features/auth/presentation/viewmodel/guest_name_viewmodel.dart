import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtrack/core/extensions/user_extension.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'guest_name_viewmodel.g.dart';

@riverpod
class GuestNameViewModel extends _$GuestNameViewModel {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> submit({required String name, User? user}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final auth = ref.read(firebaseAuthProvider);
      final firestore = ref.read(firebaseFirestoreProvider);

      User? currentUser = user;

      if (currentUser == null) {
        final userCredential = await auth.signInAnonymously();
        currentUser = userCredential.user;
      }

      if (currentUser != null) {
        await currentUser.updateDisplayNameAndReload(
          name,
          firestore: firestore,
        );
      }
    });
  }
}
