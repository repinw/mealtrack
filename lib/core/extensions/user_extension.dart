import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealtrack/core/config/app_config.dart';

extension UserExtension on User {
  Future<void> syncProfileToFirestore({
    String? name,
    FirebaseFirestore? firestore,
  }) async {
    final finalName = name ?? displayName;
    final db = firestore ?? FirebaseFirestore.instance;
    await db.collection(usersCollection).doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': finalName,
      'isAnonymous': isAnonymous,
    }, SetOptions(merge: true));
  }

  Future<void> updateDisplayNameAndReload(
    String name, {
    FirebaseFirestore? firestore,
  }) async {
    await updateDisplayName(name);
    await reload();
    await syncProfileToFirestore(name: name, firestore: firestore);
  }

  Future<void> updateDisplayNameFromProvider({
    FirebaseFirestore? firestore,
  }) async {
    if (displayName != null && displayName!.isNotEmpty) {
      await syncProfileToFirestore(firestore: firestore);
      return;
    }

    for (final provider in providerData) {
      final name = provider.displayName;
      if (name != null && name.isNotEmpty) {
        await updateDisplayNameAndReload(name, firestore: firestore);
        return;
      }
    }

    await syncProfileToFirestore(firestore: firestore);
  }
}
