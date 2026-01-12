import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealtrack/core/models/user_profile.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

@riverpod
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

@riverpod
FirebaseFirestore firebaseFirestore(Ref ref) {
  return FirebaseFirestore.instance;
}

@riverpod
Stream<User?> authStateChanges(Ref ref) {
  return ref.watch(firebaseAuthProvider).userChanges();
}

@riverpod
Stream<UserProfile?> userProfile(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);

  final docRef = ref
      .watch(firebaseFirestoreProvider)
      .collection(usersCollection)
      .doc(user.uid);

  return docRef.snapshots().asyncMap((snapshot) async {
    if (!snapshot.exists) {
      final profile = UserProfile(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        isAnonymous: user.isAnonymous,
      );
      await docRef.set(profile.toJson(), SetOptions(merge: true));
      return profile;
    }

    final data = snapshot.data()!;
    final profile = UserProfile.fromJson(data);

    // Sync if critical internal state changed (e.g. anonymous -> permanent)
    if (profile.isAnonymous != user.isAnonymous ||
        profile.email != user.email ||
        profile.displayName != user.displayName) {
      final updatedProfile = profile.copyWith(
        isAnonymous: user.isAnonymous,
        email: user.email,
        displayName: user.displayName,
      );
      await docRef.set(updatedProfile.toJson(), SetOptions(merge: true));
      return updatedProfile;
    }

    return profile;
  });
}

@riverpod
Stream<List<UserProfile>> householdMembers(Ref ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile == null) return Stream.value([]);

  final householdId = profile.householdId ?? profile.uid;

  return ref
      .watch(firebaseFirestoreProvider)
      .collection(usersCollection)
      .where(
        Filter.or(
          Filter('uid', isEqualTo: householdId),
          Filter('householdId', isEqualTo: householdId),
        ),
      )
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => UserProfile.fromJson(doc.data()))
            .toList();
      });
}
