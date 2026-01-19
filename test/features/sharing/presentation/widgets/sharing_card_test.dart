import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/user_profile.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/sharing/data/household_repository.dart';
import 'package:mealtrack/features/sharing/presentation/widgets/invite_section.dart';
import 'package:mealtrack/features/sharing/presentation/widgets/join_section.dart';
import 'package:mealtrack/features/sharing/presentation/widgets/members_section.dart';
import 'package:mealtrack/features/sharing/presentation/widgets/sharing_card.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class FakeHouseholdRepository extends Fake implements HouseholdRepository {
  bool leaveHouseholdCalled = false;

  @override
  Future<void> leaveHousehold() async {
    leaveHouseholdCalled = true;
  }
}

class FakeUser extends Fake implements User {
  @override
  final String uid;
  @override
  final bool isAnonymous;

  FakeUser({required this.uid, this.isAnonymous = false});
}

class MockFirebaseAuth extends Fake implements FirebaseAuth {
  final User? _currentUser;
  MockFirebaseAuth(this._currentUser);

  @override
  User? get currentUser => _currentUser;
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
  }) {
    return ProviderScope(
      overrides: [
        householdRepositoryProvider.overrideWith((ref) => fakeRepository),
        firebaseAuthProvider.overrideWith(
          (ref) => MockFirebaseAuth(currentUser),
        ),
        authStateChangesProvider.overrideWith(
          (ref) => Stream.value(currentUser),
        ),
        userProfileProvider.overrideWith(
          (ref) => Stream.value(currentUserProfile),
        ),
        householdMembersProvider.overrideWith(
          (ref) => Stream.value(members ?? []),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('de'),
        home: Scaffold(body: SingleChildScrollView(child: SharingCard())),
      ),
    );
  }

  group('SharingCard', () {
    final fakeAnonUser = FakeUser(uid: 'anon1', isAnonymous: true);
    const profileAnon = UserProfile(uid: 'anon1', isAnonymous: true);

    final fakeHostUser = FakeUser(uid: 'host1', isAnonymous: false);
    const profileHost = UserProfile(uid: 'host1', isAnonymous: false);

    final fakeGuestUser = FakeUser(uid: 'guest1', isAnonymous: false);
    const profileGuest = UserProfile(
      uid: 'guest1',
      isAnonymous: false,
      householdId: 'host1',
    );

    testWidgets(
      'Anonymous User: shows JoinSection, InfoBox, NO Members, NO Invite',
      (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            members: [profileAnon],
            currentUser: fakeAnonUser,
            currentUserProfile: profileAnon,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('TEILEN'), findsOneWidget);

        expect(find.byType(JoinSection), findsOneWidget);

        expect(
          find.text(
            'Bitte verknüpfen Sie Ihr Konto, um einen Haushalt erstellen zu können.',
          ),
          findsOneWidget,
        );

        expect(find.byType(MembersSection), findsNothing);
        expect(find.byType(InviteSection), findsNothing);
        expect(find.text('Haushalt verlassen'), findsNothing);
      },
    );

    testWidgets(
      'Host User (Alone): shows JoinSection, InviteSection, NO Members',
      (tester) async {
        // Alone host has 1 member (self)
        await tester.pumpWidget(
          createWidgetUnderTest(
            members: [profileHost],
            currentUser: fakeHostUser,
            currentUserProfile: profileHost,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(JoinSection), findsOneWidget);

        expect(find.byType(InviteSection), findsOneWidget);

        expect(find.byType(MembersSection), findsNothing);

        expect(find.byIcon(Icons.info_outline), findsNothing);
      },
    );

    testWidgets(
      'Host User (With Members): shows MembersSection, InviteSection, NO Join',
      (tester) async {
        // Host with Guest
        await tester.pumpWidget(
          createWidgetUnderTest(
            members: [profileHost, profileGuest],
            currentUser: fakeHostUser,
            currentUserProfile: profileHost,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(JoinSection), findsNothing);

        expect(find.byType(MembersSection), findsOneWidget);

        expect(find.byType(InviteSection), findsOneWidget);
      },
    );

    testWidgets(
      'Guest User: shows MembersSection, Leave Button, NO Join, NO Invite',
      (tester) async {
        // Guest in household
        await tester.pumpWidget(
          createWidgetUnderTest(
            members: [profileHost, profileGuest],
            currentUser: fakeGuestUser,
            currentUserProfile: profileGuest,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(JoinSection), findsNothing);

        expect(find.byType(MembersSection), findsOneWidget);

        expect(find.byType(InviteSection), findsNothing);

        expect(find.text('Haushalt verlassen'), findsOneWidget);
      },
    );

    testWidgets('Leave Household flow works', (tester) async {
      // Guest in household
      await tester.pumpWidget(
        createWidgetUnderTest(
          members: [profileHost, profileGuest],
          currentUser: fakeGuestUser,
          currentUserProfile: profileGuest,
        ),
      );
      await tester.pumpAndSettle();

      // Tap Leave
      await tester.tap(find.text('Haushalt verlassen'));
      await tester.pumpAndSettle();

      expect(find.text('Haushalt verlassen'), findsWidgets);
      expect(
        find.text('Möchten Sie den Haushalt wirklich verlassen?'),
        findsOneWidget,
      );
      expect(find.text('Abbrechen'), findsOneWidget);
      expect(find.text('Verlassen'), findsOneWidget);

      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();
      expect(fakeRepository.leaveHouseholdCalled, isFalse);

      await tester.tap(find.text('Haushalt verlassen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Verlassen'));
      await tester.pumpAndSettle();

      expect(fakeRepository.leaveHouseholdCalled, isTrue);
    });
  });
}
