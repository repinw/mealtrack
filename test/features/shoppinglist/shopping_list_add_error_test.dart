import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/add_shopping_item_dialog.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class MockFailingRepository implements ShoppingListRepository {
  @override
  Future<void> addItem(ShoppingListItem item) async {
    throw Exception('Simulated Network Error');
  }

  @override
  Future<void> addOrMergeItem({
    required String name,
    required String? brand,
    String? category,
    required int quantity,
    required double? unitPrice,
  }) async {
    throw Exception('Simulated Network Error');
  }

  @override
  Stream<List<ShoppingListItem>> watchItems() => Stream.value([]);
  @override
  Future<void> deleteItem(String id) async {}
  @override
  Future<void> updateItem(ShoppingListItem item) async {}
  @override
  Future<void> clearList() async {}
}

void main() {
  testWidgets('AddShoppingItemDialog handles addItem error gracefully', (
    tester,
  ) async {
    // Setup
    final repository = MockFailingRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AddShoppingItemDialog()),
        ),
      ),
    );

    // Enter text
    await tester.enterText(find.byType(TextField), 'Test Item');
    await tester.pump();

    // Tap Add button
    final addButton = find.widgetWithText(TextButton, 'Add');
    if (addButton.evaluate().isNotEmpty) {
      await tester.tap(addButton);
    } else {
      await tester.tap(find.widgetWithText(TextButton, 'Hinzufügen'));
    }

    await tester.pumpAndSettle();

    expect(
      find.byType(AddShoppingItemDialog),
      findsOneWidget,
      reason: 'Dialog should remain open on error',
    );
    expect(
      find.byType(SnackBar),
      findsOneWidget,
      reason: 'SnackBar should be shown on error',
    );
  });
}
