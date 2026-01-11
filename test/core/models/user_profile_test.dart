import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    const userProfile = UserProfile(
      uid: 'test_uid',
      email: 'test@example.com',
      displayName: 'Test User',
      isAnonymous: false,
      householdId: 'household_123',
    );

    test('supports value comparisons', () {
      expect(
        userProfile,
        const UserProfile(
          uid: 'test_uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isAnonymous: false,
          householdId: 'household_123',
        ),
      );
    });

    test('copyWith creates a new instance with updated values', () {
      final updatedUserProfile = userProfile.copyWith(
        displayName: 'New Name',
        isAnonymous: true,
      );

      expect(updatedUserProfile.displayName, 'New Name');
      expect(updatedUserProfile.isAnonymous, true);
      expect(updatedUserProfile.uid, userProfile.uid);
      expect(updatedUserProfile.email, userProfile.email);
    });

    test('fromJson creates a valid instance', () {
      final json = {
        'uid': 'test_uid',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'isAnonymous': false,
        'householdId': 'household_123',
      };

      expect(UserProfile.fromJson(json), userProfile);
    });

    test('toJson returns a valid map', () {
      final json = userProfile.toJson();

      expect(json, {
        'uid': 'test_uid',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'isAnonymous': false,
        'householdId': 'household_123',
      });
    });

    test('defaults isAnonymous to false', () {
      const profile = UserProfile(uid: '123');
      expect(profile.isAnonymous, false);
    });
  });
}
