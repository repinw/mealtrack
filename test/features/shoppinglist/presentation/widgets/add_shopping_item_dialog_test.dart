import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/add_shopping_item_dialog.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';

// Mock Repository to verify interactions
class MockShoppingListRepository implements ShoppingListRepository {
  final List<String> addedItems = [];

  @override
  Future<void> addItem(ShoppingListItem item) async {
    addedItems.add(item.name);
  }

  @override
  Future<void> addOrMergeItem({
    required String name,
    required String? brand,
    String? category,
    required int quantity,
    required double? unitPrice,
  }) async {
    addedItems.add(name);
  }

  @override
  Stream<List<ShoppingListItem>> watchItems() {
    return Stream.value([]);
  }

  @override
  Future<void> deleteItem(String id) async {}

  @override
  Future<void> updateItem(ShoppingListItem item) async {}
  @override
  Future<void> clearList() async {}
}

void main() {
  testWidgets('Dialog renders and adds item', (tester) async {
    final mockRepository = MockShoppingListRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(body: AddShoppingItemDialog()),
        ),
      ),
    );

    // Verify UI elements
    expect(find.text('Artikel hinzufügen'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Hinzufügen'), findsOneWidget);
    expect(find.text('Abbrechen'), findsOneWidget);

    // Enter text
    await tester.enterText(find.byType(TextField), 'New Item');

    // Tap Add
    await tester.tap(find.text('Hinzufügen'));
    await tester.pumpAndSettle();

    // Verify interaction
    expect(mockRepository.addedItems, contains('New Item'));
  });

  testWidgets('Cancel button closes dialog', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Material(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AddShoppingItemDialog(),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Open Dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();
    expect(find.text('Artikel hinzufügen'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    // Dialog should be gone
    expect(find.text('Artikel hinzufügen'), findsNothing);
  });

  testWidgets('submits via keyboard action', (tester) async {
    final mockRepository = MockShoppingListRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: Scaffold(body: AddShoppingItemDialog()),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Keyboard Item');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(mockRepository.addedItems, contains('Keyboard Item'));
  });
}
