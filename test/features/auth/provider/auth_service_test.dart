import 'dart:async';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/config/app_config.dart';
import 'package:mealtrack/core/models/user_profile.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    fakeFirestore = FakeFirebaseFirestore();

    when(() => mockUser.uid).thenReturn('test_uid');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.isAnonymous).thenReturn(false);
  });

  group('userProfileProvider', () {
    test('returns null when user is not authenticated', () async {
      final authController = StreamController<User?>();
      addTearDown(authController.close);

      final container = ProviderContainer(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
          authStateChangesProvider.overrideWith((ref) => authController.stream),
        ],
      );
      addTearDown(container.dispose);

      authController.add(null);

      final completer = Completer<UserProfile?>();
      final subscription = container.listen<AsyncValue<UserProfile?>>(
        userProfileProvider,
        (_, next) {
          // If expecting null, we check if data is null
          if (next.hasValue && next.value == null) {
            if (!completer.isCompleted) completer.complete(null);
          }
        },
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      final profile = await completer.future;
      expect(profile, isNull);
    });

    test('creates new profile if one does not exist', () async {
      final authController = StreamController<User?>();
      addTearDown(authController.close);

      final container = ProviderContainer(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
          authStateChangesProvider.overrideWith((ref) => authController.stream),
        ],
      );
      addTearDown(container.dispose);

      final completer = Completer<UserProfile>();
      final subscription = container.listen<AsyncValue<UserProfile?>>(
        userProfileProvider,
        (_, next) {
          if (next.hasValue && next.value != null) {
            if (!completer.isCompleted) completer.complete(next.value!);
          }
        },
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      authController.add(mockUser);

      final profile = await completer.future;

      expect(profile, isNotNull);
      expect(profile.uid, 'test_uid');
      expect(profile.email, 'test@example.com');

      final doc = await fakeFirestore
          .collection(usersCollection)
          .doc('test_uid')
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['displayName'], 'Test User');
    });

    test('returns existing profile', () async {
      const existingProfile = UserProfile(
        uid: 'test_uid',
        email: 'test@example.com',
        displayName: 'Old Name',
        isAnonymous: false,
      );
      await fakeFirestore
          .collection(usersCollection)
          .doc('test_uid')
          .set(existingProfile.toJson());

      // Ensure Mock User matches so NO sync happens
      when(() => mockUser.displayName).thenReturn('Old Name');

      final authController = StreamController<User?>();
      addTearDown(authController.close);

      final container = ProviderContainer(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
          authStateChangesProvider.overrideWith((ref) => authController.stream),
        ],
      );
      addTearDown(container.dispose);

      final completer = Completer<UserProfile>();
      final subscription = container.listen<AsyncValue<UserProfile?>>(
        userProfileProvider,
        (_, next) {
          if (next.hasValue && next.value != null) {
            if (!completer.isCompleted) completer.complete(next.value!);
          }
        },
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      authController.add(mockUser);

      final profile = await completer.future;

      expect(profile, isNotNull);
      expect(profile.displayName, 'Old Name');
    });

    test('updates existing profile if critical data changed', () async {
      const existingProfile = UserProfile(
        uid: 'test_uid',
        email: 'test@example.com',
        displayName: 'Old Name',
        isAnonymous: true, // Initially anonymous
      );
      await fakeFirestore
          .collection(usersCollection)
          .doc('test_uid')
          .set(existingProfile.toJson());

      // Setup user with NEW data (converted to permanent)
      when(() => mockUser.isAnonymous).thenReturn(false);
      when(() => mockUser.displayName).thenReturn('New Name');
      when(() => mockUser.email).thenReturn('new@example.com');

      final authController = StreamController<User?>();
      addTearDown(authController.close);

      final container = ProviderContainer(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
          authStateChangesProvider.overrideWith((ref) => authController.stream),
        ],
      );
      addTearDown(container.dispose);

      final completer = Completer<UserProfile>();
      final subscription = container.listen<AsyncValue<UserProfile?>>(
        userProfileProvider,
        (_, next) {
          if (next.hasValue && next.value != null) {
            final p = next.value!;
            // Wait until it reflects the update
            if (p.isAnonymous == false && p.displayName == 'New Name') {
              if (!completer.isCompleted) completer.complete(p);
            }
          }
        },
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      authController.add(mockUser);

      final profile = await completer.future;

      expect(profile.isAnonymous, isFalse);
      expect(profile.displayName, 'New Name');
      expect(profile.email, 'new@example.com');

      // Verify Firestore update
      final doc = await fakeFirestore
          .collection(usersCollection)
          .doc('test_uid')
          .get();
      expect(doc.data()!['isAnonymous'], isFalse);
      expect(doc.data()!['displayName'], 'New Name');
    });
  });

  group('householdMembersProvider', () {
    test('returns empty list if user profile is null', () async {
      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
          userProfileProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      final completer = Completer<List<UserProfile>>();
      final subscription = container.listen<AsyncValue<List<UserProfile>>>(
        householdMembersProvider,
        (_, next) {
          if (next.hasValue && next.value != null && next.value!.isEmpty) {
            if (!completer.isCompleted) completer.complete(next.value!);
          }
        },
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      final members = await completer.future;
      expect(members, isEmpty);
    });

    test('returns members of the household', () async {
      const hostProfile = UserProfile(
        uid: 'host_uid',
        email: 'host@example.com',
        displayName: 'Host',
        isAnonymous: false,
      );
      const memberProfile = UserProfile(
        uid: 'member_uid',
        email: 'member@example.com',
        displayName: 'Member',
        isAnonymous: false,
        householdId: 'host_uid',
      );
      const otherProfile = UserProfile(
        uid: 'other_uid',
        email: 'other@example.com',
        displayName: 'Other',
        isAnonymous: false,
        householdId: 'other_host',
      );

      await fakeFirestore
          .collection(usersCollection)
          .doc('host_uid')
          .set(hostProfile.toJson());
      await fakeFirestore
          .collection(usersCollection)
          .doc('member_uid')
          .set(memberProfile.toJson());
      await fakeFirestore
          .collection(usersCollection)
          .doc('other_uid')
          .set(otherProfile.toJson());

      final profileController = StreamController<UserProfile?>();
      addTearDown(profileController.close);

      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
          userProfileProvider.overrideWith((ref) => profileController.stream),
        ],
      );
      addTearDown(container.dispose);

      final completer = Completer<List<UserProfile>>();
      final subscription = container.listen<AsyncValue<List<UserProfile>>>(
        householdMembersProvider,
        (_, next) {
          if (next.hasValue && next.value != null && next.value!.length == 2) {
            if (!completer.isCompleted) completer.complete(next.value!);
          }
        },
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      profileController.add(hostProfile);

      final members = await completer.future;

      expect(members.length, 2);
      expect(members.any((m) => m.uid == 'host_uid'), isTrue);
      expect(members.any((m) => m.uid == 'member_uid'), isTrue);
    });
  });
}
