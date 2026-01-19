import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/shoppinglist/domain/shopping_list_item.dart';
import 'package:mealtrack/features/shoppinglist/presentation/shopping_list_page.dart';
import 'package:mealtrack/features/shoppinglist/data/shopping_list_repository.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mealtrack/core/presentation/widgets/summary_header.dart';

// Fake Repository for UI Test
class FakeShoppingListRepository implements ShoppingListRepository {
  List<ShoppingListItem> items;
  final _controller = StreamController<List<ShoppingListItem>>.broadcast();

  FakeShoppingListRepository(this.items);

  @override
  Stream<List<ShoppingListItem>> watchItems() async* {
    yield items;
    yield* _controller.stream;
  }

  @override
  Future<void> addItem(ShoppingListItem item) async {
    items = [...items, item];
    _controller.add(items);
  }

  final List<String> deletedIds = [];

  @override
  Future<void> deleteItem(String id) async {
    deletedIds.add(id);
    items = items.where((i) => i.id != id).toList();
    _controller.add(items);
  }

  @override
  Future<void> updateItem(ShoppingListItem item) async {
    items = items.map((i) => i.id == item.id ? item : i).toList();
    _controller.add(items);
  }

  bool clearListCalled = false;
  @override
  Future<void> clearList() async {
    clearListCalled = true;
    items = [];
    _controller.add(items);
  }
}

void main() {
  Future<void> pumpShoppingListPage(
    WidgetTester tester,
    ShoppingListRepository repository,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShoppingListPage(),
        ),
      ),
    );
    // Allow FutureBuilder/StreamBuilder to resolve
    await tester.pump();
  }

  testWidgets('ShoppingListPage renders list of items', (tester) async {
    const item1 = ShoppingListItem(id: '1', name: 'Apples');
    const item2 = ShoppingListItem(id: '2', name: 'Bananas');

    final repository = FakeShoppingListRepository([item1, item2]);

    await pumpShoppingListPage(tester, repository);

    // Verify Title
    expect(find.text('Einkaufsliste'), findsOneWidget);

    // Verify Items
    expect(find.text('Apples'), findsOneWidget);
    expect(find.text('Bananas'), findsOneWidget);

    // Verify Stats Header
    expect(find.byType(SummaryHeader), findsOneWidget);
    expect(find.text('UNGEFÄHRE KOSTEN'), findsOneWidget);
  });

  testWidgets('ShoppingListPage renders empty state', (tester) async {
    final repository = FakeShoppingListRepository([]);

    await pumpShoppingListPage(tester, repository);

    expect(find.text('Keine Einträge'), findsOneWidget);
  });

  testWidgets('swiping item dismisses it', (tester) async {
    const item = ShoppingListItem(id: '1', name: 'Apples');
    final repository = FakeShoppingListRepository([item]);

    await pumpShoppingListPage(tester, repository);

    // Swipe item
    await tester.drag(find.text('Apples'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Verify delete was called
    expect(repository.deletedIds, contains('1'));
  });

  testWidgets('tapping clear list button shows confirmation and clears list', (
    tester,
  ) async {
    final repository = FakeShoppingListRepository([]);

    await pumpShoppingListPage(tester, repository);

    // Tap delete all button
    await tester.tap(find.byIcon(Icons.delete_sweep));
    await tester.pumpAndSettle();

    // Verify dialog appears
    expect(find.text('Liste leeren?'), findsOneWidget);
    expect(
      find.text('Möchtest du wirklich alle Einträge löschen?'),
      findsOneWidget,
    );

    // Tap Confirm
    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();

    // Verify clearList was called
    expect(repository.clearListCalled, true);
  });
}
