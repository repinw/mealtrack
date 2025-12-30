import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/app.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/home/presentation/home_page.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';

class MockFridgeItems extends FridgeItems {
  @override
  Future<List<FridgeItem>> build() async => [];
}

void main() {
  testWidgets('MealTrackApp builds and displays HomePage', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [fridgeItemsProvider.overrideWith(() => MockFridgeItems())],
        child: const MealTrackApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('MealTrackApp has correct title and theme', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [fridgeItemsProvider.overrideWith(() => MockFridgeItems())],
        child: const MealTrackApp(),
      ),
    );
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'MealTrack');
    expect(materialApp.theme?.useMaterial3, isTrue);
    expect(
      materialApp.theme?.colorScheme.primary,
      ColorScheme.fromSeed(seedColor: Colors.deepPurple).primary,
    );
  });
}
