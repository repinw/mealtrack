import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/provider/firebase_providers.dart';
import 'package:mealtrack/features/sharing/data/household_repository.dart';
import 'package:mealtrack/features/sharing/presentation/sharing_page.dart';
import 'package:mealtrack/features/sharing/presentation/widgets/sharing_card.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/l10n/app_localizations_de.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';

class FakeHouseholdRepository extends Fake implements HouseholdRepository {
}

void main() {
  late AppLocalizations l10n;

  setUp(() {
    l10n = AppLocalizationsDe();
  });

  Widget buildTestWidget() {
    final fakeFirestore = FakeFirebaseFirestore();
    final mockAuth = MockFirebaseAuth();

    return ProviderScope(
      overrides: [
        firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
        firebaseAuthProvider.overrideWithValue(mockAuth),
        householdRepositoryProvider.overrideWith(
          (ref) => FakeHouseholdRepository(),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('de'),
        home: SharingPage(),
      ),
    );
  }

  group('SharingPage', () {
    testWidgets('displays AppBar with localized sharing title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(l10n.sharing), findsOneWidget);
    });

    testWidgets('contains a Scaffold', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('contains an AppBar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('contains a ListView', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('contains SharingCard widget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SharingCard), findsOneWidget);
    });
  });
}
