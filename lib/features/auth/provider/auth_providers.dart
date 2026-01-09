import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mealtrack/core/provider/app_providers.dart';
import 'package:mealtrack/features/auth/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthRepository(auth, GoogleSignIn());
}

@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}
