import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/app.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/auth/presentation/welcome_page.dart';
import 'package:mealtrack/features/auth/provider/auth_service.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';

import 'package:mocktail/mocktail.dart';

class MockUser extends Mock implements User {}

class MockFridgeItems extends FridgeItems {
  @override
  Future<List<FridgeItem>> build() async => [];
}

void main() {
  late MockUser mockUser;

  setUp(() {
    mockUser = MockUser();
  });

  testWidgets(
    'MealTrackApp shows loading indicator when auth state is loading',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateChangesProvider.overrideWith(
              (ref) => const Stream.empty(),
            ),
          ],
          child: const MealTrackApp(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('MealTrackApp shows WelcomePage when unauthenticated', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const MealTrackApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WelcomePage), findsOneWidget);
    expect(find.byType(InventoryPage), findsNothing);
  });

  testWidgets('MealTrackApp shows InventoryPage when authenticated', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith(
            (ref) => Stream.value(mockUser),
          ),
          fridgeItemsProvider.overrideWith(() => MockFridgeItems()),
        ],
        child: const MealTrackApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(InventoryPage), findsOneWidget);
    expect(find.byType(WelcomePage), findsNothing);
  });
}
