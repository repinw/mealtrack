// coverage:ignore-file
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_providers.g.dart';

@riverpod
ImagePicker imagePicker(Ref ref) {
  return ImagePicker();
}

@riverpod
FilePicker filePicker(Ref ref) {
  return FilePicker.platform;
}

@riverpod
FirebaseAiService firebaseAiService(Ref ref) {
  return FirebaseAiService();
}

@riverpod
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

@riverpod
Stream<User?> authStateChanges(Ref ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
}

@riverpod
Future<void> appInitialization(Ref ref) async {
  try {
    debugPrint('Startup: Initializing AI Service...');
    await ref.watch(firebaseAiServiceProvider).initialize();
    debugPrint('Startup: AI Service initialized.');
  } catch (e) {
    debugPrint('Startup: Failed to initialize AI Service (non-fatal): $e');
  }
}

@riverpod
Future<User> authenticatedUser(Ref ref) async {
  final auth = ref.watch(firebaseAuthProvider);
  if (auth.currentUser == null) {
    throw Exception('User not authenticated');
  }
  return auth.currentUser!;
}
