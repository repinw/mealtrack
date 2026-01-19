import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/user_profile.dart';
import 'package:mealtrack/features/sharing/data/household_repository.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/sharing/presentation/widgets/members_section.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class FakeHouseholdRepository extends Fake implements HouseholdRepository {
  String? removedMemberId;

  @override
  Future<void> removeMember(String uid) async {
    removedMemberId = uid;
  }
}

class FakeUser extends Fake implements User {
  @override
  final String uid;

  FakeUser({required this.uid});
}

void main() {
  late FakeHouseholdRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeHouseholdRepository();
  });

  Widget createWidgetUnderTest({
    List<UserProfile>? members,
    UserProfile? currentUserProfile,
    FakeUser? currentUser,
    bool isLoading = false,
  }) {
    return ProviderScope(
      overrides: [
        householdRepositoryProvider.overrideWith((ref) => fakeRepository),
        firebaseAuthProvider.overrideWith(
          (ref) => MockFirebaseAuth(currentUser),
        ),
        userProfileProvider.overrideWith(
          (ref) => Stream.value(currentUserProfile),
        ),
        householdMembersProvider.overrideWith((ref) {
          if (isLoading) {
            return const Stream.empty();
          }
          return Stream.value(members ?? []);
        }),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('de'),
        home: Scaffold(body: MembersSection()),
      ),
    );
  }

  Widget createWidgetUnderTestWithStream(
    Stream<List<UserProfile>> membersStream, {
    UserProfile? currentUserProfile,
    FakeUser? currentUser,
  }) {
    return ProviderScope(
      overrides: [
        householdRepositoryProvider.overrideWith((ref) => fakeRepository),
        firebaseAuthProvider.overrideWith(
          (ref) => MockFirebaseAuth(currentUser),
        ),
        userProfileProvider.overrideWith(
          (ref) => Stream.value(currentUserProfile),
        ),
        householdMembersProvider.overrideWith((ref) => membersStream),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('de'),
        home: Scaffold(body: MembersSection()),
      ),
    );
  }

  group('MembersSection', () {
    const hostUser = UserProfile(
      uid: 'host1',
      displayName: 'Host User',
      isAnonymous: false,
    );
    const guestUser = UserProfile(
      uid: 'guest1',
      displayName: 'Guest User',
      householdId: 'host1',
    );
    final fakeHost = FakeUser(uid: 'host1');
    final fakeGuest = FakeUser(uid: 'guest1');

    testWidgets('shows nothing when list is empty', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          members: [],
          currentUser: fakeHost,
          currentUserProfile: hostUser,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MembersSection), findsOneWidget);
      expect(find.text('Haushaltsmitglieder'), findsNothing);
    });

    testWidgets('shows nothing when list has only 1 member', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          members: [hostUser],
          currentUser: fakeHost,
          currentUserProfile: hostUser,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Haushaltsmitglieder'), findsNothing);
    });

    testWidgets('renders members list correctly when > 1 members', (
      tester,
    ) async {
      final members = [hostUser, guestUser];

      await tester.pumpWidget(
        createWidgetUnderTest(
          members: members,
          currentUser: fakeHost,
          currentUserProfile: hostUser,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Haushaltsmitglieder'), findsOneWidget);
      expect(find.text('Host User'), findsOneWidget);
      expect(find.text('Guest User'), findsOneWidget);
      // "Du" badge for host (current user)
      expect(find.text('Du'), findsOneWidget);
      // Initials in Avatars
      expect(find.text('H'), findsOneWidget);
      expect(find.text('G'), findsOneWidget);
    });

    testWidgets('shows remove button for guests when current user is host', (
      tester,
    ) async {
      final members = [hostUser, guestUser];

      await tester.pumpWidget(
        createWidgetUnderTest(
          members: members,
          currentUser: fakeHost,
          currentUserProfile: hostUser, // householdId null -> Host
        ),
      );
      await tester.pumpAndSettle();

      // Should find remove button for guest
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    });

    testWidgets('does NOT show remove button when current user is guest', (
      tester,
    ) async {
      final members = [hostUser, guestUser];
      // Current user is guest
      final guestProfile = guestUser;

      await tester.pumpWidget(
        createWidgetUnderTest(
          members: members,
          currentUser: fakeGuest,
          currentUserProfile: guestProfile, // has householdId -> Guest
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.remove_circle_outline), findsNothing);
    });

    testWidgets('remove member flow works', (tester) async {
      final members = [hostUser, guestUser];

      await tester.pumpWidget(
        createWidgetUnderTest(
          members: members,
          currentUser: fakeHost,
          currentUserProfile: hostUser,
        ),
      );
      await tester.pumpAndSettle();

      // Tap remove on guest
      await tester.tap(find.byIcon(Icons.remove_circle_outline));
      await tester.pumpAndSettle();

      // Verify Dialog
      expect(find.text('Mitglied entfernen'), findsOneWidget);
      expect(
        find.text(
          'Möchten Sie dieses Mitglied wirklich aus dem Haushalt entfernen?',
        ),
        findsOneWidget,
      );
      expect(find.text('Abbrechen'), findsOneWidget);
      expect(find.text('Entfernen'), findsOneWidget);

      // Cancel
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();
      expect(fakeRepository.removedMemberId, isNull);

      // Re-open and Confirm
      await tester.tap(find.byIcon(Icons.remove_circle_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entfernen'));
      await tester.pumpAndSettle();

      expect(fakeRepository.removedMemberId, 'guest1');
    });

    testWidgets('shows loading indicator', (tester) async {
      // Use a controller to simulate loading state (no event emitted initially)
      final controller = StreamController<List<UserProfile>>();

      await tester.pumpWidget(
        createWidgetUnderTestWithStream(
          controller.stream,
          currentUser: fakeHost,
          currentUserProfile: hostUser,
        ),
      );
      await tester.pump(const Duration(milliseconds: 10)); // Initial pump

      // Should be loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Emit data
      controller.add([hostUser, guestUser]);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Haushaltsmitglieder'), findsOneWidget);

      await controller.close();
    });
  });
}

class MockFirebaseAuth extends Fake implements FirebaseAuth {
  final User? _currentUser;
  MockFirebaseAuth(this._currentUser);

  @override
  User? get currentUser => _currentUser;
}
